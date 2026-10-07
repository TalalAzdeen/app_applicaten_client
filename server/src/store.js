import { DatabaseSync } from 'node:sqlite';
import { randomUUID } from 'node:crypto';
export class Store {
  constructor(path) {
    this.db = new DatabaseSync(path);
    this.db.exec(`PRAGMA foreign_keys=ON; PRAGMA journal_mode=WAL;
      CREATE TABLE IF NOT EXISTS orders (id TEXT PRIMARY KEY, owner TEXT NOT NULL, service TEXT NOT NULL,
        description TEXT NOT NULL, address TEXT NOT NULL, created TEXT NOT NULL,
        amount INTEGER, currency TEXT NOT NULL, paid INTEGER NOT NULL DEFAULT 0, checkout_key TEXT NOT NULL UNIQUE);
      CREATE TABLE IF NOT EXISTS sessions (id TEXT PRIMARY KEY, order_id TEXT NOT NULL REFERENCES orders(id), url TEXT NOT NULL);
      CREATE TABLE IF NOT EXISTS events (id TEXT PRIMARY KEY);
      CREATE TABLE IF NOT EXISTS receipts (order_id TEXT PRIMARY KEY REFERENCES orders(id), session_id TEXT NOT NULL UNIQUE,
        amount INTEGER NOT NULL, currency TEXT NOT NULL, paid_at TEXT NOT NULL);`);
  }
  create({ owner, service, description, address, amount, currency }) {
    const id = randomUUID();
    this.db.prepare('INSERT INTO orders VALUES (?,?,?,?,?,?,?,?,0,?)').run(
      id, owner, service, description, JSON.stringify(address), new Date().toISOString(), amount, currency, randomUUID());
    return this.get(id, owner);
  }
  get(id, owner) { return this.db.prepare('SELECT * FROM orders WHERE id=? AND owner=?').get(id, owner); }
  list(owner) { return this.db.prepare('SELECT * FROM orders WHERE owner=? ORDER BY created DESC').all(owner); }
  session(orderId) { return this.db.prepare('SELECT * FROM sessions WHERE order_id=? ORDER BY rowid DESC LIMIT 1').get(orderId); }
  saveSession(id, orderId, url) { this.db.prepare('INSERT OR IGNORE INTO sessions VALUES (?,?,?)').run(id, orderId, url); }
  rotateKey(orderId) { this.db.prepare('UPDATE orders SET checkout_key=? WHERE id=?').run(randomUUID(), orderId); }
  acceptPayment(event) {
    const session = event.data?.object;
    this.db.exec('BEGIN IMMEDIATE');
    try {
      if (this.db.prepare('SELECT id FROM events WHERE id=?').get(event.id)) { this.db.exec('COMMIT'); return; }
      const order = this.db.prepare(`SELECT orders.* FROM orders JOIN sessions ON orders.id=sessions.order_id WHERE sessions.id=?`).get(session.id);
      if (!order || session.metadata?.order_id !== order.id || session.client_reference_id !== order.owner ||
          session.amount_total !== order.amount || session.currency !== order.currency) throw new Error('Payment does not match trusted order');
      this.db.prepare('INSERT OR IGNORE INTO receipts VALUES (?,?,?,?,?)').run(order.id, session.id, order.amount, order.currency, new Date().toISOString());
      this.db.prepare('UPDATE orders SET paid=1 WHERE id=?').run(order.id);
      this.db.prepare('INSERT INTO events VALUES (?)').run(event.id);
      this.db.exec('COMMIT');
    } catch (error) { this.db.exec('ROLLBACK'); throw error; }
  }
  close() { this.db.close(); }
}
