import { Router } from "express";
import {
  billGenerationValidation,
  generateBill,
  listBills,
  paymentValidation,
  recordPayment
} from "../controllers/billingController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/bills", authorize("admin", "receptionist", "patient"), listBills);
router.post("/bills/generate", authorize("admin", "receptionist"), billGenerationValidation, generateBill);
router.post("/payments", authorize("admin", "receptionist", "patient"), paymentValidation, recordPayment);

export default router;
