import { body } from "express-validator";
import { callProcedure, pool, query, queryWithAudit, withAuditContext } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { createAuditLog } from "../services/auditService.js";

export const appointmentValidation = [
  body("patientId").isInt(),
  body("treatmentPlanId").optional({ values: "falsy" }).isInt(),
  body("therapyId").optional({ values: "falsy" }).isInt(),
  body("therapistId").optional({ values: "falsy" }).isInt(),
  body("appointmentDate").isISO8601(),
  body("visitType").optional({ values: "falsy" }).trim().isLength({ min: 3, max: 100 }),
  body("bufferMinutes").optional({ values: "falsy" }).isInt({ min: 0, max: 60 }),
  body("status").optional().isIn(["Scheduled", "Completed", "Cancelled", "No-show", "In Progress"]),
  validate
];

export const listAppointments = asyncHandler(async (req, res) => {
  const rows =
    req.user.role === "patient"
      ? await query(
          `SELECT v.*
           FROM vw_appointment_calendar v
           JOIN appointments a ON a.id = v.id
           JOIN patients p ON p.id = a.patient_id
           WHERE p.user_id = :userId
           ORDER BY v.appointment_date ASC`,
          { userId: req.user.id }
        )
      : await query(
          `SELECT *
           FROM vw_appointment_calendar
           ORDER BY appointment_date ASC`
        );
  res.json(rows);
});

export const createAppointment = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await callProcedure(
    "sp_book_appointment",
    [
      payload.patientId,
      payload.treatmentPlanId || null,
      payload.therapyId || null,
      payload.therapistId || null,
      payload.appointmentDate,
      payload.visitType || "Consultation",
      payload.notes || null,
      payload.bufferMinutes || 15
    ],
    req.user.id
  );

  const appointmentId = result[0]?.appointment_id;

  await createAuditLog({
    userId: req.user.id,
    action: "APPOINTMENT_CREATED",
    entityType: "appointment",
    entityId: appointmentId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.status(201).json({ message: "Appointment booked", id: appointmentId });
});

export const updateAppointmentStatusValidation = [
  body("status").isIn(["Scheduled", "Completed", "Cancelled", "No-show", "In Progress"]),
  validate
];

export const updateAppointmentStatus = asyncHandler(async (req, res) => {
  const appointmentId = Number(req.params.id);
  const { status } = req.body;
  const [appointment] = await query(
    `SELECT a.id, a.status, ts.id AS therapy_session_id, b.id AS bill_id
     FROM appointments a
     LEFT JOIN therapy_sessions ts ON ts.appointment_id = a.id
     LEFT JOIN bills b ON b.appointment_id = a.id
     WHERE a.id = :id`,
    { id: appointmentId }
  );

  if (!appointment) {
    return res.status(404).json({ message: "Appointment not found" });
  }

  if (appointment.status === status) {
    return res.json({ message: "Appointment already has this status", id: appointmentId, status });
  }

  if (appointment.status === "Completed" && status !== "Completed") {
    return res.status(400).json({ message: "Completed appointments cannot be changed" });
  }

  if ((appointment.therapy_session_id || appointment.bill_id) && status === "Cancelled") {
    return res.status(400).json({ message: "Appointments with recorded sessions cannot be cancelled" });
  }

  const result = await queryWithAudit(
    "UPDATE appointments SET status = ? WHERE id = ?",
    [status, appointmentId],
    req.user.id
  );

  if (!result.affectedRows) {
    return res.status(400).json({ message: "Appointment status could not be updated" });
  }

  await createAuditLog({
    userId: req.user.id,
    action: "APPOINTMENT_STATUS_UPDATED",
    entityType: "appointment",
    entityId: appointmentId,
    metadata: { status },
    ipAddress: req.ip
  });

  res.json({ message: "Appointment status updated", id: appointmentId, status });
});

export const deleteAppointment = asyncHandler(async (req, res) => {
  const appointmentId = Number(req.params.id);
  const forceDelete = req.query.force === "true";
  const [appointment] = await query(
    `SELECT a.status,
            ts.id AS therapy_session_id,
            b.id AS bill_id
     FROM appointments a
     LEFT JOIN therapy_sessions ts ON ts.appointment_id = a.id
     LEFT JOIN bills b ON b.appointment_id = a.id
     WHERE a.id = :id`,
    { id: appointmentId }
  );

  if (!appointment) {
    return res.status(404).json({ message: "Appointment not found" });
  }

  if (forceDelete && req.user.role !== "admin") {
    return res.status(403).json({ message: "Only admin can force delete locked appointments" });
  }

  if (forceDelete) {
    await withAuditContext(req.user.id, async (connection) => {
      await connection.beginTransaction();
      try {
        await connection.query(
          `DELETE f
           FROM feedback f
           JOIN therapy_sessions ts ON ts.id = f.therapy_session_id
           WHERE ts.appointment_id = ?`,
          [appointmentId]
        );

        await connection.query(
          `DELETE siu
           FROM session_inventory_usage siu
           JOIN therapy_sessions ts ON ts.id = siu.therapy_session_id
           WHERE ts.appointment_id = ?`,
          [appointmentId]
        );

        await connection.query(
          `DELETE p
           FROM payments p
           JOIN bills b ON b.id = p.bill_id
           WHERE b.appointment_id = ?`,
          [appointmentId]
        );

        await connection.query("DELETE FROM bills WHERE appointment_id = ?", [appointmentId]);
        await connection.query("DELETE FROM therapy_sessions WHERE appointment_id = ?", [appointmentId]);
        const [result] = await connection.query("DELETE FROM appointments WHERE id = ?", [appointmentId]);

        if (!result.affectedRows) {
          throw new Error("Appointment could not be deleted");
        }

        await connection.commit();
      } catch (error) {
        await connection.rollback();
        throw error;
      }
    });

    await createAuditLog({
      userId: req.user.id,
      action: "APPOINTMENT_FORCE_DELETED",
      entityType: "appointment",
      entityId: appointmentId,
      metadata: { forceDelete: true },
      ipAddress: req.ip
    });

    return res.json({ message: "Locked appointment and linked records deleted", id: appointmentId });
  }

  if (appointment.status === "Completed") {
    return res.status(400).json({ message: "Completed appointments cannot be deleted" });
  }

  if (appointment.therapy_session_id || appointment.bill_id) {
    return res.status(400).json({ message: "Appointments linked to sessions or bills cannot be deleted" });
  }

  const result = await queryWithAudit("DELETE FROM appointments WHERE id = ?", [appointmentId], req.user.id);

  if (!result.affectedRows) {
    return res.status(400).json({ message: "Appointment could not be deleted" });
  }

  await createAuditLog({
    userId: req.user.id,
    action: "APPOINTMENT_DELETED",
    entityType: "appointment",
    entityId: appointmentId,
    ipAddress: req.ip
  });

  res.json({ message: "Appointment deleted", id: appointmentId });
});
