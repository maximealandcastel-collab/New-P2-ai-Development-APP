import { createHash, randomUUID } from 'node:crypto';
import { Router } from 'express';
import pool from '../lib/db';
import { chargeState, mergePaymentState, planFor, secureEqual } from '../services/cloverPolicy';

const router = Router();
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const enterprise = (plan: string) => plan.startsWith('enterprise_');
function configuration() {
  const sandbox = process.env.CLOVER_ENV === 'sandbox';
  if (sandbox && process.env.NODE_ENV === 'production') throw new Error('Sandbox billing cannot grant production access');
  if (!process.env.CLOVER_API_KEY || !process.env.CLOVER_MERCHANT_ID) throw new Error('Clover is not configured');
  return { base: sandbox ? 'https://scl-sandbox.dev.clover.com' : 'https://scl.clover.com', production: !sandbox };
}
let schemaReady: Promise<void> | undefined;
function ready() {
  return schemaReady ??= pool.query(`CREATE TABLE IF NOT EXISTS billing_attempts (
    id UUID PRIMARY KEY, email TEXT NOT NULL, name TEXT, plan TEXT NOT NULL,
    amount_cents INTEGER NOT NULL CHECK (amount_cents > 0), application_id TEXT, environment TEXT NOT NULL,
    charge_id TEXT UNIQUE, status TEXT NOT NULL DEFAULT 'pending',
    provider_created BIGINT, expires_at TIMESTAMPTZ, promo_code TEXT,
    delivered_status TEXT, reconciled_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  ); CREATE TABLE IF NOT EXISTS billing_webhook_events (
    event_hash TEXT PRIMARY KEY, received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  ); CREATE INDEX IF NOT EXISTS billing_reconcile_idx ON billing_attempts(reconciled_at);`)
    .then(() => undefined).catch(error => { schemaReady = undefined; throw error; });
}
async function backend(path: string, body: any) {
  const secret = process.env.APP_BACKEND_SHARED_SECRET;
  const origin = process.env.APP_BACKEND_URL;
  if (!secret || !origin) throw new Error('Internal billing delivery is not configured');
  const parsed = new URL(origin);
  if (process.env.NODE_ENV === 'production' && (parsed.protocol !== 'https:' || /localhost|127\.0\.0\.1|\.replit\.dev$/.test(parsed.hostname))) throw new Error('Invalid production backend origin');
  const response = await fetch(`${origin.replace(/\/$/, '')}/api/v1/${path}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json', 'x-admin-key': secret },
    body: JSON.stringify(body), signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) throw new Error('Backend payment delivery failed');
  const result = await response.json() as any;
  if (result.success !== true) throw new Error('Backend payment delivery was rejected');
  return result;
}
async function clover(path: string, options: RequestInit = {}) {
  const config = configuration();
  const response = await fetch(`${config.base}${path}`, { ...options,
    headers: { Authorization: `Bearer ${process.env.CLOVER_API_KEY}`, 'Content-Type': 'application/json', 'User-Agent': 'P2P-FitTech/1.0', ...options.headers },
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) throw new Error('Provider request failed; retry with the same payment attempt');
  return response.json() as Promise<any>;
}
async function recordCharge(client: any, attempt: any, charge: any) {
  if (attempt.environment !== (configuration().production ? 'production' : 'sandbox')) throw new Error('Payment environment mismatch');
  const status = mergePaymentState(attempt.status, chargeState(charge, attempt, configuration().production));
  if (!Number.isSafeInteger(charge.created) || charge.created <= 0) throw new Error('Provider creation time missing');
  const expires = new Date(charge.created + planFor(attempt.plan).days * 86400000);
  const result = await client.query(`UPDATE billing_attempts SET charge_id=$2, status=$3,
    provider_created=$4, expires_at=$5, reconciled_at=NOW() WHERE id=$1 RETURNING *`,
    [attempt.id, charge.id, status, charge.created, expires]);
  return result.rows[0];
}
async function deliver(attempt: any) {
  if (!attempt.charge_id || attempt.delivered_status === attempt.status) return;
  const payload = { sourcePurchaseId: attempt.charge_id, plan: attempt.plan,
    amountCents: attempt.amount_cents, email: attempt.email, applicationId: attempt.application_id,
    status: attempt.status, environment: attempt.environment, expiresAt: new Date(attempt.expires_at).toISOString() };
  const result = await backend('enterprise/internal/payment', payload);
  await pool.query(`UPDATE billing_attempts SET delivered_status=$2, promo_code=$3
    WHERE id=$1 AND status=$2`, [attempt.id, attempt.status, result.data?.promoCode || null]);
}
export async function reconcileBilling(limit = 25) {
  await ready();
  const candidates = await pool.query(`SELECT id FROM billing_attempts WHERE charge_id IS NOT NULL AND (status <> 'refunded' OR delivered_status IS DISTINCT FROM status)
    AND environment=$2 ORDER BY reconciled_at ASC NULLS FIRST LIMIT $1`, [limit, configuration().production ? 'production' : 'sandbox']);
  let failures = 0;
  for (const candidate of candidates.rows) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const locked = await client.query('SELECT * FROM billing_attempts WHERE id=$1 FOR UPDATE SKIP LOCKED', [candidate.id]);
      if (!locked.rows[0]) { await client.query('ROLLBACK'); continue; }
      const attempt = locked.rows[0];
      const charge = await clover(`/v1/charges/${encodeURIComponent(attempt.charge_id)}`);
      const updated = await recordCharge(client, attempt, charge);
      await client.query('COMMIT');
      await deliver(updated);
    } catch { await client.query('ROLLBACK').catch(() => {}); await pool.query('UPDATE billing_attempts SET reconciled_at=NOW() WHERE id=$1',[candidate.id]).catch(()=>{}); failures++; }
    finally { client.release(); }
  }
  return { checked: candidates.rows.length, failures };
}
router.get('/config', (_req, res) => res.json({ publishableKey: process.env.CLOVER_PUBLISHABLE_KEY || '',
  merchantId: process.env.CLOVER_MERCHANT_ID || '', env: process.env.CLOVER_ENV === 'sandbox' ? 'sandbox' : 'production' }));
router.post('/checkout', async (req, res) => {
  const { token, plan, email, name, applicationId, idempotencyKey } = req.body || {};
  if (typeof token !== 'string' || token.length > 4096 || !token || typeof email !== 'string' ||
      email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || !uuid.test(idempotencyKey || '')) {
    return res.status(400).json({ error: 'Valid card token, email and UUID idempotencyKey are required' });
  }
  let catalog;
  try { catalog = planFor(plan); configuration(); } catch { return res.status(400).json({ error: 'Billing plan or environment is unavailable' }); }
  const cleanEmail = email.trim().toLowerCase();
  const claimId = typeof applicationId === 'string' ? applicationId : null;
  if (enterprise(plan) && !/^[a-f0-9]{24}$/.test(claimId || '')) return res.status(400).json({ error: 'Submit a gym application before payment' });
  let client;
  try {
    await ready();
    if (enterprise(plan)) await backend('enterprise/internal/validate-payment', { applicationId: claimId, email: cleanEmail, plan });
    await pool.query(`INSERT INTO billing_attempts(id,email,name,plan,amount_cents,application_id,environment)
      VALUES($1,$2,$3,$4,$5,$6,$7) ON CONFLICT(id) DO NOTHING`,
      [idempotencyKey, cleanEmail, typeof name === 'string' ? name.trim().slice(0,200) : null, plan, catalog.amount, claimId, configuration().production ? 'production' : 'sandbox']);
    client = await pool.connect();
    await client.query('BEGIN');
    const locked = await client.query('SELECT * FROM billing_attempts WHERE id=$1 FOR UPDATE', [idempotencyKey]);
    let attempt = locked.rows[0];
    if (attempt.email !== cleanEmail || attempt.plan !== plan || attempt.application_id !== claimId || attempt.amount_cents !== catalog.amount) {
      await client.query('ROLLBACK'); return res.status(409).json({ error: 'Payment attempt belongs to different checkout details' });
    }
    if (!attempt.charge_id) {
      const charge = await clover('/v1/charges', { method: 'POST', headers: { 'Idempotency-Key': idempotencyKey },
        body: JSON.stringify({ amount: catalog.amount, currency: 'usd', source: token,
          description: `P2P ${plan}`, receipt_email: cleanEmail, captured: true }) });
      attempt = await recordCharge(client, attempt, charge);
    }
    await client.query('COMMIT');
    // Payment is persisted even if delivery fails. A reconciliation retry never charges again.
    let deliveryPending = false;
    try { await deliver(attempt); } catch { deliveryPending = true; }
    const saved = await pool.query('SELECT promo_code FROM billing_attempts WHERE id=$1', [attempt.id]);
    return res.json({ success: attempt.status === 'paid', chargeId: attempt.charge_id,
      promoCode: saved.rows[0]?.promo_code || null, deliveryPending,
      durationLabel: `${catalog.days}-day`, status: attempt.status });
  } catch {
    if (client) await client.query('ROLLBACK').catch(() => {});
    return res.status(503).json({ error: 'Payment confirmation is pending. Retry using the same checkout attempt; do not start a second payment.' });
  } finally { client?.release(); }
});
// Direct Ecommerce charges use Clover REST payment notifications, not Hosted Checkout payloads.
router.post('/webhook', async (req, res) => {
  if (!secureEqual(req.get('X-Clover-Auth'), process.env.CLOVER_WEBHOOK_AUTH)) return res.status(401).json({ error: 'Invalid webhook authentication' });
  const merchant = process.env.CLOVER_MERCHANT_ID;
  if (!merchant || !process.env.CLOVER_APP_ID || req.body?.appId !== process.env.CLOVER_APP_ID || !Array.isArray(req.body?.merchants?.[merchant])) return res.status(400).json({ error: 'Unexpected webhook merchant or application' });
  try {
    await ready();
    const events = req.body.merchants[merchant];
    if (events.length > 100) return res.status(413).json({ error: 'Too many events' });
    for (const event of events) {
      if (typeof event.objectId !== 'string' || !event.objectId.startsWith('P:')) continue;
      const hash = createHash('sha256').update(JSON.stringify([merchant,event.objectId,event.type,event.ts])).digest('hex');
      await pool.query('INSERT INTO billing_webhook_events(event_hash) VALUES($1) ON CONFLICT DO NOTHING', [hash]);
    }
    // Re-fetch our own known charges. A webhook payload never grants access or supplies an amount.
    const result = await reconcileBilling();
    return res.status(result.failures ? 503 : 200).json({ success: result.failures === 0 });
  } catch { return res.status(503).json({ error: 'Webhook reconciliation unavailable; retry' }); }
});
router.post('/reconcile', async (req, res) => {
  if (!secureEqual(req.get('x-admin-key'), process.env.APP_BACKEND_SHARED_SECRET)) return res.status(401).json({ error: 'Unauthorized' });
  try { const result = await reconcileBilling(100); return res.status(result.failures ? 503 : 200).json(result); }
  catch { return res.status(503).json({ error: 'Reconciliation unavailable' }); }
});
// Explicit, authenticated migration: reverify legacy consumer charges before
// attaching the new durable ledger. Never infer payment from the old status field.
router.post('/migrate-legacy', async (req, res) => {
  if (!secureEqual(req.get('x-admin-key'), process.env.APP_BACKEND_SHARED_SECRET)) return res.status(401).json({ error: 'Unauthorized' });
  try {
    await ready();
    const rows = await pool.query(`SELECT DISTINCT ON (o.clover_charge_id) o.* FROM clover_orders o
      LEFT JOIN billing_attempts b ON b.charge_id=o.clover_charge_id
      WHERE b.id IS NULL AND o.clover_charge_id IS NOT NULL
        AND o.plan IN ('trial_access','three_months','annual','affiliate')
      ORDER BY o.clover_charge_id LIMIT 100`);
    let migrated = 0, failures = 0;
    for (const order of rows.rows) {
      const client = await pool.connect();
      try {
        const plan = planFor(order.plan);
        if (order.amount_cents !== plan.amount) throw new Error('Legacy amount mismatch');
        const charge = await clover(`/v1/charges/${encodeURIComponent(order.clover_charge_id)}`);
        chargeState(charge, { amount_cents: plan.amount, charge_id: order.clover_charge_id }, configuration().production);
        await client.query('BEGIN');
        const inserted = await client.query(`INSERT INTO billing_attempts(id,email,name,plan,amount_cents,charge_id,environment)
          VALUES($1,$2,$3,$4,$5,$6,$7) ON CONFLICT(charge_id) DO NOTHING RETURNING *`,
          [randomUUID(), String(order.email).trim().toLowerCase(), order.name, order.plan, plan.amount,
            order.clover_charge_id, configuration().production ? 'production' : 'sandbox']);
        if (!inserted.rows[0]) { await client.query('ROLLBACK'); continue; }
        const updated = await recordCharge(client, inserted.rows[0], charge);
        await client.query('COMMIT');
        await deliver(updated); migrated++;
      } catch { await client.query('ROLLBACK').catch(()=>{}); failures++; }
      finally { client.release(); }
    }
    return res.status(failures ? 503 : 200).json({ migrated, failures, examined: rows.rows.length });
  } catch { return res.status(503).json({ error: 'Legacy payment reconciliation unavailable' }); }
});
router.get('/web-access/:email', async (req, res) => {
  if (!secureEqual(req.get('x-admin-key'), process.env.APP_BACKEND_SHARED_SECRET)) return res.status(401).json({ error: 'Unauthorized' });
  try {
    await ready();
    const result = await pool.query(`SELECT promo_code, expires_at FROM billing_attempts WHERE email=$1
      AND status='paid' AND delivered_status='paid' AND expires_at>NOW() AND application_id IS NULL
      ORDER BY expires_at DESC LIMIT 1`, [String(req.params.email).trim().toLowerCase()]);
    return res.json({ hasAccess: !!result.rows[0], promoCode: result.rows[0]?.promo_code || null, expiresAt: result.rows[0]?.expires_at || null });
  } catch { return res.status(503).json({ error: 'Billing unavailable' }); }
});
export default router;

export function startBillingReconciliation() {
  if (!process.env.CLOVER_API_KEY || !process.env.APP_BACKEND_SHARED_SECRET) return;
  let running = false;
  const tick = async () => {
    if (running) return;
    running = true;
    try { const result = await reconcileBilling(100); if (result.failures) console.error('[Billing] reconciliation failures', result.failures); }
    catch { console.error('[Billing] reconciliation unavailable; retrying'); }
    finally { running = false; }
  };
  void tick();
  const timer = setInterval(() => void tick(), 60000);
  timer.unref();
  return timer;
}
