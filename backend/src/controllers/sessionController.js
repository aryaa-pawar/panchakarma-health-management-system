import { body } from "express-validator";
import { callProcedure, query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { createAuditLog } from "../services/auditService.js";

export const sessionValidation = [
  body("appointmentId").isInt(),
  body("status").optional().isIn(["Scheduled", "In Progress", "Completed"]),
  body("sessionDate").optional({ values: "falsy" }).isISO8601(),
  body("patientComfortRating").optional({ values: "falsy" }).isInt({ min: 1, max: 5 }),
  validate
];

export const listSessions = asyncHandler(async (req, res) => {
  const rows = await query(
    `SELECT ts.id, ts.session_date, ts.status, ts.patient_comfort_rating, ts.therapist_notes,
            CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
            t.name AS therapy_name
     FROM therapy_sessions ts
     JOIN appointments a ON a.id = ts.appointment_id
     JOIN patients p ON p.id = a.patient_id
     LEFT JOIN therapies t ON t.id = a.therapy_id
     ORDER BY ts.session_date DESC`
  );
  res.json(rows);
});

export const createSession = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await callProcedure(
    "sp_complete_therapy_session",
    [
      payload.appointmentId,
      payload.sessionDate || new Date(),
      payload.observations || null,
      payload.patientComfortRating || null,
      payload.therapistNotes || null,
      payload.recommendations || null
    ],
    req.user.id
  );

  const sessionId = result[0]?.therapy_session_id;

  await createAuditLog({
    userId: req.user.id,
    action: "THERAPY_SESSION_COMPLETED",
    entityType: "therapy_session",
    entityId: sessionId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.status(201).json({ message: "Session recorded", id: sessionId });
});

export const inventoryUsageValidation = [
  body("therapySessionId").isInt(),
  body("inventoryItemId").isInt(),
  body("quantityUsed").isFloat({ gt: 0 }),
  validate
];

export const logSessionInventoryUsage = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await callProcedure(
    "sp_log_session_inventory_usage",
    [payload.therapySessionId, payload.inventoryItemId, payload.quantityUsed],
    req.user.id
  );

  await createAuditLog({
    userId: req.user.id,
    action: "SESSION_INVENTORY_USAGE_LOGGED",
    entityType: "therapy_session",
    entityId: payload.therapySessionId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.status(201).json({
    message: "Inventory usage logged",
    remainingStock: result[0]?.remaining_stock ?? null
  });
});
