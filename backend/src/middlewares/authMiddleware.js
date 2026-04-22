import jwt from "jsonwebtoken";
import { env } from "../config/env.js";
import { query } from "../config/db.js";
import { ApiError } from "../utils/ApiError.js";

export async function protect(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    return next(new ApiError(401, "Authentication required"));
  }

  try {
    const token = authHeader.split(" ")[1];
    const payload = jwt.verify(token, env.jwtSecret);
    const users = await query(
      `SELECT u.id, u.email, u.full_name, u.role_id, r.name AS role
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.id = :id AND u.is_active = 1`,
      { id: payload.id }
    );

    if (!users.length) {
      throw new ApiError(401, "Invalid token");
    }

    req.user = users[0];
    next();
  } catch (error) {
    next(new ApiError(401, "Invalid or expired token"));
  }
}

export function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new ApiError(403, "You do not have permission to perform this action"));
    }
    next();
  };
}
