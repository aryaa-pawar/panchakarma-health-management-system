use panchakarma_hms;
-- patient added from frontend
SELECT id, patient_code, first_name, last_name, primary_phone, city, state, constitution_type, lifecycle_stage
FROM patients
ORDER BY id DESC
LIMIT 5;


-- book an appointment for that patient
SELECT id, patient_id, therapy_id, therapist_id, appointment_date, status, visit_type
FROM appointments
ORDER BY id DESC
LIMIT 5;

-- appointment calendar view:

SELECT *
FROM vw_appointment_calendar
ORDER BY appointment_date DESC
LIMIT 10;


-- treatment plan creation
SELECT id, patient_id, doctor_id, diagnosis, status, start_date, end_date
FROM treatment_plans
ORDER BY id DESC
LIMIT 5;


-- therapy session completion

SELECT id, appointment_id, session_date, status, patient_comfort_rating, therapist_notes
FROM therapy_sessions
ORDER BY id DESC
LIMIT 5;


-- appointment status changed:

SELECT id, appointment_date, status
FROM appointments
ORDER BY id DESC
LIMIT 10;

-- inventory usage automation

SELECT id, therapy_session_id, inventory_item_id, quantity_used
FROM session_inventory_usage
ORDER BY id DESC
LIMIT 10;

-- deducted automatically:

SELECT id, item_name, quantity_in_stock, low_stock_threshold
FROM inventory_items
ORDER BY id DESC;

-- generate a bill for an appointment
Then run:

SELECT id, invoice_number, patient_id, appointment_id, subtotal, tax_amount, net_amount, pending_amount, status
FROM bills
ORDER BY id DESC
LIMIT 10;

-- record payment
SELECT id, bill_id, amount_paid, payment_mode, created_at
FROM payments
ORDER BY id DESC
LIMIT 10;

-- bill status/pending updated automatically:

SELECT id, invoice_number, net_amount, amount_paid, pending_amount, status
FROM bills
ORDER BY id DESC
LIMIT 10;


-- generate bill
SELECT id, invoice_number, patient_id, appointment_id, subtotal, tax_amount, discount_amount, previous_pending_amount, net_amount, amount_paid, pending_amount, status
FROM bills
ORDER BY id DESC
LIMIT 5;

