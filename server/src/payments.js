import { createHmac, timingSafeEqual } from 'node:crypto';
export function verifyWebhook(raw, header, secret, now = Date.now()) {
  if (typeof header !== 'string' || !secret) throw new Error('Missing signature');
  const parts = header.split(',').map(part => part.trim().split('='));
  const timestamps = parts.filter(([key]) => key === 't');
  if (timestamps.length !== 1) throw new Error('Invalid timestamp');
  const timestamp = timestamps[0][1];
  if (!/^\d+$/.test(timestamp) || Math.abs(now / 1000 - Number(timestamp)) > 300) throw new Error('Expired signature');
  const expected = createHmac('sha256', secret).update(timestamp).update('.').update(raw).digest();
  const valid = parts.filter(([key]) => key === 'v1').some(([, signature]) => {
    if (!/^[a-f0-9]{64}$/.test(signature)) return false;
    return timingSafeEqual(expected, Buffer.from(signature, 'hex'));
  });
  if (!valid) throw new Error('Invalid signature');
  const event = JSON.parse(raw.toString('utf8'));
  if (typeof event.id !== 'string' || !event.id || typeof event.type !== 'string') throw new Error('Invalid event');
  return event;
}
export class StripeProvider {
  constructor({ key, mode, returnUrl, fetcher = fetch }) {
    if (!['test', 'live'].includes(mode) || !key.startsWith(`sk_${mode}_`)) throw new Error('Payment mode/key mismatch');
    const url = new URL(returnUrl);
    if (url.protocol !== 'https:') throw new Error('Return URL requires HTTPS');
    this.key = key; this.mode = mode; this.returnUrl = url; this.fetcher = fetcher;
  }
  async request(path, { method = 'GET', body, key } = {}) {
    const response = await this.fetcher(`https://api.stripe.com/v1/${path}`, { method,
      headers: { Authorization: `Bearer ${this.key}`, 'Stripe-Version': '2025-06-30.basil',
        ...(body ? { 'Content-Type': 'application/x-www-form-urlencoded' } : {}), ...(key ? { 'Idempotency-Key': key } : {}) },
      body, signal: AbortSignal.timeout(20000) });
    if (!response.ok) throw new Error('Payment provider request failed');
    return response.json();
  }
  async create(order) {
    const success = new URL(this.returnUrl); success.searchParams.set('checkout', 'returned');
    const cancel = new URL(this.returnUrl); cancel.searchParams.set('checkout', 'cancelled');
    const body = new URLSearchParams({ mode: 'payment', success_url: success.href, cancel_url: cancel.href,
      client_reference_id: order.owner, 'metadata[order_id]': order.id,
      'line_items[0][price_data][currency]': order.currency, 'line_items[0][price_data][unit_amount]': String(order.amount),
      'line_items[0][price_data][product_data][name]': `SALLIH service ${order.service}`, 'line_items[0][quantity]': '1' });
    return this.request('checkout/sessions', { method: 'POST', body, key: order.checkout_key });
  }
  get(sessionId) { return this.request(`checkout/sessions/${encodeURIComponent(sessionId)}`); }
}
