import { Router } from "express";
import pool from "../../lib/db.js";
import { requireAuth, requireGymAccess, errorResponse, type AuthRequest } from "./middleware.js";

const router = Router();

// ─── GET /api/v1/gym/:id ──────────────────────────────────────────────────────
router.get("/:id", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

    const [gymResult, trainersResult, memberCount] = await Promise.all([
      pool.query(
        `SELECT id, name, owner_name, owner_email, owner_phone, brand_color, brand_color_light,
                logo_url, description, licensing_tier, status, created_at, approved_at
         FROM v1_gyms WHERE id = $1`,
        [id]
      ),
      pool.query(
        `SELECT id, name, trainer_type, schedule, schedule_status, bio, avatar_url FROM v1_trainers WHERE gym_id = $1`,
        [id]
      ),
      pool.query(`SELECT COUNT(*) as count FROM v1_users WHERE gym_id = $1`, [id]),
    ]);

    if (!gymResult.rows[0]) return errorResponse(res, 404, "Gym not found", "NOT_FOUND");

    res.json({
      ...gymResult.rows[0],
      trainers: trainersResult.rows,
      memberCount: parseInt(memberCount.rows[0]?.count ?? "0"),
    });
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

// ─── GET /api/v1/gym/:id/dashboard ───────────────────────────────────────────
router.get("/:id/dashboard", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

    const [gym, members, trainers, recentActivity, workoutsToday] = await Promise.all([
      pool.query(`SELECT id, name, status, licensing_tier FROM v1_gyms WHERE id = $1`, [id]),
      pool.query(`SELECT COUNT(*) as total FROM v1_users WHERE gym_id = $1`, [id]),
      pool.query(`SELECT COUNT(*) as total, trainer_type FROM v1_trainers WHERE gym_id = $1 GROUP BY trainer_type`, [id]),
      pool.query(
        `SELECT u.first_name, u.last_name, u.username, u.last_active
         FROM v1_users u WHERE u.gym_id = $1 AND u.last_active > NOW() - INTERVAL '7 days'
         ORDER BY u.last_active DESC LIMIT 10`,
        [id]
      ),
      pool.query(
        `SELECT COUNT(DISTINCT user_id) as count FROM v1_watch_data wd
         JOIN v1_users u ON u.id = wd.user_id
         WHERE u.gym_id = $1 AND wd.date = CURRENT_DATE`,
        [id]
      ),
    ]);

    if (!gym.rows[0]) return errorResponse(res, 404, "Gym not found", "NOT_FOUND");

    const memberTotal = parseInt(members.rows[0]?.total ?? "0");
    const liveTrainers = trainers.rows.find(t => t.trainer_type === "live")?.total ?? 0;
    const aiTrainers = trainers.rows.find(t => t.trainer_type === "ai")?.total ?? 0;
    const activeToday = parseInt(workoutsToday.rows[0]?.count ?? "0");
    const retentionRate = memberTotal > 0 ? ((activeToday / memberTotal) * 100).toFixed(1) + "%" : "0%";

    res.json({
      gym: gym.rows[0],
      kpis: {
        totalMembers: memberTotal,
        liveTrainers: parseInt(String(liveTrainers)),
        aiTrainers: parseInt(String(aiTrainers)),
        activeToday,
        retentionRate,
      },
      recentActivity: recentActivity.rows,
    });
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

// ─── GET /api/v1/gym/:id/members ─────────────────────────────────────────────
router.get("/:id/members", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const page = Math.max(1, parseInt(String(req.query.page || "1")));
    const limit = Math.min(100, parseInt(String(req.query.limit || "20")));
    const offset = (page - 1) * limit;

    const [members, total] = await Promise.all([
      pool.query(
        `SELECT id, username, first_name, last_name, email, current_streak, join_date, last_active
         FROM v1_users WHERE gym_id = $1
         ORDER BY join_date DESC LIMIT $2 OFFSET $3`,
        [id, limit, offset]
      ),
      pool.query(`SELECT COUNT(*) as count FROM v1_users WHERE gym_id = $1`, [id]),
    ]);

    res.json({
      members: members.rows,
      total: parseInt(total.rows[0]?.count ?? "0"),
      page,
      limit,
    });
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

// ─── GET /api/v1/gym/:id/payments ────────────────────────────────────────────
router.get("/:id/payments", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    // Billing dates must come from verified provider records, never join dates.
    return errorResponse(res, 503, "Verified gym billing records are not connected", "BILLING_UNAVAILABLE");
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

// ─── PATCH /api/v1/gym/:id/settings ──────────────────────────────────────────
router.patch("/:id/settings", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { name, brandColor, brandColorLight, description, logoUrl } = req.body;

    const result = await pool.query(
      `UPDATE v1_gyms SET
         name = COALESCE($1, name),
         brand_color = COALESCE($2, brand_color),
         brand_color_light = COALESCE($3, brand_color_light),
         description = COALESCE($4, description),
         logo_url = COALESCE($5, logo_url)
       WHERE id = $6
       RETURNING id, name, brand_color, brand_color_light, description, logo_url`,
      [name || null, brandColor || null, brandColorLight || null, description || null, logoUrl || null, id]
    );

    if (!result.rows[0]) return errorResponse(res, 404, "Gym not found", "NOT_FOUND");
    res.json(result.rows[0]);
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

// ─── POST /api/v1/gym/:id/trainers ───────────────────────────────────────────
router.post("/:id/trainers", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { name, trainerType, schedule, scheduleStatus, bio, avatarUrl } = req.body;
    if (!name) return errorResponse(res, 400, "name is required", "VALIDATION_ERROR");

    const result = await pool.query(
      `INSERT INTO v1_trainers (gym_id, name, trainer_type, schedule, schedule_status, bio, avatar_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [id, name, trainerType || "live", schedule ? JSON.stringify(schedule) : null, scheduleStatus || "available", bio || null, avatarUrl || null]
    );
    res.status(201).json(result.rows[0]);
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

// ─── PATCH /api/v1/gym/:id/trainers/:trainerId ───────────────────────────────
router.patch("/:id/trainers/:trainerId", requireAuth, requireGymAccess, async (req: AuthRequest, res) => {
  try {
    const { trainerId } = req.params;
    const { name, scheduleStatus, schedule, bio, avatarUrl } = req.body;

    const result = await pool.query(
      `UPDATE v1_trainers SET
         name = COALESCE($1, name),
         schedule_status = COALESCE($2, schedule_status),
         schedule = COALESCE($3::jsonb, schedule),
         bio = COALESCE($4, bio),
         avatar_url = COALESCE($5, avatar_url)
       WHERE id = $6 AND gym_id = $7
       RETURNING *`,
      [name || null, scheduleStatus || null, schedule ? JSON.stringify(schedule) : null, bio || null, avatarUrl || null, trainerId, req.params.id]
    );
    if (!result.rows[0]) return errorResponse(res, 404, "Trainer not found", "NOT_FOUND");
    res.json(result.rows[0]);
  } catch (err: any) {
    errorResponse(res, 500, err.message, "SERVER_ERROR");
  }
});

export default router;
