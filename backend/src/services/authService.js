import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { query } from "../config/db.js";
import { env } from "../config/env.js";
import { ApiError } from "../utils/ApiError.js";

export async function createToken(userId) {
  return jwt.sign({ id: userId }, env.jwtSecret, { expiresIn: env.jwtExpiresIn });
}

export async function loginUser(email, password) {
  const users = await query(
    `SELECT u.id, u.email, u.password_hash, u.full_name, u.role_id, r.name AS role
     FROM users u
     JOIN roles r ON r.id = u.role_id
     WHERE u.email = :email AND u.is_active = 1`,
    { email }
  );

  if (!users.length) {
    throw new ApiError(401, "Invalid email or password");
  }

  const user = users[0];
  const isMatch = await bcrypt.compare(password, user.password_hash);

  if (!isMatch) {
    throw new ApiError(401, "Invalid email or password");
  }

  const token = await createToken(user.id);
  delete user.password_hash;

  return { user, token };
}
