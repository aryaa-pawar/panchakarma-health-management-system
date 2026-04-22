import { Router } from "express";
import {
  createTreatmentPlan,
  listTreatmentPlans,
  treatmentPlanValidation,
  updateTreatmentPlan
} from "../controllers/doctorController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect, authorize("admin", "doctor"));
router.get("/treatment-plans", listTreatmentPlans);
router.post("/treatment-plans", treatmentPlanValidation, createTreatmentPlan);
router.put("/treatment-plans/:id", treatmentPlanValidation, updateTreatmentPlan);

export default router;
