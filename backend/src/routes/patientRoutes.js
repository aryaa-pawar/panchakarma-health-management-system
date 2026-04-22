import { Router } from "express";
import {
  createPatient,
  getPatient,
  getPatientPortalSummary,
  listPatients,
  patientValidation,
  updatePatient
} from "../controllers/patientController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/portal/me", authorize("patient"), getPatientPortalSummary);
router.get("/", authorize("admin", "doctor", "receptionist", "therapist"), listPatients);
router.get("/:id", authorize("admin", "doctor", "receptionist", "therapist", "patient"), getPatient);
router.post("/", authorize("admin", "receptionist"), patientValidation, createPatient);
router.put("/:id", authorize("admin", "receptionist"), patientValidation, updatePatient);

export default router;
