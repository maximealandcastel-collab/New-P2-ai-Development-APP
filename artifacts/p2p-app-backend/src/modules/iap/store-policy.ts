export const STORE_PRODUCTS = {
  month_1: { tier: "monthly", accessTier: "paid" },
  year_1: { tier: "annual", accessTier: "paid" },
  p2p_standard_3m: { tier: "quarterly", accessTier: "paid" },
  p2p_standard_annual: { tier: "annual", accessTier: "paid" },
  p2p_pro_3m: { tier: "quarterly", accessTier: "premium" },
  p2p_pro_annual: { tier: "annual", accessTier: "premium" },
} as const;

export function resolveStoreProduct(id: string) {
  return Object.prototype.hasOwnProperty.call(STORE_PRODUCTS, id) ? STORE_PRODUCTS[id as keyof typeof STORE_PRODUCTS] : null;
}

export function googleSubscriptionDates(data: any, productId: string, now: number, production: boolean) {
  if (production && data.testPurchase) throw new Error("Test purchases cannot activate production access");
  if (!["SUBSCRIPTION_STATE_ACTIVE", "SUBSCRIPTION_STATE_IN_GRACE_PERIOD", "SUBSCRIPTION_STATE_CANCELED"].includes(data.subscriptionState)) {
    throw new Error("Subscription is not entitled");
  }
  const line = data.lineItems?.find((item: any) => item.productId === productId);
  const startDate = new Date(data.startTime);
  const endDate = new Date(line?.expiryTime);
  if (!Number.isFinite(startDate.getTime()) || !Number.isFinite(endDate.getTime()) || endDate.getTime() <= now) {
    throw new Error("Subscription product is missing or expired");
  }
  return { startDate, endDate };
}
