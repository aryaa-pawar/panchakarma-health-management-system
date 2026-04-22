import { query } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const getDashboardOverview = asyncHandler(async (req, res) => {
  const [
    [patientCount],
    [appointmentCount],
    [pendingBills],
    [inventoryAlerts],
    revenueTrend,
    therapistUtilization
  ] = await Promise.all([
    query("SELECT COUNT(*) AS total FROM vw_patient_master_summary"),
    query("SELECT COUNT(*) AS total FROM vw_appointment_calendar WHERE appointment_date >= CURDATE()"),
    query("SELECT COALESCE(SUM(pending_amount), 0) AS total FROM vw_billing_summary WHERE status <> 'Paid'"),
    query("SELECT COUNT(*) AS total FROM vw_inventory_alerts WHERE alert_type <> 'NORMAL'"),
    query(
      `SELECT DATE_FORMAT(bill_date, '%Y-%m') AS month, SUM(net_amount) AS revenue
       FROM vw_billing_summary
       GROUP BY DATE_FORMAT(bill_date, '%Y-%m')
       ORDER BY month DESC
       LIMIT 6`
    ),
    query(
      `SELECT u.full_name AS therapist_name, COUNT(a.id) AS sessions_count
       FROM therapists t
       JOIN users u ON u.id = t.user_id
       LEFT JOIN appointments a ON a.therapist_id = t.id
       GROUP BY t.id
       ORDER BY sessions_count DESC`
    )
  ]);

  res.json({
    stats: {
      patients: patientCount.total,
      upcomingAppointments: appointmentCount.total,
      pendingReceivables: pendingBills.total,
      inventoryAlerts: inventoryAlerts.total
    },
    revenueTrend,
    therapistUtilization
  });
});

export const getClinicReports = asyncHandler(async (req, res) => {
  const [doctorPerformance, popularTherapies, receivables] = await Promise.all([
    query("SELECT * FROM vw_doctor_performance"),
    query(
      `SELECT th.name AS therapy_name, COUNT(a.id) AS bookings
       FROM therapies th
       LEFT JOIN appointments a ON a.therapy_id = th.id
       GROUP BY th.id
       ORDER BY bookings DESC`
    ),
    query(
      `SELECT invoice_number, pending_amount, DATEDIFF(CURDATE(), bill_date) AS aging_days
       FROM bills
       WHERE pending_amount > 0
       ORDER BY aging_days DESC`
    )
  ]);

  res.json({ doctorPerformance, popularTherapies, receivables });
});

export const getRecentActivity = asyncHandler(async (req, res) => {
  const rows = await query(
    `SELECT al.id, al.action, al.entity_type, al.entity_id, al.created_at, u.full_name
     FROM audit_log al
     LEFT JOIN users u ON u.id = al.user_id
     ORDER BY al.created_at DESC
     LIMIT 12`
  );

  res.json(rows);
});
