USE panchakarma_hms;

DELIMITER $$

CREATE PROCEDURE sp_register_patient(
  IN p_first_name VARCHAR(100),
  IN p_last_name VARCHAR(100),
  IN p_date_of_birth DATE,
  IN p_gender VARCHAR(10),
  IN p_email VARCHAR(150),
  IN p_primary_phone VARCHAR(25),
  IN p_constitution_type VARCHAR(20),
  IN p_allergies TEXT,
  IN p_medical_history TEXT,
  IN p_segment VARCHAR(20),
  IN p_lifecycle_stage VARCHAR(20),
  IN p_referral_source VARCHAR(150)
)
BEGIN
  INSERT INTO patients (
    patient_code, first_name, last_name, date_of_birth, gender, email, primary_phone,
    constitution_type, allergies, medical_history, segment, lifecycle_stage, referral_source
  ) VALUES (
    CONCAT('PAT', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(1000 + RAND() * 8999), 4, '0')),
    p_first_name, p_last_name, p_date_of_birth, p_gender, p_email, p_primary_phone,
    p_constitution_type, p_allergies, p_medical_history, COALESCE(p_segment, 'New'),
    COALESCE(p_lifecycle_stage, 'Intake'), p_referral_source
  );

  SELECT LAST_INSERT_ID() AS patient_id;
END$$

CREATE PROCEDURE sp_book_appointment(
  IN p_patient_id BIGINT,
  IN p_treatment_plan_id BIGINT,
  IN p_therapy_id BIGINT,
  IN p_therapist_id BIGINT,
  IN p_appointment_date DATETIME,
  IN p_visit_type VARCHAR(100),
  IN p_notes TEXT,
  IN p_buffer_minutes INT
)
BEGIN
  DECLARE v_conflict_count INT DEFAULT 0;

  SELECT COUNT(*)
  INTO v_conflict_count
  FROM appointments
  WHERE therapist_id = p_therapist_id
    AND status IN ('Scheduled', 'In Progress')
    AND ABS(TIMESTAMPDIFF(MINUTE, appointment_date, p_appointment_date)) < COALESCE(p_buffer_minutes, 15);

  IF v_conflict_count > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Therapist already has a conflicting appointment';
  END IF;

  INSERT INTO appointments (
    patient_id, treatment_plan_id, therapy_id, therapist_id, appointment_date,
    visit_type, status, notes, buffer_minutes
  ) VALUES (
    p_patient_id, p_treatment_plan_id, p_therapy_id, p_therapist_id, p_appointment_date,
    COALESCE(p_visit_type, 'Consultation'), 'Scheduled', p_notes, COALESCE(p_buffer_minutes, 15)
  );

  SELECT LAST_INSERT_ID() AS appointment_id;
END$$

CREATE PROCEDURE sp_complete_therapy_session(
  IN p_appointment_id BIGINT,
  IN p_session_date DATETIME,
  IN p_observations TEXT,
  IN p_patient_comfort_rating INT,
  IN p_therapist_notes TEXT,
  IN p_recommendations TEXT
)
BEGIN
  DECLARE v_existing_session INT DEFAULT 0;

  SELECT COUNT(*)
  INTO v_existing_session
  FROM therapy_sessions
  WHERE appointment_id = p_appointment_id;

  IF v_existing_session > 0 THEN
    UPDATE therapy_sessions
    SET session_date = p_session_date,
        status = 'Completed',
        observations = p_observations,
        patient_comfort_rating = p_patient_comfort_rating,
        therapist_notes = p_therapist_notes,
        recommendations = p_recommendations
    WHERE appointment_id = p_appointment_id;
  ELSE
    INSERT INTO therapy_sessions (
      appointment_id, session_date, status, observations,
      patient_comfort_rating, therapist_notes, recommendations
    ) VALUES (
      p_appointment_id, p_session_date, 'Completed', p_observations,
      p_patient_comfort_rating, p_therapist_notes, p_recommendations
    );
  END IF;

  UPDATE appointments
  SET status = 'Completed'
  WHERE id = p_appointment_id;

  SELECT id AS therapy_session_id
  FROM therapy_sessions
  WHERE appointment_id = p_appointment_id;
END$$

