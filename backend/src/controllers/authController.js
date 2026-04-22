import bcrypt from "bcryptjs";
import { body } from "express-validator";
import { query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { ApiError } from "../utils/ApiError.js";
import { createAuditLog } from "../services/auditService.js";
import { createToken, loginUser } from "../services/authService.js";

export const registerValidation = [
  body("fullName").trim().notEmpty(),
  body("email").isEmail(),
  body("password").isLength({ min: 8 }),
  body("role").isIn(["patient", "receptionist", "therapist", "doctor", "admin"]),
  validate
];

export const loginValidation = [
  body("email").isEmail(),
  body("password").notEmpty(),
  validate
];

export const otpValidation = [
  body("email").isEmail(),
  validate
];

export const register = asyncHandler(async (req, res) => {
  const { fullName, email, password, role } = req.body;
  const existing = await query("SELECT id FROM users WHERE email = :email", { email });
  if (existing.length) {
    throw new ApiError(409, "Email already registered");
  }

  const roles = await query("SELECT id FROM roles WHERE name = :role", { role });
  if (!roles.length) {
    throw new ApiError(400, "Invalid role");
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const result = await query(
    `INSERT INTO users (role_id, full_name, email, password_hash, email_verified_at)
     VALUES (:roleId, :fullName, :email, :passwordHash, NOW())`,
    {
      roleId: roles[0].id,
      fullName,
      email,
      passwordHash
    }
  );

  const token = await createToken(result.insertId);
  await createAuditLog({
    userId: result.insertId,
    action: "USER_REGISTERED",
    entityType: "user",
    entityId: result.insertId,
    ipAddress: req.ip
  });

  res.status(201).json({
    message: "Registration successful",
    token
  });
});

export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const { user, token } = await loginUser(email, password);

  await query(
    `INSERT INTO login_history (user_id, ip_address, user_agent, logged_in_at)
     VALUES (:userId, :ipAddress, :userAgent, NOW())`,
    {
      userId: user.id,
      ipAddress: req.ip,
      userAgent: req.headers["user-agent"] || null
    }
  );

  await createAuditLog({
    userId: user.id,
    action: "USER_LOGIN",
    entityType: "session",
    metadata: { email },
    ipAddress: req.ip
  });

  res.json({ token, user });
});

export const me = asyncHandler(async (req, res) => {
  const [profile] = await query(
    `SELECT u.id, u.full_name, u.email, r.name AS role, u.phone, u.avatar_url
     FROM users u
     JOIN roles r ON r.id = u.role_id
     WHERE u.id = :id`,
    { id: req.user.id }
  );

  res.json(profile);
});

export const requestPasswordReset = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const users = await query("SELECT id FROM users WHERE email = :email", { email });
  if (!users.length) {
    throw new ApiError(404, "User not found");
  }

  const otp = `${Math.floor(100000 + Math.random() * 900000)}`;
  await query(
    `INSERT INTO password_reset_otps (user_id, otp_code, expires_at)
     VALUES (:userId, :otp, DATE_ADD(NOW(), INTERVAL 10 MINUTE))`,
    { userId: users[0].id, otp }
  );

  await createAuditLog({
    userId: users[0].id,
    action: "PASSWORD_RESET_REQUESTED",
    entityType: "user",
    entityId: users[0].id,
    ipAddress: req.ip
  });

  res.json({
    message: "Password reset OTP generated",
    demoOtp: otp
  });
});
