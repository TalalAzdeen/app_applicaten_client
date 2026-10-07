import test from 'node:test';
import assert from 'node:assert/strict';
import { createHmac, randomBytes } from 'node:crypto';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Store } from '../src/store.js';
import { createApp } from '../src/app.js';
import { verifyWebhook, StripeProvider } from '../src/payments.js';
import { supabaseAuthenticator } from '../src/auth.js';

const address = { label: 'Home', fullAddress: 'Building 1', latitude: 24.7136, longitude: 46.6753 };
async function fixture(t) {
  const store = new Store(':memory:');
  const secret = randomBytes(32).toString('hex');
  let creates = 0;
  const sessions = new Map();
  const provider = {
    async create(order) {
      creates++;
      await new Promise(resolve => setTimeout(resolve, 5));
      const session = { id: `cs_${creates}`, url: `https://checkout.stripe.com/c/pay/${creates}`, status: 'open',
        metadata: { order_id: order.id }, client_reference_id: order.owner, amount_total: order.amount, currency: order.currency };
      sessions.set(session.id, session); return session;
    },
    async get(id) { return sessions.get(id); },
  };
  const app = createApp({ store, provider, webhookSecret: secret, origins: ['https://app.example.com'],
    authenticate: async header => header === 'Bearer alice' ? 'alice' : header === 'Bearer bob' ? 'bob' : null });
  await new Promise(resolve => app.listen(0, '127.0.0.1', resolve));
  t.after(async () => { await new Promise(resolve => app.close(resolve)); store.close(); });
  const base = `http://127.0.0.1:${app.address().port}`;
  const request = async (path, { method = 'GET', owner = 'alice', body, headers = {} } = {}) => {
    const response = await fetch(base + path, { method, headers: {
      ...(owner ? { Authorization: `Bearer ${owner}` } : {}), 'Content-Type': 'application/json', ...headers },
      body: body === undefined ? undefined : JSON.stringify(body) });
    return { status: response.status, body: await response.json() };
  };
  const order = async (serviceId = 's2', overrides = {}) => (await request('/orders', {
    method: 'POST', body: { serviceId, description: 'Repair the tap', address, ...overrides } })).body;
  const webhook = async (session, overrides = {}, signatureSecret = secret) => {
    const event = { id: 'evt_first', type: 'checkout.session.completed', livemode: false,
      data: { object: { ...session, status: 'complete', payment_status: 'paid' } }, ...overrides };
    const raw = JSON.stringify(event);
    const timestamp = Math.floor(Date.now() / 1000);
    const signature = createHmac('sha256', signatureSecret).update(`${timestamp}.${raw}`).digest('hex');
    const response = await fetch(base + '/webhooks/stripe', { method: 'POST', body: raw,
      headers: { 'Stripe-Signature': `t=${timestamp},v1=${signature}` } });
    return response.status;
  };
  return { store, request, order, webhook, sessions, secret, creates: () => creates };
}

