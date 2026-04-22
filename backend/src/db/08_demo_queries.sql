USE panchakarma_hms;

CALL sp_patient_treatment_history(1);
CALL sp_monthly_revenue_report(2026, 4);
SELECT * FROM vw_patient_master_summary;
SELECT * FROM vw_appointment_calendar;
SELECT * FROM vw_inventory_alerts;
SELECT * FROM vw_billing_summary;
SELECT * FROM vw_doctor_performance;
SELECT fn_patient_age('1992-08-14') AS patient_age;
SELECT fn_bill_balance(1) AS bill_pending_balance;