CREATE PROCEDURE sp_log_session_inventory_usage(
  IN p_therapy_session_id BIGINT,
  IN p_inventory_item_id BIGINT,
  IN p_quantity_used DECIMAL(10,2)
)
BEGIN
  INSERT INTO session_inventory_usage (
    therapy_session_id, inventory_item_id, quantity_used
  ) VALUES (
    p_therapy_session_id, p_inventory_item_id, p_quantity_used
  );

  SELECT quantity_in_stock AS remaining_stock
  FROM inventory_items
  WHERE id = p_inventory_item_id;
END$$

CREATE PROCEDURE sp_generate_bill_for_appointment(
  IN p_appointment_id BIGINT,
  IN p_discount_amount DECIMAL(10,2),
  IN p_previous_pending_amount DECIMAL(10,2),
  IN p_payment_terms VARCHAR(255)
)
BEGIN
  DECLARE v_patient_id BIGINT;
  DECLARE v_subtotal DECIMAL(10,2);
  DECLARE v_tax_amount DECIMAL(10,2);

  SELECT a.patient_id, t.cost_per_session
  INTO v_patient_id, v_subtotal
  FROM appointments a
  LEFT JOIN therapies t ON t.id = a.therapy_id
  WHERE a.id = p_appointment_id;

  IF v_patient_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Appointment not found';
  END IF;

  SET v_tax_amount = ROUND(v_subtotal * 0.18, 2);

  INSERT INTO bills (
    patient_id, appointment_id, invoice_number, bill_date, subtotal, tax_amount, discount_amount,
    previous_pending_amount, net_amount, amount_paid, pending_amount, status, payment_terms
  ) VALUES (
    v_patient_id,
    p_appointment_id,
    CONCAT('INV-', DATE_FORMAT(CURDATE(), '%Y'), '-', LPAD(FLOOR(1000 + RAND() * 8999), 4, '0')),
    CURDATE(),
    COALESCE(v_subtotal, 0),
    COALESCE(v_tax_amount, 0),
    COALESCE(p_discount_amount, 0),
    COALESCE(p_previous_pending_amount, 0),
    0,
    0,
    0,
    'Pending',
    p_payment_terms
  );

  SELECT LAST_INSERT_ID() AS bill_id;
END$$

CREATE PROCEDURE sp_record_bill_payment(
  IN p_bill_id BIGINT,
  IN p_amount_paid DECIMAL(10,2),
  IN p_payment_mode VARCHAR(20),
  IN p_reference_number VARCHAR(120),
  IN p_received_by_user_id BIGINT,
  IN p_notes TEXT
)
BEGIN
  DECLARE v_pending_amount DECIMAL(10,2);

  SELECT pending_amount
  INTO v_pending_amount
  FROM bills
  WHERE id = p_bill_id;

  IF v_pending_amount IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Bill not found';
  END IF;

  IF p_amount_paid > v_pending_amount THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payment exceeds pending amount';
  END IF;

  INSERT INTO payments (
    bill_id, amount_paid, payment_mode, reference_number, received_by_user_id, notes
  ) VALUES (
    p_bill_id, p_amount_paid, p_payment_mode, p_reference_number, p_received_by_user_id, p_notes
  );

  SELECT pending_amount, status
  FROM bills
  WHERE id = p_bill_id;
END$$

CREATE PROCEDURE sp_patient_treatment_history(IN p_patient_id BIGINT)
BEGIN
  SELECT p.patient_code,
         CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
         tp.diagnosis,
         tp.status AS treatment_status,
         a.appointment_date,
         a.status AS appointment_status,
         th.name AS therapy_name,
         ts.status AS session_status,
         ts.patient_comfort_rating
  FROM patients p
  LEFT JOIN treatment_plans tp ON tp.patient_id = p.id
  LEFT JOIN appointments a ON a.treatment_plan_id = tp.id
  LEFT JOIN therapies th ON th.id = a.therapy_id
  LEFT JOIN therapy_sessions ts ON ts.appointment_id = a.id
  WHERE p.id = p_patient_id
  ORDER BY a.appointment_date DESC;
END$$

CREATE PROCEDURE sp_monthly_revenue_report(IN p_year INT, IN p_month INT)
BEGIN
  SELECT DATE_FORMAT(b.bill_date, '%Y-%m') AS billing_month,
         COUNT(b.id) AS total_bills,
         SUM(b.net_amount) AS total_billed,
         SUM(b.amount_paid) AS total_collected,
         SUM(b.pending_amount) AS total_pending
  FROM bills b
  WHERE YEAR(b.bill_date) = p_year
    AND MONTH(b.bill_date) = p_month
  GROUP BY DATE_FORMAT(b.bill_date, '%Y-%m');
END$$

DELIMITER ;
