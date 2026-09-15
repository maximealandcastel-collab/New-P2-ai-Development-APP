import { Router } from "express";
import bcrypt from "bcryptjs";
import { db, gymOwnerAccountsTable } from "@workspace/db";
import { sql } from "drizzle-orm";
import pool from "../lib/db.js";

import { requireFounder } from "../middleware/founderAuth.js";

const router = Router();

// Auto-create and migrate gym_owner_accounts table
(async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS gym_owner_accounts (
        id SERIAL PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        gym_name TEXT,
        email TEXT,
        stripe_session_id TEXT,
        access_expires_at TIMESTAMPTZ NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
      )
    `);
    // Add approval_status column if it doesn't exist yet
    await pool.query(`
      ALTER TABLE gym_owner_accounts
        ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending'
    `);
    console.log("[GymOwner] gym_owner_accounts table ready (with approval_status)");
  } catch (err: any) {
    console.error("[GymOwner] Table migration error:", err.message);
  }
})();

router.post("/gym-owner/register", async (req, res) => {
  const { username, password, gymName, email } = req.body;
  if (!username || !password)
    return res.status(400).json({ error: "Username and password are required." });
  if (username.trim().length < 3)
    return res.status(400).json({ error: "Username must be at least 3 characters." });
  if (password.length < 6)
    return res.status(400).json({ error: "Password must be at least 6 characters." });

  try {
    const existing = await db
      .select({ id: gymOwnerAccountsTable.id })
      .from(gymOwnerAccountsTable)
      .where(sql`LOWER(${gymOwnerAccountsTable.username}) = LOWER(${username.trim()})`)
      .limit(1);

    if (existing.length > 0)
      return res.status(409).json({ error: "That username is already taken. Choose another." });

    const passwordHash = await bcrypt.hash(password, 10);
    const accessExpiresAt = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000);

    const [account] = await db
      .insert(gymOwnerAccountsTable)
      .values({
        username: username.trim().toLowerCase(),
        passwordHash,
        gymName: gymName?.trim() || null,
        email: email?.trim() || null,
        accessExpiresAt,
        approvalStatus: "pending",
      })
      .returning({
        id: gymOwnerAccountsTable.id,
        username: gymOwnerAccountsTable.username,
        gymName: gymOwnerAccountsTable.gymName,
        email: gymOwnerAccountsTable.email,
        accessExpiresAt: gymOwnerAccountsTable.accessExpiresAt,
        approvalStatus: gymOwnerAccountsTable.approvalStatus,
      });

    res.json({
      ok: true,
      account: {
        ...account,
        accessExpiresAt: account.accessExpiresAt.toISOString(),
        approvalStatus: account.approvalStatus,
      },
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/gym-owner/login", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ error: "Username and password are required." });

  try {
    const [account] = await db
      .select()
      .from(gymOwnerAccountsTable)
      .where(sql`LOWER(${gymOwnerAccountsTable.username}) = LOWER(${username.trim()})`)
      .limit(1);

    if (!account) return res.status(401).json({ error: "Invalid credentials." });

    const valid = await bcrypt.compare(password, account.passwordHash);
    if (!valid) return res.status(401).json({ error: "Invalid credentials." });

    const approvalStatus = account.approvalStatus ?? "pending";

    if (approvalStatus === "pending") {
      return res.status(403).json({
        error: "Your application is pending review. You'll receive access once approved by the P2P team.",
        approvalStatus: "pending",
      });
    }

    if (approvalStatus === "rejected") {
      return res.status(403).json({
        error: "Your application was not approved. Please contact support@p2pfittech.com for more information.",
        approvalStatus: "rejected",
      });
    }

    const expired = new Date() >= account.accessExpiresAt;
    if (approvalStatus !== "approved" || expired) return res.status(403).json({ error: "Gym access is not active" });

    res.json({
      ok: true,
      account: {
        id: account.id,
        username: account.username,
        gymName: account.gymName,
        email: account.email,
        accessExpiresAt: account.accessExpiresAt.toISOString(),
        approvalStatus,
        expired,
      },
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/gym-owner/approve/:id", requireFounder, async (req, res) => {
  try {
    const { id } = req.params;
    await db
      .update(gymOwnerAccountsTable)
      .set({ approvalStatus: "approved" })
      .where(sql`${gymOwnerAccountsTable.id} = ${parseInt(id)}`);
    res.json({ ok: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/gym-owner/reject/:id", requireFounder, async (req, res) => {
  try {
    const { id } = req.params;
    await db
      .update(gymOwnerAccountsTable)
      .set({ approvalStatus: "rejected" })
      .where(sql`${gymOwnerAccountsTable.id} = ${parseInt(id)}`);
    res.json({ ok: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/gym-owner/revoke/:id", requireFounder, async (req, res) => {
  try {
    const { id } = req.params;
    await db
      .update(gymOwnerAccountsTable)
      .set({ accessExpiresAt: new Date(Date.now() - 1000) })
      .where(sql`${gymOwnerAccountsTable.id} = ${parseInt(id)}`);
    res.json({ ok: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/gym-owner/stats", requireFounder, async (_req, res) => {
  try {
    const now = new Date();
    const [totalRows, activeRows, pendingRows, recentRows, pendingListRows] = await Promise.all([
      db.select({ count: sql<string>`count(*)` }).from(gymOwnerAccountsTable),
      db.select({ count: sql<string>`count(*)` })
        .from(gymOwnerAccountsTable)
        .where(sql`${gymOwnerAccountsTable.accessExpiresAt} > ${now} AND ${gymOwnerAccountsTable.approvalStatus} = 'approved'`),
      db.select({ count: sql<string>`count(*)` })
        .from(gymOwnerAccountsTable)
        .where(sql`${gymOwnerAccountsTable.approvalStatus} = 'pending'`),
      db.select({
        id: gymOwnerAccountsTable.id,
        username: gymOwnerAccountsTable.username,
        gymName: gymOwnerAccountsTable.gymName,
        email: gymOwnerAccountsTable.email,
        accessExpiresAt: gymOwnerAccountsTable.accessExpiresAt,
        approvalStatus: gymOwnerAccountsTable.approvalStatus,
        createdAt: gymOwnerAccountsTable.createdAt,
      }).from(gymOwnerAccountsTable)
        .where(sql`${gymOwnerAccountsTable.approvalStatus} = 'approved'`)
        .orderBy(sql`created_at DESC`)
        .limit(10),
      db.select({
        id: gymOwnerAccountsTable.id,
        username: gymOwnerAccountsTable.username,
        gymName: gymOwnerAccountsTable.gymName,
        email: gymOwnerAccountsTable.email,
        approvalStatus: gymOwnerAccountsTable.approvalStatus,
        createdAt: gymOwnerAccountsTable.createdAt,
      }).from(gymOwnerAccountsTable)
        .where(sql`${gymOwnerAccountsTable.approvalStatus} = 'pending'`)
        .orderBy(sql`created_at DESC`),
    ]);

    res.json({
      total: parseInt(totalRows[0]?.count ?? "0"),
      active: parseInt(activeRows[0]?.count ?? "0"),
      pending: parseInt(pendingRows[0]?.count ?? "0"),
      recent: recentRows.map(r => ({
        ...r,
        accessExpiresAt: r.accessExpiresAt?.toISOString(),
        createdAt: (r.createdAt as any)?.toISOString?.() ?? null,
      })),
      pendingList: pendingListRows.map(r => ({
        ...r,
        createdAt: (r.createdAt as any)?.toISOString?.() ?? null,
      })),
    });
  } catch (err: any) {
    console.error("gym owner stats error:", err?.message || err);
    // Stats are a non-critical Founder dashboard panel. Return the same
    // shape on a cold start or transient database failure so one panel cannot
    // prevent the rest of the dashboard from rendering.
    res.status(503).json({ error: "Gym statistics are temporarily unavailable" });
  }
});

export default router;
