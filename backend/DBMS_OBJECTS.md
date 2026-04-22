# DBMS Objects

This project now includes a fuller MySQL DBMS layer suitable for a core database submission.

## Tables

- `roles`
- `users`
- `login_history`
- `password_reset_otps`
- `patients`
- `doctors`
- `therapists`
- `therapies`
- `packages`
- `package_therapies`
- `treatment_plans`
- `appointments`
- `therapy_sessions`
- `suppliers`
- `inventory_items`
- `session_inventory_usage`
- `bills`
- `payments`
- `feedback`
- `audit_log`

## Triggers

- `trg_session_inventory_usage_after_insert`
- `trg_bill_calculation_before_insert`
- `trg_bill_payment_after_insert`
- `trg_appointment_status_before_update`

## Functions

- `fn_patient_age`
- `fn_bill_balance`

## Stored Procedures

- `sp_register_patient`
- `sp_book_appointment`
- `sp_complete_therapy_session`
- `sp_log_session_inventory_usage`
- `sp_generate_bill_for_appointment`
- `sp_record_bill_payment`
- `sp_patient_treatment_history`
- `sp_monthly_revenue_report`

## Views

- `vw_patient_master_summary`
- `vw_appointment_calendar`
- `vw_inventory_alerts`
- `vw_billing_summary`
- `vw_doctor_performance`

## Indexes

- Patient search and segmentation indexes
- Appointment scheduling indexes
- Treatment, session, billing, payment, and audit indexes

## Suggested Demo Queries

```sql
CALL sp_patient_treatment_history(1);
CALL sp_monthly_revenue_report(2026, 4);
SELECT * FROM vw_inventory_alerts;
SELECT * FROM vw_doctor_performance;
SELECT fn_patient_age('1992-08-14') AS age;
SELECT fn_bill_balance(1) AS pending_balance;
```
