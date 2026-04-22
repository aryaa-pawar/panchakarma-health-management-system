import { Router } from "express";
import {
  login,
  loginValidation,
  me,
  otpValidation,
  register,
  registerValidation,
  requestPasswordReset
} from "../controllers/authController.js";
import { protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.post("/register", registerValidation, register);
router.post("/login", loginValidation, login);
router.post("/password-reset/request", otpValidation, requestPasswordReset);
router.get("/me", protect, me);

export default router;
