import { body } from "express-validator";
import { query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { createAuditLog } from "../services/auditService.js";

export const treatmentPlanValidation = [
  body("patientId").isInt(),
  body("doctorId").isInt(),
  body("diagnosis").trim().notEmpty(),
  body("status").optional().isIn(["Draft", "Active", "Completed", "Cancelled"]),
  validate
];

export const listTreatmentPlans = asyncHandler(async (req, res) => {
  const rows = await query(
    `SELECT tp.id, tp.diagnosis, tp.status, tp.start_date, tp.end_date,
            CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
            u.full_name AS doctor_name, pkg.name AS package_name
     FROM treatment_plans tp
     JOIN patients p ON p.id = tp.patient_id
     JOIN doctors d ON d.id = tp.doctor_id
     JOIN users u ON u.id = d.user_id
     LEFT JOIN packages pkg ON pkg.id = tp.package_id
     ORDER BY tp.created_at DESC`
  );
  res.json(rows);
});

export const createTreatmentPlan = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await query(
    `INSERT INTO treatment_plans (
      patient_id, doctor_id, package_id, diagnosis, condition_details, recommended_therapies,
      treatment_duration_weeks, precautions, contraindications, expected_outcomes,
      success_metrics, status, start_date, end_date
    ) VALUES (
      :patientId, :doctorId, :packageId, :diagnosis, :conditionDetails, :recommendedTherapies,
      :treatmentDurationWeeks, :precautions, :contraindications, :expectedOutcomes,
      :successMetrics, :status, :startDate, :endDate
    )`,
    {
      patientId: payload.patientId,
      doctorId: payload.doctorId,
      packageId: payload.packageId || null,
      diagnosis: payload.diagnosis,
      conditionDetails: payload.conditionDetails || null,
      recommendedTherapies: JSON.stringify(payload.recommendedTherapies || []),
      treatmentDurationWeeks: payload.treatmentDurationWeeks || null,
      precautions: payload.precautions || null,
      contraindications: payload.contraindications || null,
      expectedOutcomes: payload.expectedOutcomes || null,
      successMetrics: payload.successMetrics || null,
      status: payload.status || "Draft",
      startDate: payload.startDate || null,
      endDate: payload.endDate || null
    }
  );

  await createAuditLog({
    userId: req.user.id,
    action: "TREATMENT_PLAN_CREATED",
    entityType: "treatment_plan",
    entityId: result.insertId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.status(201).json({ message: "Treatment plan created", id: result.insertId });
});

export const updateTreatmentPlan = asyncHandler(async (req, res) => {
  const treatmentPlanId = Number(req.params.id);
  const payload = req.body;

  await query(
    `UPDATE treatment_plans
     SET package_id = :packageId,
         diagnosis = :diagnosis,
         condition_details = :conditionDetails,
         recommended_therapies = :recommendedTherapies,
         treatment_duration_weeks = :treatmentDurationWeeks,
         precautions = :precautions,
         contraindications = :contraindications,
         expected_outcomes = :expectedOutcomes,
         success_metrics = :successMetrics,
         status = :status,
         start_date = :startDate,
         end_date = :endDate
     WHERE id = :treatmentPlanId`,
    {
      treatmentPlanId,
      packageId: payload.packageId || null,
      diagnosis: payload.diagnosis,
      conditionDetails: payload.conditionDetails || null,
      recommendedTherapies: JSON.stringify(payload.recommendedTherapies || []),
      treatmentDurationWeeks: payload.treatmentDurationWeeks || null,
      precautions: payload.precautions || null,
      contraindications: payload.contraindications || null,
      expectedOutcomes: payload.expectedOutcomes || null,
      successMetrics: payload.successMetrics || null,
      status: payload.status || "Draft",
      startDate: payload.startDate || null,
      endDate: payload.endDate || null
    }
  );

  await createAuditLog({
    userId: req.user.id,
    action: "TREATMENT_PLAN_UPDATED",
    entityType: "treatment_plan",
    entityId: treatmentPlanId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.json({ message: "Treatment plan updated", id: treatmentPlanId });
});
