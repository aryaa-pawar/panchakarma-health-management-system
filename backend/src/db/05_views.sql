USE panchakarma_hms;

CREATE OR REPLACE VIEW vw_patient_master_summary AS
SELECT p.id,
       p.patient_code,
       CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       fn_patient_age(p.date_of_birth) AS age,
       p.gender,
       p.constitution_type,
       p.segment,
       p.lifecycle_stage,
       p.primary_phone,
       p.city,
       p.state
FROM patients p;

CREATE OR REPLACE VIEW vw_appointment_calendar AS
SELECT a.id,
       a.appointment_date,
       a.status,
       a.visit_type,
       CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       th.name AS therapy_name,
       u.full_name AS therapist_name
FROM appointments a
JOIN patients p ON p.id = a.patient_id
LEFT JOIN therapies th ON th.id = a.therapy_id
LEFT JOIN therapists t ON t.id = a.therapist_id
LEFT JOIN users u ON u.id = t.user_id;

CREATE OR REPLACE VIEW vw_inventory_alerts AS
SELECT i.id,
       i.item_name,
       i.item_type,
       i.batch_number,
       i.quantity_in_stock,
       i.low_stock_threshold,
       i.expiry_date,
       CASE
         WHEN i.quantity_in_stock <= i.low_stock_threshold THEN 'LOW_STOCK'
         WHEN i.expiry_date IS NOT NULL AND i.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRY_RISK'
         ELSE 'NORMAL'
       END AS alert_type
FROM inventory_items i;

CREATE OR REPLACE VIEW vw_billing_summary AS
SELECT b.id,
       b.patient_id,
       b.invoice_number,
       b.bill_date,
       CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       b.net_amount,
       b.amount_paid,
       b.pending_amount,
       b.status
FROM bills b
JOIN patients p ON p.id = b.patient_id;

CREATE OR REPLACE VIEW vw_doctor_performance AS
SELECT d.id AS doctor_id,
       u.full_name AS doctor_name,
       COUNT(DISTINCT tp.id) AS treatment_plans_count,
       COUNT(DISTINCT tp.patient_id) AS unique_patients,
       COALESCE(AVG(f.rating), 0) AS avg_feedback_rating,
       COALESCE(SUM(b.net_amount), 0) AS revenue_generated
FROM doctors d
JOIN users u ON u.id = d.user_id
LEFT JOIN treatment_plans tp ON tp.doctor_id = d.id
LEFT JOIN feedback f ON f.patient_id = tp.patient_id
LEFT JOIN bills b ON b.patient_id = tp.patient_id
GROUP BY d.id, u.full_name;
