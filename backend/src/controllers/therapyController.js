import { body } from "express-validator";
import { query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";

export const therapyValidation = [
  body("name").trim().notEmpty(),
  body("category").trim().notEmpty(),
  body("durationMinutes").isInt({ min: 10 }),
  body("costPerSession").isFloat({ min: 0 }),
  validate
];

export const listTherapies = asyncHandler(async (req, res) => {
  const rows = await query("SELECT * FROM therapies ORDER BY category, name");
  res.json(rows);
});

export const createTherapy = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await query(
    `INSERT INTO therapies (
      name, category, duration_minutes, cost_per_session, required_items_json,
      precautions, contraindications, benefits, indications, skill_level_required
    ) VALUES (
      :name, :category, :durationMinutes, :costPerSession, :requiredItemsJson,
      :precautions, :contraindications, :benefits, :indications, :skillLevelRequired
    )`,
    {
      name: payload.name,
      category: payload.category,
      durationMinutes: payload.durationMinutes,
      costPerSession: payload.costPerSession,
      requiredItemsJson: JSON.stringify(payload.requiredItems || []),
      precautions: payload.precautions || null,
      contraindications: payload.contraindications || null,
      benefits: payload.benefits || null,
      indications: payload.indications || null,
      skillLevelRequired: payload.skillLevelRequired || "Intermediate"
    }
  );

  res.status(201).json({ message: "Therapy created", id: result.insertId });
});
