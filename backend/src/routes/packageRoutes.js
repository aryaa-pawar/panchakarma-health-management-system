import { Router } from "express";
import { createPackage, listPackages, packageValidation } from "../controllers/packageController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/", listPackages);
router.post("/", authorize("admin", "doctor"), packageValidation, createPackage);

export default router;
