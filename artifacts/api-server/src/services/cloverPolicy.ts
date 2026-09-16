import { createHash, createHmac, timingSafeEqual } from 'node:crypto';

export const plans = {
  trial_access: { amount: 499, days: 7 }, three_months: { amount: 1999, days: 90 },
  annual: { amount: 12000, days: 365 }, affiliate: { amount: 1000, days: 180 },
  enterprise_core: { amount: 4999, days: 30 }, enterprise_elite: { amount: 30599, days: 30 },
} as const;
export function planFor(value: unknown) {
  if (typeof value !== 'string' || !Object.prototype.hasOwnProperty.call(plans, value)) throw new Error('Invalid plan');
  return plans[value as keyof typeof plans];
}
export function secureEqual(a: unknown, b: unknown): boolean {
  if (typeof a !== 'string' || typeof b !== 'string' || !a || !b) return false;
  return timingSafeEqual(createHash('sha256').update(a).digest(), createHash('sha256').update(b).digest());
}
export function verifyHostedSignature(raw: Buffer, header: string, secret: string, now = Date.now()) {
  const parts = header.split(',').map(x => x.trim().split('='));
  const stamps = parts.filter(([key]) => key === 't');
  if (!secret || stamps.length !== 1 || !/^\d+$/.test(stamps[0][1] || '')) return false;
  const stamp = Number(stamps[0][1]);
  if (!Number.isSafeInteger(stamp) || Math.abs(now / 1000 - stamp) > 300) return false;
  const expected = createHmac('sha256', secret).update(`${stamp}.`).update(raw).digest('hex');
  return parts.some(([key, value]) => key === 'v1' && /^[a-f0-9]{64}$/i.test(value || '') && secureEqual(value.toLowerCase(), expected));
}
export function chargeState(charge: any, expected: { amount_cents: number; charge_id?: string }, production: boolean) {
  if (!charge || typeof charge.id !== 'string' || (expected.charge_id && charge.id !== expected.charge_id) ||
      charge.amount !== expected.amount_cents || String(charge.currency).toLowerCase() !== 'usd' ||
      (production && charge.livemode === false)) throw new Error('Provider charge identity, amount, currency or environment mismatch');
  if (charge.refunded === true || (typeof charge.amount_refunded === 'number' && charge.amount_refunded > 0)) return 'refunded';
  if (charge.paid !== true || charge.captured !== true || charge.status !== 'succeeded') throw new Error('Payment is not captured and successful');
  return 'paid';
}
export function mergePaymentState(previous: string, verified: string) {
  // Old delivery or an earlier concurrent provider response cannot undo revocation.
  return previous === 'refunded' ? previous : verified;
}
