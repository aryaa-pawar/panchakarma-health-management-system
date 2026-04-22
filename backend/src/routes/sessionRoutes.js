import { Router } from "express";
import {
  createSession,
  inventoryUsageValidation,
  listSessions,
  logSessionInventoryUsage,
  sessionValidation
} from "../controllers/sessionController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/", authorize("admin", "doctor", "therapist"), listSessions);
router.post("/", authorize("admin", "therapist"), sessionValidation, createSession);
router.post("/inventory-usage", authorize("admin", "therapist"), inventoryUsageValidation, logSessionInventoryUsage);

export default router;
