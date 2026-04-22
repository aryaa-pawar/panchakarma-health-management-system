import { Router } from "express";
import { getClinicReports, getDashboardOverview, getRecentActivity } from "../controllers/reportController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/overview", getDashboardOverview);
router.get("/clinic", authorize("admin", "doctor"), getClinicReports);
router.get("/activity", authorize("admin"), getRecentActivity);

export default router;
