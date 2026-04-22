import { Router } from "express";
import { createInventoryItem, inventoryValidation, listInventory } from "../controllers/inventoryController.js";
import { authorize, protect } from "../middlewares/authMiddleware.js";

const router = Router();

router.use(protect);
router.get("/", authorize("admin", "therapist"), listInventory);
router.post("/", authorize("admin"), inventoryValidation, createInventoryItem);

export default router;
