import type { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// Uses the same dedicated Founder Console identity as /api/admin/login.
export function requireFounder(req: Request, res: Response, next: NextFunction) {
  const secret = process.env.JWT_SECRET || process.env.SESSION_SECRET;
  if (!secret) return res.status(503).json({ error: "Founder authentication is unavailable" });
  const token = req.headers.authorization;
  if (!token?.startsWith("Bearer ")) return res.status(401).json({ error: "Unauthorized" });
  try {
    const identity = jwt.verify(token.slice(7), secret, { algorithms: ["HS256"] }) as any;
    if (identity.admin !== true || identity.user !== (process.env.CU_ADMIN_USERNAME || "FounderP2")) {
      return res.status(403).json({ error: "Founder access required" });
    }
    return next();
  } catch { return res.status(401).json({ error: "Invalid or expired token" }); }
}
