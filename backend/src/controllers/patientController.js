import { body } from "express-validator";
import { callProcedure, query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { createAuditLog } from "../services/auditService.js";

export const patientValidation = [
  body("firstName").trim().matches(/^[A-Za-z\s]+$/).isLength({ min: 2, max: 100 }),
  body("lastName").trim().matches(/^[A-Za-z\s]+$/).isLength({ min: 1, max: 100 }),
  body("dateOfBirth").optional({ values: "falsy" }).isISO8601().toDate(),
  body("gender").isIn(["Male", "Female", "Other"]),
  body("email").optional({ values: "falsy" }).trim().normalizeEmail().isEmail(),
  body("primaryPhone").optional({ values: "falsy" }).matches(/^\d{10}$/),
  body("emergencyContactPhone").optional({ values: "falsy" }).matches(/^\d{10}$/),
  body("city").optional({ values: "falsy" }).trim().matches(/^[A-Za-z\s]+$/).isLength({ min: 2, max: 100 }),
  body("state").optional({ values: "falsy" }).trim().matches(/^[A-Za-z\s]+$/).isLength({ min: 2, max: 100 }),
  body("constitutionType").optional().isIn(["Vata", "Pitta", "Kapha", "Vata-Pitta", "Pitta-Kapha", "Vata-Kapha", "Tri-dosha"]),
  body("segment").optional({ values: "falsy" }).isIn(["New", "Recurring", "VIP"]),
  body("lifecycleStage").optional({ values: "falsy" }).isIn(["Intake", "Treatment", "Follow-up", "Discharged"]),
  validate
];

export const listPatients = asyncHandler(async (req, res) => {
  const rows = await query(
    `SELECT id, patient_code, patient_name AS full_name, age, gender, constitution_type,
            lifecycle_stage, segment, primary_phone, city, state
     FROM vw_patient_master_summary
     ORDER BY id DESC`
  );
  res.json(rows);
});

export const getPatient = asyncHandler(async (req, res) => {
  let patientId = Number(req.params.id);
  if (req.user.role === "patient") {
    const [linkedPatient] = await query("SELECT id FROM patients WHERE user_id = :userId", {
      userId: req.user.id
    });

    patientId = linkedPatient?.id;
  }

  const [patient] = await query(
    `SELECT *
     FROM patients
     WHERE id = :id`,
    { id: patientId }
  );

  const treatmentTimeline = await callProcedure("sp_patient_treatment_history", [patientId], req.user.id);

  const appointments = await query(
    `SELECT a.id, a.appointment_date, a.status, a.visit_type, t.name AS therapy_name
     FROM appointments a
     LEFT JOIN therapies t ON t.id = a.therapy_id
     WHERE a.patient_id = :id
     ORDER BY a.appointment_date DESC
     LIMIT 10`,
    { id: patientId }
  );

  res.json({ patient, treatmentTimeline, appointments });
});

export const createPatient = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await callProcedure(
    "sp_register_patient",
    [
      payload.firstName,
      payload.lastName,
      payload.dateOfBirth || null,
      payload.gender,
      payload.email || null,
      payload.primaryPhone || null,
      payload.emergencyContactName || null,
      payload.emergencyContactPhone || null,
      payload.addressLine1 || null,
      payload.city || null,
      payload.state || null,
      payload.constitutionType || null,
      payload.allergies || null,
      payload.currentMedications || null,
      payload.medicalHistory || null,
      payload.segment || "New",
      payload.lifecycleStage || "Intake",
      payload.referralSource || null
    ],
    req.user.id
  );

  const patientId = result[0]?.patient_id;

  await createAuditLog({
    userId: req.user.id,
    action: "PATIENT_CREATED",
    entityType: "patient",
    entityId: patientId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.status(201).json({ message: "Patient created", id: patientId });
});

export const updatePatient = asyncHandler(async (req, res) => {
  const patientId = Number(req.params.id);
  const payload = req.body;

  await query(
    `UPDATE patients
     SET first_name = :firstName,
         last_name = :lastName,
         date_of_birth = :dateOfBirth,
         gender = :gender,
         email = :email,
         primary_phone = :primaryPhone,
         city = :city,
         state = :state,
         constitution_type = :constitutionType,
         allergies = :allergies,
         current_medications = :currentMedications,
         medical_history = :medicalHistory,
         segment = :segment,
         lifecycle_stage = :lifecycleStage,
         referral_source = :referralSource
     WHERE id = :patientId`,
    {
      patientId,
      firstName: payload.firstName,
      lastName: payload.lastName,
      dateOfBirth: payload.dateOfBirth || null,
      gender: payload.gender,
      email: payload.email || null,
      primaryPhone: payload.primaryPhone || null,
      city: payload.city || null,
      state: payload.state || null,
      constitutionType: payload.constitutionType || null,
      allergies: payload.allergies || null,
      currentMedications: payload.currentMedications || null,
      medicalHistory: payload.medicalHistory || null,
      segment: payload.segment || "New",
      lifecycleStage: payload.lifecycleStage || "Intake",
      referralSource: payload.referralSource || null
    }
  );

  await createAuditLog({
    userId: req.user.id,
    action: "PATIENT_UPDATED",
    entityType: "patient",
    entityId: patientId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.json({ message: "Patient updated", id: patientId });
});

export const getPatientPortalSummary = asyncHandler(async (req, res) => {
  const [linkedPatient] = await query(
    `SELECT id, patient_code, first_name, last_name, constitution_type, lifecycle_stage
     FROM patients
     WHERE user_id = :userId`,
    { userId: req.user.id }
  );

  if (!linkedPatient) {
    return res.status(404).json({ message: "Patient profile not linked to this account" });
  }

  const treatmentTimeline = await callProcedure("sp_patient_treatment_history", [linkedPatient.id], req.user.id);

  const appointments = await query(
    `SELECT a.id, a.appointment_date, a.status, a.visit_type, t.name AS therapy_name
     FROM appointments a
     LEFT JOIN therapies t ON t.id = a.therapy_id
     WHERE a.patient_id = :patientId
     ORDER BY a.appointment_date ASC`,
    { patientId: linkedPatient.id }
  );

  const bills = await query(
    `SELECT *
     FROM vw_billing_summary
     WHERE patient_id = :patientId
     ORDER BY bill_date DESC`,
    { patientId: linkedPatient.id }
  );

  const stats = {
    upcomingAppointments: appointments.filter((item) => ["Scheduled", "In Progress"].includes(item.status)).length,
    activeTreatments: treatmentTimeline.filter((item) => item.treatment_status === "Active").length,
    pendingBills: bills.filter((item) => item.status !== "Paid").length,
    completedSessions: treatmentTimeline.filter((item) => item.session_status === "Completed").length
  };

  res.json({
    patient: linkedPatient,
    stats,
    treatmentTimeline,
    appointments,
    bills
  });
});
