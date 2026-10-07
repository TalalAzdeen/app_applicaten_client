import { mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { Store } from './store.js';
import { StripeProvider } from './payments.js';
import { supabaseAuthenticator } from './auth.js';
import { createApp } from './app.js';
process.umask(0o077);
const path = resolve(process.env.DATABASE_PATH || './data/sallih.sqlite');
mkdirSync(dirname(path), { recursive: true });
const store = new Store(path);
const mode = process.env.PAYMENT_MODE || 'test';
if (!['test', 'live'].includes(mode)) throw new Error('Invalid payment mode');
const provider = process.env.STRIPE_SECRET_KEY && process.env.CHECKOUT_RETURN_URL
  ? new StripeProvider({ key: process.env.STRIPE_SECRET_KEY, mode, returnUrl: process.env.CHECKOUT_RETURN_URL }) : null;
const authenticate = process.env.SUPABASE_URL && process.env.SUPABASE_ANON_KEY
  ? supabaseAuthenticator({ url: process.env.SUPABASE_URL, publicKey: process.env.SUPABASE_ANON_KEY }) : null;
const app = createApp({ store, provider, authenticate, mode, webhookSecret: process.env.STRIPE_WEBHOOK_SECRET,
  origins: (process.env.ALLOWED_ORIGINS || '').split(',').filter(Boolean) });
app.requestTimeout = 30000; app.headersTimeout = 15000;
app.listen(Number(process.env.PORT || 8080), process.env.HOST || '127.0.0.1', () => console.log('SALLIH API started'));
for (const signal of ['SIGTERM', 'SIGINT']) process.on(signal, () => app.close(() => { store.close(); process.exit(0); }));
