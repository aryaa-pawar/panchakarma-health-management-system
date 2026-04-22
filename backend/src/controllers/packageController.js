import { body } from "express-validator";
import { query, pool } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";

export const packageValidation = [
  body("name").trim().notEmpty(),
  body("durationDays").isInt({ min: 1 }),
  body("totalCost").isFloat({ min: 0 }),
  body("therapyIds").isArray({ min: 1 }),
  validate
];

export const listPackages = asyncHandler(async (req, res) => {
  const packages = await query(
    `SELECT p.*, COUNT(pt.therapy_id) AS therapies_count
     FROM packages p
     LEFT JOIN package_therapies pt ON pt.package_id = p.id
     GROUP BY p.id
     ORDER BY p.name`
  );
  res.json(packages);
});

export const createPackage = asyncHandler(async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const payload = req.body;
    const [packageResult] = await connection.execute(
      `INSERT INTO packages (
        name, package_type, description, duration_days, total_cost, discount_type, discount_value,
        inclusions, expected_outcomes, customization_options, seasonal_offer_note
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        payload.name,
        payload.packageType || "Standard",
        payload.description || null,
        payload.durationDays,
        payload.totalCost,
        payload.discountType || "None",
        payload.discountValue || 0,
        payload.inclusions || null,
        payload.expectedOutcomes || null,
        payload.customizationOptions || null,
        payload.seasonalOfferNote || null
      ]
    );

    for (const therapyId of payload.therapyIds) {
      await connection.execute(
        `INSERT INTO package_therapies (package_id, therapy_id, frequency_per_week)
         VALUES (?, ?, ?)`,
        [packageResult.insertId, therapyId, payload.frequencyPerWeek || 3]
      );
    }

    await connection.commit();
    res.status(201).json({ message: "Package created", id: packageResult.insertId });
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
});
