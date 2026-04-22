import { Router } from "express";
import { createTherapy, listTherapies, therapyValidation } from "../controllers/therapyController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/", listTherapies);
router.post("/", authorize("admin", "doctor"), therapyValidation, createTherapy);

export default router;
