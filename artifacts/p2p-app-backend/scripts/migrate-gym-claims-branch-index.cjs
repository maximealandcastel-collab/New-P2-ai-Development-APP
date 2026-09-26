// Run once before deploying branch-specific claims. Dry-run by default.
// DATABASE_URL=... node scripts/migrate-gym-claims-branch-index.cjs --apply
const mongoose = require('mongoose');

async function main() {
  const uri = process.env.DATABASE_URL;
  if (!uri) throw new Error('DATABASE_URL is required');
  await mongoose.connect(uri);
  try {
    const collection = mongoose.connection.db.collection('gymclaims');
    const indexes = await collection.indexes();
    const legacy = indexes.filter((index) => index.unique &&
      JSON.stringify(index.key) === JSON.stringify({ workEmail: 1, gymName: 1 }) &&
      index.partialFilterExpression?.status === 'pending_review');
    const needsMigration = legacy.some((index) =>
      index.partialFilterExpression?.locationId === undefined);
    console.log({ legacyIndexes: legacy.map((index) => index.name), needsMigration });
    if (!process.argv.includes('--apply')) return;
    // Create branch protection before removing the old brand-wide constraint.
    await collection.createIndex({ workEmail: 1, franchiseId: 1, locationId: 1 }, {
      name: 'pending_branch_claim_identity', unique: true,
      partialFilterExpression: { status: 'pending_review', locationId: { $type: 'string' } },
    });
    for (const index of legacy) {
      if (index.partialFilterExpression?.locationId === undefined) {
        await collection.dropIndex(index.name);
      }
    }
    await collection.createIndex({ workEmail: 1, gymName: 1, locationId: 1 }, {
      name: 'pending_legacy_claim_identity', unique: true,
      partialFilterExpression: { status: 'pending_review' },
    });
  } finally {
    await mongoose.disconnect();
  }
}

main().catch((error) => { console.error(error); process.exitCode = 1; });