test('anonymous callers cannot create orders', async t => {
  const f = await fixture(t);
  assert.equal((await f.request('/orders', { method: 'POST', owner: null, body: {} })).status, 401);
});
test('prices and ownership come from server, ignoring client fields', async t => {
  const f = await fixture(t); const order = await f.order('s2', { amount: 1, owner: 'bob', currency: 'usd' });
  assert.equal(order.amount, 15000); assert.equal(order.currency, 'sar');
  assert.equal(f.store.get(order.id, 'alice').owner, 'alice');
});
test('invalid locations and unknown services fail validation', async t => {
  const f = await fixture(t);
  for (const body of [{ serviceId: 'unknown', description: 'Repair', address },
    { serviceId: 's2', description: 'Repair', address: { ...address, latitude: 91 } },
    { serviceId: 's2', description: 'Repair', address: { ...address, longitude: '46' } },
    { serviceId: 's2', description: ' ', address }]) {
    assert.equal((await f.request('/orders', { method: 'POST', body })).status, 400);
  }
});
test('another customer cannot read or pay an order', async t => {
  const f = await fixture(t); const order = await f.order();
  assert.equal((await f.request(`/orders/${order.id}`, { owner: 'bob' })).status, 404);
  assert.equal((await f.request('/checkout', { method: 'POST', owner: 'bob', body: { orderId: order.id } })).status, 404);
});
test('quote services cannot charge an unapproved amount', async t => {
  const f = await fixture(t); const order = await f.order('s1');
  assert.equal((await f.request('/checkout', { method: 'POST', body: { orderId: order.id, amount: 200 } })).status, 409);
  assert.equal(f.creates(), 0);
});
test('concurrent and repeated checkout requests reuse one session', async t => {
  const f = await fixture(t); const order = await f.order();
  const requests = await Promise.all(Array.from({ length: 4 }, () => f.request('/checkout', { method: 'POST', body: { orderId: order.id } })));
  assert.ok(requests.every(result => result.status === 200 && result.body.url === requests[0].body.url));
  assert.equal(f.creates(), 1);
  assert.equal((await f.request('/checkout', { method: 'POST', body: { orderId: order.id } })).status, 200);
  assert.equal(f.creates(), 1);
});
test('expired sessions get a fresh key; completed sessions await webhook', async t => {
  const f = await fixture(t); const order = await f.order();
  await f.request('/checkout', { method: 'POST', body: { orderId: order.id } });
  const oldKey = f.store.get(order.id, 'alice').checkout_key;
  f.sessions.get('cs_1').status = 'expired';
  await Promise.all([1, 2].map(() => f.request('/checkout', { method: 'POST', body: { orderId: order.id } })));
  assert.equal(f.creates(), 2); assert.notEqual(f.store.get(order.id, 'alice').checkout_key, oldKey);
  f.sessions.get('cs_2').status = 'complete';
  assert.equal((await f.request('/checkout', { method: 'POST', body: { orderId: order.id } })).status, 409);
  assert.equal(f.store.get(order.id, 'alice').paid, 0);
});
test('forged webhook cannot mark an order paid', async t => {
  const f = await fixture(t); const order = await f.order();
  await f.request('/checkout', { method: 'POST', body: { orderId: order.id } });
  assert.equal(await f.webhook(f.sessions.get('cs_1'), {}, 'incorrect-fixture-secret'), 400);
  assert.equal(f.store.get(order.id, 'alice').paid, 0);
});
test('valid signatures still require matching amount, currency, customer and order', async t => {
  const f = await fixture(t); const order = await f.order();
  await f.request('/checkout', { method: 'POST', body: { orderId: order.id } });
  const session = f.sessions.get('cs_1');
  for (const changes of [{ amount_total: 1 }, { currency: 'usd' }, { client_reference_id: 'bob' }, { metadata: { order_id: 'other' } }, { id: 'unknown' }]) {
    assert.equal(await f.webhook({ ...session, ...changes }), 409);
    assert.equal(f.store.get(order.id, 'alice').paid, 0);
  }
});
test('verified payment persists one receipt and duplicate webhooks are idempotent', async t => {
  const f = await fixture(t); const order = await f.order();
  await f.request('/checkout', { method: 'POST', body: { orderId: order.id } });
  const session = f.sessions.get('cs_1');
  assert.equal(await f.webhook(session), 200); assert.equal(await f.webhook(session), 200);
  assert.equal(await f.webhook(session, { id: 'evt_duplicate_session' }), 200);
  assert.equal(f.store.db.prepare('SELECT COUNT(*) AS count FROM receipts').get().count, 1);
  assert.equal((await f.request(`/orders/${order.id}`)).body.paid, true);
  assert.equal((await f.request('/checkout', { method: 'POST', body: { orderId: order.id } })).status, 409);
});
test('pending payments and wrong live/test modes never confirm payment', async t => {
  const f = await fixture(t); const order = await f.order();
  await f.request('/checkout', { method: 'POST', body: { orderId: order.id } });
  const session = f.sessions.get('cs_1');
  assert.equal(await f.webhook(session, { data: { object: { ...session, status: 'complete', payment_status: 'unpaid' } } }), 200);
  assert.equal(await f.webhook(session, { livemode: true }), 400);
  assert.equal(f.store.get(order.id, 'alice').paid, 0);
});
test('CORS restricts callers to configured web origins', async t => {
  const f = await fixture(t);
  assert.equal((await f.request('/orders', { headers: { Origin: 'https://evil.example.com' } })).status, 403);
  assert.equal((await f.request('/orders', { headers: { Origin: 'https://app.example.com' } })).status, 200);
});
test('webhook timestamps and payload integrity are checked', () => {
  const raw = Buffer.from(JSON.stringify({ id: 'evt_signed', type: 'test' }));
  const secret = randomBytes(32).toString('hex'); const timestamp = 1000;
  const signature = createHmac('sha256', secret).update(`${timestamp}.`).update(raw).digest('hex');
  const header = `t=${timestamp},v1=${signature}`;
  assert.equal(verifyWebhook(raw, header, secret, timestamp * 1000).id, 'evt_signed');
  assert.throws(() => verifyWebhook(raw, header, secret, (timestamp + 301) * 1000));
  assert.throws(() => verifyWebhook(Buffer.from('{}'), header, secret, timestamp * 1000));
  assert.throws(() => verifyWebhook(raw, `${header},t=${timestamp}`, secret, timestamp * 1000));
});
test('order ledger survives reopening its database', () => {
  const directory = mkdtempSync(join(tmpdir(), 'sallih-store-'));
  const path = join(directory, 'orders.sqlite');
  try {
    let store = new Store(path);
    const order = store.create({ owner: 'alice', service: 's2', description: 'Repair', address, amount: 15000, currency: 'sar' });
    store.close(); store = new Store(path);
    assert.equal(store.get(order.id, 'alice').amount, 15000); store.close();
  } finally { rmSync(directory, { recursive: true, force: true }); }
});
test('authentication is validated remotely and rejects expired/invalid tokens', async () => {
  let calls = 0;
  const authenticate = supabaseAuthenticator({ url: 'https://auth.example.com', publicKey: 'public-fixture',
    fetcher: async (url, options) => {
      calls++; assert.equal(url.pathname, '/auth/v1/user');
      return new Response(JSON.stringify({ id: 'trusted-user' }), { status: options.headers.Authorization === 'Bearer valid-token' ? 200 : 401 });
    } });
  assert.equal(await authenticate('Bearer valid-token'), 'trusted-user');
  assert.equal(await authenticate('Bearer expired-token'), null);
  assert.equal(await authenticate('Basic invalid'), null); assert.equal(calls, 2);
});
test('Stripe uses trusted amounts, fixed return URLs and idempotency keys', async () => {
  const provider = new StripeProvider({ key: 'sk_test_synthetic_fixture', mode: 'test', returnUrl: 'https://app.example.com/',
    fetcher: async (url, options) => {
      assert.equal(url, 'https://api.stripe.com/v1/checkout/sessions');
      assert.equal(options.headers['Idempotency-Key'], 'checkout_key');
      assert.equal(options.body.get('line_items[0][price_data][unit_amount]'), '15000');
      assert.equal(new URL(options.body.get('success_url')).origin, 'https://app.example.com');
      return new Response(JSON.stringify({ id: 'cs_fixture', url: 'https://checkout.stripe.com/c/pay/fixture' }));
    } });
  assert.equal((await provider.create({ id: 'order', owner: 'alice', amount: 15000, currency: 'sar', service: 's2', checkout_key: 'checkout_key' })).id, 'cs_fixture');
  assert.throws(() => new StripeProvider({ key: 'sk_test_fixture', mode: 'live', returnUrl: 'https://app.example.com/' }));
});
