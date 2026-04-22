import { Router } from "express";
import {
  appointmentValidation,
  createAppointment,
  deleteAppointment,
  listAppointments,
  updateAppointmentStatus,
  updateAppointmentStatusValidation
} from "../controllers/appointmentController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/", authorize("admin", "doctor", "therapist", "receptionist", "patient"), listAppointments);
router.post("/", authorize("admin", "doctor", "receptionist"), appointmentValidation, createAppointment);
router.patch("/:id/status", authorize("admin", "doctor", "receptionist"), updateAppointmentStatusValidation, updateAppointmentStatus);
router.delete("/:id", authorize("admin", "doctor", "receptionist"), deleteAppointment);

export default router;
