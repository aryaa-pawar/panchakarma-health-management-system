import { body } from "express-validator";
import { callProcedure, query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { createAuditLog } from "../services/auditService.js";

export const paymentValidation = [
  body("billId").isInt(),
  body("amountPaid").isFloat({ gt: 0 }),
  body("paymentMode").isIn(["Cash", "Card", "UPI", "Bank Transfer", "Cheque", "Insurance"]),
  validate
];

export const billGenerationValidation = [
  body("appointmentId").isInt(),
  body("discountAmount").optional().isFloat({ min: 0 }),
  body("previousPendingAmount").optional().isFloat({ min: 0 }),
  validate
];

export const listBills = asyncHandler(async (req, res) => {
  const rows =
    req.user.role === "patient"
      ? await query(
          `SELECT v.*
           FROM vw_billing_summary v
           JOIN patients p ON p.id = v.patient_id
           WHERE p.user_id = :userId
           ORDER BY v.bill_date DESC`,
          { userId: req.user.id }
        )
      : await query(
          `SELECT *
           FROM vw_billing_summary
           ORDER BY bill_date DESC`
        );
  res.json(rows);
});

export const generateBill = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await callProcedure(
    "sp_generate_bill_for_appointment",
    [
      payload.appointmentId,
      payload.discountAmount || 0,
      payload.previousPendingAmount || 0,
      payload.paymentTerms || "Due on completion"
    ],
    req.user.id
  );

  const billId = result[0]?.bill_id;

  await createAuditLog({
    userId: req.user.id,
    action: "BILL_GENERATED",
    entityType: "bill",
    entityId: billId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.status(201).json({ message: "Bill generated", id: billId });
});

export const recordPayment = asyncHandler(async (req, res) => {
  const payload = req.body;
  const result = await callProcedure(
    "sp_record_bill_payment",
    [
      payload.billId,
      payload.amountPaid,
      payload.paymentMode,
      payload.referenceNumber || null,
      req.user.id,
      payload.notes || null
    ],
    req.user.id
  );

  const bill = result[0];

  await createAuditLog({
    userId: req.user.id,
    action: "PAYMENT_RECORDED",
    entityType: "bill",
    entityId: payload.billId,
    metadata: payload,
    ipAddress: req.ip
  });

  res.json({
    message: "Payment recorded",
    pendingAmount: bill?.pending_amount,
    status: bill?.status
  });
});
