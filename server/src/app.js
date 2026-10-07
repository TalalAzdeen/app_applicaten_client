import { createServer } from 'node:http';
import { verifyWebhook } from './payments.js';
// Server-owned integer minor units. Quote services cannot be paid before approval.
const catalogue = Object.freeze({ s1: null, s2: 15000, s3: 18000, s4: null });
class HttpError extends Error { constructor(status, message) { super(message); this.status = status; } }
async function readBody(request) {
  const chunks = []; let size = 0;
  for await (const chunk of request) { size += chunk.length; if (size > 65536) throw new HttpError(413, 'Request too large'); chunks.push(chunk); }
  return Buffer.concat(chunks);
}
function orderView(order) {
  return { id: order.id, serviceId: order.service, description: order.description, address: JSON.parse(order.address),
    createdAt: order.created, amount: order.amount, currency: order.currency, paid: order.paid === 1 };
}
function validateOrder({ serviceId, description, address }) {
  if (!Object.hasOwn(catalogue, serviceId) || typeof description !== 'string' || !description.trim() || description.length > 2000 || !address ||
      typeof address.label !== 'string' || !address.label.trim() || address.label.length > 100 ||
      typeof address.fullAddress !== 'string' || !address.fullAddress.trim() || address.fullAddress.length > 500 ||
      !Number.isFinite(address.latitude) || Math.abs(address.latitude) > 90 ||
      !Number.isFinite(address.longitude) || Math.abs(address.longitude) > 180) throw new HttpError(400, 'Invalid service, description or address');
}
export function createApp({ store, authenticate, provider, webhookSecret, mode = 'test', origins = [] }) {
  const limits = new Map();
  const checkouts = new Map();
  const checkout = async (orderId, owner) => {
        let order = store.get(orderId, owner);
        if (!order) throw new HttpError(404, 'Order not found');
        if (order.paid || !Number.isSafeInteger(order.amount) || order.amount <= 0) throw new HttpError(409, 'Order already paid or requires an approved quote');
        const saved = store.session(order.id); let session;
        if (saved) {
          session = await provider.get(saved.id);
          if (session.status === 'expired') { store.rotateKey(order.id); order = store.get(order.id, owner); session = null; }
          else if (session.status !== 'open') throw new HttpError(409, 'Checkout completed; await verified webhook');
        }
        session ??= await provider.create(order);
        if (typeof session.id !== 'string' || typeof session.url !== 'string') throw new Error('Invalid checkout response');
        const checkoutUrl = new URL(session.url);
        if (checkoutUrl.protocol !== 'https:' || checkoutUrl.hostname !== 'checkout.stripe.com') throw new Error('Invalid checkout URL');
        store.saveSession(session.id, order.id, session.url); return { url: session.url };
  };
  return createServer(async (request, response) => {
    const send = (status, data) => { response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' }); response.end(JSON.stringify(data)); };
    try {
      const url = new URL(request.url, 'http://internal');
      const origin = request.headers.origin;
      if (origin) {
        if (!origins.includes(origin)) throw new HttpError(403, 'Origin not allowed');
        response.setHeader('Access-Control-Allow-Origin', origin); response.setHeader('Vary', 'Origin');
        response.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        response.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
      }
      if (request.method === 'OPTIONS') { response.writeHead(204); response.end(); return; }
      if (url.pathname === '/health' && request.method === 'GET') {
        const configured = Boolean(provider && authenticate && webhookSecret);
        send(configured ? 200 : 503, { status: configured ? 'configured' : 'configuration_required' }); return;
      }
      if (url.pathname === '/webhooks/stripe' && request.method === 'POST') {
        if (!webhookSecret) throw new HttpError(503, 'Webhook not configured');
        const raw = await readBody(request); let event;
        try { event = verifyWebhook(raw, request.headers['stripe-signature'], webhookSecret); }
        catch { throw new HttpError(400, 'Invalid webhook signature or payload'); }
        if (event.livemode !== (mode === 'live')) throw new HttpError(400, 'Payment mode mismatch');
        if (['checkout.session.completed', 'checkout.session.async_payment_succeeded'].includes(event.type) && event.data?.object?.payment_status === 'paid' && event.data.object.status === 'complete') {
          try { store.acceptPayment(event); } catch { throw new HttpError(409, 'Payment does not match a recorded order'); }
        }
        send(200, { received: true }); return;
      }
      if (!authenticate) throw new HttpError(503, 'Authentication not configured');
      const owner = await authenticate(request.headers.authorization);
      if (!owner) throw new HttpError(401, 'Authentication required');
      const minute = Math.floor(Date.now() / 60000);
      if (limits.size > 10000) for (const [id, entry] of limits) if (entry.minute !== minute) limits.delete(id);
      const rate = limits.get(owner);
      if (rate?.minute === minute && rate.count >= 60) throw new HttpError(429, 'Too many requests');
      limits.set(owner, { minute, count: rate?.minute === minute ? rate.count + 1 : 1 });
      if (request.method === 'GET' && url.pathname === '/orders') { send(200, { orders: store.list(owner).map(orderView) }); return; }
      if (request.method === 'GET' && /^\/orders\/[^/]+$/.test(url.pathname)) {
        const order = store.get(decodeURIComponent(url.pathname.slice(8)), owner);
        if (!order) throw new HttpError(404, 'Order not found'); send(200, orderView(order)); return;
      }
      if (request.method !== 'POST') throw new HttpError(404, 'Route not found');
      if (!request.headers['content-type']?.startsWith('application/json')) throw new HttpError(415, 'JSON required');
      let body;
      try { body = JSON.parse((await readBody(request)).toString('utf8')); }
      catch (error) { if (error instanceof HttpError) throw error; throw new HttpError(400, 'Invalid JSON'); }
      if (!body || typeof body !== 'object' || Array.isArray(body)) throw new HttpError(400, 'JSON object required');
      if (url.pathname === '/orders') {
        validateOrder(body);
        send(201, orderView(store.create({ owner, service: body.serviceId, description: body.description.trim(),
          address: { label: body.address.label.trim(), fullAddress: body.address.fullAddress.trim(), latitude: body.address.latitude, longitude: body.address.longitude },
          amount: catalogue[body.serviceId], currency: 'sar' }))); return;
      }
      if (url.pathname === '/checkout') {
        if (!provider) throw new HttpError(503, 'Payment provider not configured');
        if (typeof body.orderId !== 'string') throw new HttpError(400, 'Order ID required');
        const key = `${owner}:${body.orderId}`;
        let pending = checkouts.get(key);
        if (!pending) {
          pending = checkout(body.orderId, owner);
          checkouts.set(key, pending);
        }
        try { send(200, await pending); }
        finally { if (checkouts.get(key) === pending) checkouts.delete(key); }
        return;
      }
      throw new HttpError(404, 'Route not found');
    } catch (error) { send(error instanceof HttpError ? error.status : 503,
      { error: error instanceof HttpError ? error.message : 'Service temporarily unavailable' }); }
  });
}
