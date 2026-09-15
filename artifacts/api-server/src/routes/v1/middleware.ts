import pool from "../../lib/db.js";
import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

export const JWT_SECRET = process.env["JWT_SECRET"] || "";
export const ADMIN_API_KEY = process.env["ADMIN_API_KEY"] || "";

export interface AuthRequest extends Request {
  userId?: string;
  userType?: string;
}

export async function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  const auth = req.headers["authorization"];
  if (!auth?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Unauthorized — missing token", code: "UNAUTHORIZED", statusCode: 401 });
    return;
  }
  if (!JWT_SECRET) return errorResponse(res, 503, "Authentication unavailable", "UNAVAILABLE");
  try {
    const payload = jwt.verify(auth.slice(7), JWT_SECRET, { algorithms: ["HS256"] }) as any;
    if (typeof payload.userId !== "string" || typeof payload.accountType !== "string") {
      return errorResponse(res, 401, "Invalid session identity", "UNAUTHORIZED");
    }
    const current = await pool.query("SELECT account_type FROM v1_users WHERE id = $1", [payload.userId]);
    if (!current.rows[0] || current.rows[0].account_type !== payload.accountType) {
      return errorResponse(res, 401, "Account access has changed", "UNAUTHORIZED");
    }
    req.userId = payload.userId;
    req.userType = payload.accountType;
    next();
  } catch {
    res.status(401).json({ error: "Invalid or expired token", code: "UNAUTHORIZED", statusCode: 401 });
  }
}

export function requireAdminKey(req: Request, res: Response, next: NextFunction) {
  const key = req.headers["x-admin-key"];
  if (!ADMIN_API_KEY || !key || key !== ADMIN_API_KEY) {
    res.status(401).json({ error: "Invalid admin key", code: "UNAUTHORIZED", statusCode: 401 });
    return;
  }
  next();
}

export function generateToken(userId: string, accountType: string): string {
  if (!JWT_SECRET) throw new Error("JWT_SECRET must be configured");
  return jwt.sign({ userId, accountType }, JWT_SECRET, { expiresIn: "30d" });
}

export function errorResponse(res: Response, status: number, message: string, code: string) {
  return res.status(status).json({ error: message, code, statusCode: status });
}

// Resolve current membership for every gym operation, never a client gym ID alone.
export async function requireGymAccess(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const result = await pool.query(
      `SELECT u.account_type FROM v1_users u JOIN v1_gyms g ON g.id = u.gym_id
       WHERE u.id = $1 AND u.gym_id = $2 AND g.status = 'approved'`,
      [req.userId, req.params.id],
    );
    const type = result.rows[0]?.account_type;
    const management = req.method !== "GET" || /\/(members|payments|dashboard)$/.test(req.path);
    if (!type || (management && !["gym_owner", "gym_admin"].includes(type))) {
      return errorResponse(res, 403, "Gym access denied", "FORBIDDEN");
    }
    return next();
  } catch { return errorResponse(res, 503, "Gym authorization unavailable", "UNAVAILABLE"); }
}
