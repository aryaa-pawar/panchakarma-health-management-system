DROP DATABASE IF EXISTS panchakarma_hms;
CREATE DATABASE panchakarma_hms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE panchakarma_hms;

CREATE TABLE roles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255) NULL
);

CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  role_id BIGINT NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(25) NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url VARCHAR(255) NULL,
  email_verified_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_users_email CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
  CONSTRAINT chk_users_phone CHECK (phone IS NULL OR phone REGEXP '^[0-9]{10}$'),
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE login_history (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  logged_in_at DATETIME NOT NULL,
  CONSTRAINT fk_login_history_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE password_reset_otps (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  otp_code VARCHAR(10) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reset_otp_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE patients (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_code VARCHAR(30) NOT NULL UNIQUE,
  user_id BIGINT NULL UNIQUE,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE NULL,
  gender ENUM('Male', 'Female', 'Other') NOT NULL,
  email VARCHAR(150) NULL,
  primary_phone VARCHAR(25) NULL,
  emergency_contact_name VARCHAR(150) NULL,
  emergency_contact_phone VARCHAR(25) NULL,
  address_line1 VARCHAR(255) NULL,
  city VARCHAR(100) NULL,
  state VARCHAR(100) NULL,
  constitution_type ENUM('Vata', 'Pitta', 'Kapha', 'Vata-Pitta', 'Pitta-Kapha', 'Vata-Kapha', 'Tri-dosha') NULL,
  allergies TEXT NULL,
  previous_conditions TEXT NULL,
  current_medications TEXT NULL,
  medical_history TEXT NULL,
  photo_url VARCHAR(255) NULL,
  insurance_provider VARCHAR(120) NULL,
  insurance_policy_number VARCHAR(120) NULL,
  segment ENUM('New', 'Recurring', 'VIP') NOT NULL DEFAULT 'New',
  lifecycle_stage ENUM('Intake', 'Treatment', 'Follow-up', 'Discharged') NOT NULL DEFAULT 'Intake',
  referral_source VARCHAR(150) NULL,
  family_group_code VARCHAR(50) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_patients_email CHECK (email IS NULL OR email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
  CONSTRAINT chk_patients_phone CHECK (primary_phone IS NULL OR primary_phone REGEXP '^[0-9]{10}$'),
  CONSTRAINT chk_patients_emergency_phone CHECK (emergency_contact_phone IS NULL OR emergency_contact_phone REGEXP '^[0-9]{10}$'),
  CONSTRAINT chk_patients_city CHECK (city IS NULL OR city REGEXP '^[A-Za-z ]+$'),
  CONSTRAINT chk_patients_state CHECK (state IS NULL OR state REGEXP '^[A-Za-z ]+$'),
  CONSTRAINT fk_patients_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE doctors (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL UNIQUE,
  specialization VARCHAR(150) NOT NULL,
  qualifications VARCHAR(255) NULL,
  license_number VARCHAR(100) NULL,
  years_experience INT DEFAULT 0 CHECK (years_experience >= 0),
  consultation_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_doctors_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE therapists (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL UNIQUE,
  certification VARCHAR(255) NULL,
  skills JSON NULL,
  availability_json JSON NULL,
  compatibility_notes TEXT NULL,
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_therapists_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE therapies (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL UNIQUE,
  category VARCHAR(100) NOT NULL,
  duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
  cost_per_session DECIMAL(10,2) NOT NULL CHECK (cost_per_session >= 0),
  required_items_json JSON NULL,
  precautions TEXT NULL,
  contraindications TEXT NULL,
  benefits TEXT NULL,
  indications TEXT NULL,
  skill_level_required VARCHAR(50) NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE packages (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL UNIQUE,
  package_type VARCHAR(100) NOT NULL,
  description TEXT NULL,
  duration_days INT NOT NULL CHECK (duration_days > 0),
  total_cost DECIMAL(10,2) NOT NULL CHECK (total_cost >= 0),
  discount_type ENUM('None', 'Fixed', 'Percentage') NOT NULL DEFAULT 'None',
  discount_value DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (discount_value >= 0),
  inclusions TEXT NULL,
  expected_outcomes TEXT NULL,
  customization_options TEXT NULL,
  seasonal_offer_note VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE package_therapies (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  package_id BIGINT NOT NULL,
  therapy_id BIGINT NOT NULL,
  frequency_per_week INT NOT NULL DEFAULT 3 CHECK (frequency_per_week > 0),
  CONSTRAINT fk_package_therapies_package FOREIGN KEY (package_id) REFERENCES packages(id),
  CONSTRAINT fk_package_therapies_therapy FOREIGN KEY (therapy_id) REFERENCES therapies(id),
  CONSTRAINT uq_package_therapy UNIQUE (package_id, therapy_id)
);

CREATE TABLE treatment_plans (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  package_id BIGINT NULL,
  diagnosis VARCHAR(255) NOT NULL,
  condition_details TEXT NULL,
  recommended_therapies JSON NULL,
  treatment_duration_weeks INT NULL CHECK (treatment_duration_weeks >= 0),
  precautions TEXT NULL,
  contraindications TEXT NULL,
  expected_outcomes TEXT NULL,
  success_metrics TEXT NULL,
  status ENUM('Draft', 'Active', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Draft',
  start_date DATE NULL,
  end_date DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_treatment_plans_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
  CONSTRAINT fk_treatment_plans_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),
  CONSTRAINT fk_treatment_plans_package FOREIGN KEY (package_id) REFERENCES packages(id)
);

CREATE TABLE appointments (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  treatment_plan_id BIGINT NULL,
  therapy_id BIGINT NULL,
  therapist_id BIGINT NULL,
  appointment_date DATETIME NOT NULL,
  visit_type VARCHAR(100) NOT NULL DEFAULT 'Consultation',
  status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled', 'No-show') NOT NULL DEFAULT 'Scheduled',
  notes TEXT NULL,
  buffer_minutes INT NOT NULL DEFAULT 15 CHECK (buffer_minutes >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
  CONSTRAINT fk_appointments_treatment_plan FOREIGN KEY (treatment_plan_id) REFERENCES treatment_plans(id),
  CONSTRAINT fk_appointments_therapy FOREIGN KEY (therapy_id) REFERENCES therapies(id),
  CONSTRAINT fk_appointments_therapist FOREIGN KEY (therapist_id) REFERENCES therapists(id)
);

CREATE TABLE therapy_sessions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  appointment_id BIGINT NOT NULL UNIQUE,
  session_date DATETIME NOT NULL,
  status ENUM('Scheduled', 'In Progress', 'Completed') NOT NULL DEFAULT 'Scheduled',
  before_media_url VARCHAR(255) NULL,
  after_media_url VARCHAR(255) NULL,
  observations TEXT NULL,
  patient_comfort_rating INT NULL CHECK (patient_comfort_rating BETWEEN 1 AND 5),
  therapist_notes TEXT NULL,
  recommendations TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sessions_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id)
);

CREATE TABLE suppliers (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  contact_person VARCHAR(120) NULL,
  phone VARCHAR(30) NULL,
  email VARCHAR(150) NULL,
  payment_terms VARCHAR(255) NULL,
  quality_feedback TEXT NULL,
  CONSTRAINT chk_suppliers_phone CHECK (phone IS NULL OR phone REGEXP '^[0-9]{10}$'),
  CONSTRAINT chk_suppliers_email CHECK (email IS NULL OR email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
);

CREATE TABLE inventory_items (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  item_name VARCHAR(150) NOT NULL,
  item_type VARCHAR(100) NOT NULL,
  batch_number VARCHAR(80) NULL,
  cost_per_unit DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (cost_per_unit >= 0),
  selling_price DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (selling_price >= 0),
  quantity_in_stock DECIMAL(10,2) NOT NULL CHECK (quantity_in_stock >= 0),
  unit VARCHAR(30) NOT NULL DEFAULT 'ml',
  expiry_date DATE NULL,
  supplier_id BIGINT NULL,
  storage_location VARCHAR(150) NULL,
  low_stock_threshold DECIMAL(10,2) NOT NULL DEFAULT 10 CHECK (low_stock_threshold >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_inventory_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

CREATE TABLE session_inventory_usage (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  therapy_session_id BIGINT NOT NULL,
  inventory_item_id BIGINT NOT NULL,
  quantity_used DECIMAL(10,2) NOT NULL CHECK (quantity_used > 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_usage_session FOREIGN KEY (therapy_session_id) REFERENCES therapy_sessions(id),
  CONSTRAINT fk_usage_item FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id)
);

CREATE TABLE bills (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  appointment_id BIGINT NULL,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  bill_date DATE NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  previous_pending_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  net_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  amount_paid DECIMAL(10,2) NOT NULL DEFAULT 0,
  pending_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('Pending', 'Partially Paid', 'Paid', 'Refunded') NOT NULL DEFAULT 'Pending',
  payment_terms VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bills_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
  CONSTRAINT fk_bills_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id)
);

CREATE TABLE payments (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  bill_id BIGINT NOT NULL,
  amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid > 0),
  payment_mode ENUM('Cash', 'Card', 'UPI', 'Bank Transfer', 'Cheque', 'Insurance') NOT NULL,
  reference_number VARCHAR(120) NULL,
  received_by_user_id BIGINT NOT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_bill FOREIGN KEY (bill_id) REFERENCES bills(id),
  CONSTRAINT fk_payments_user FOREIGN KEY (received_by_user_id) REFERENCES users(id)
);

CREATE TABLE feedback (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  therapy_session_id BIGINT NULL,
  therapist_id BIGINT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  facility_rating INT NULL CHECK (facility_rating BETWEEN 1 AND 5),
  comment TEXT NULL,
  improvement_metrics JSON NULL,
  consent_for_testimonial TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_feedback_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
  CONSTRAINT fk_feedback_session FOREIGN KEY (therapy_session_id) REFERENCES therapy_sessions(id),
  CONSTRAINT fk_feedback_therapist FOREIGN KEY (therapist_id) REFERENCES therapists(id)
);

CREATE TABLE audit_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NULL,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id BIGINT NULL,
  metadata JSON NULL,
  ip_address VARCHAR(45) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_patients_name_phone ON patients(last_name, first_name, primary_phone);
CREATE INDEX idx_patients_segment_stage ON patients(segment, lifecycle_stage);
CREATE INDEX idx_appointments_date_status ON appointments(appointment_date, status);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_treatment_plans_patient_status ON treatment_plans(patient_id, status);
CREATE INDEX idx_sessions_status_date ON therapy_sessions(status, session_date);
CREATE INDEX idx_inventory_expiry_stock ON inventory_items(expiry_date, quantity_in_stock);
CREATE INDEX idx_bills_status_date ON bills(status, bill_date);
CREATE INDEX idx_payments_bill_id ON payments(bill_id);
CREATE INDEX idx_audit_log_user_action ON audit_log(user_id, action, created_at);

DELIMITER $$

CREATE TRIGGER trg_patients_after_insert
AFTER INSERT ON patients
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
  VALUES (
    @app_user_id,
    'PATIENT_CREATED_DB',
    'patient',
    NEW.id,
    JSON_OBJECT('patient_code', NEW.patient_code, 'segment', NEW.segment, 'lifecycle_stage', NEW.lifecycle_stage)
  );
END$$

CREATE TRIGGER trg_appointments_after_insert
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
  VALUES (
    @app_user_id,
    'APPOINTMENT_CREATED_DB',
    'appointment',
    NEW.id,
    JSON_OBJECT('patient_id', NEW.patient_id, 'therapy_id', NEW.therapy_id, 'status', NEW.status)
  );
END$$

CREATE TRIGGER trg_session_inventory_usage_after_insert
AFTER INSERT ON session_inventory_usage
FOR EACH ROW
BEGIN
  DECLARE v_available_stock DECIMAL(10,2);

  SELECT quantity_in_stock
  INTO v_available_stock
  FROM inventory_items
  WHERE id = NEW.inventory_item_id;

  IF v_available_stock < NEW.quantity_used THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient inventory for session usage';
  END IF;

  UPDATE inventory_items
  SET quantity_in_stock = quantity_in_stock - NEW.quantity_used
  WHERE id = NEW.inventory_item_id;
END$$

CREATE TRIGGER trg_bill_after_insert
AFTER INSERT ON bills
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
  VALUES (
    @app_user_id,
    'BILL_GENERATED_DB',
    'bill',
    NEW.id,
    JSON_OBJECT('invoice_number', NEW.invoice_number, 'net_amount', NEW.net_amount, 'status', NEW.status)
  );
END$$

CREATE TRIGGER trg_bill_calculation_before_insert
BEFORE INSERT ON bills
FOR EACH ROW
BEGIN
  SET NEW.net_amount = (NEW.subtotal + NEW.tax_amount + NEW.previous_pending_amount) - NEW.discount_amount;
  SET NEW.pending_amount = NEW.net_amount - NEW.amount_paid;
  IF NEW.pending_amount < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Overpayment is not allowed';
  END IF;
END$$

CREATE TRIGGER trg_bill_payment_after_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
  UPDATE bills
  SET amount_paid = amount_paid + NEW.amount_paid,
      pending_amount = net_amount - (amount_paid + NEW.amount_paid),
      status = CASE
        WHEN net_amount - (amount_paid + NEW.amount_paid) <= 0 THEN 'Paid'
        ELSE 'Partially Paid'
      END
  WHERE id = NEW.bill_id;

  INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
  VALUES (
    @app_user_id,
    'PAYMENT_RECORDED_DB',
    'payment',
    NEW.id,
    JSON_OBJECT('bill_id', NEW.bill_id, 'amount_paid', NEW.amount_paid, 'payment_mode', NEW.payment_mode)
  );
END$$

CREATE TRIGGER trg_appointment_status_before_update
BEFORE UPDATE ON appointments
FOR EACH ROW
BEGIN
  IF OLD.status = 'Cancelled' AND NEW.status = 'Completed' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cancelled appointments cannot be completed';
  END IF;
END$$

CREATE TRIGGER trg_appointment_status_after_update
AFTER UPDATE ON appointments
FOR EACH ROW
BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
    VALUES (
      @app_user_id,
      'APPOINTMENT_STATUS_CHANGED_DB',
      'appointment',
      NEW.id,
      JSON_OBJECT('old_status', OLD.status, 'new_status', NEW.status)
    );
  END IF;
END$$

CREATE TRIGGER trg_therapy_session_after_insert
AFTER INSERT ON therapy_sessions
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
  VALUES (
    @app_user_id,
    'THERAPY_SESSION_RECORDED_DB',
    'therapy_session',
    NEW.id,
    JSON_OBJECT('appointment_id', NEW.appointment_id, 'status', NEW.status, 'comfort_rating', NEW.patient_comfort_rating)
  );
END$$

CREATE TRIGGER trg_therapy_session_after_update
AFTER UPDATE ON therapy_sessions
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, entity_type, entity_id, metadata)
  VALUES (
    @app_user_id,
    'THERAPY_SESSION_UPDATED_DB',
    'therapy_session',
    NEW.id,
    JSON_OBJECT('old_status', OLD.status, 'new_status', NEW.status, 'comfort_rating', NEW.patient_comfort_rating)
  );
END$$

CREATE FUNCTION fn_patient_age(p_date_of_birth DATE)
RETURNS INT
DETERMINISTIC
BEGIN
  IF p_date_of_birth IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN TIMESTAMPDIFF(YEAR, p_date_of_birth, CURDATE());
END$$

CREATE FUNCTION fn_bill_balance(p_bill_id BIGINT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
  DECLARE v_balance DECIMAL(10,2);

  SELECT pending_amount
  INTO v_balance
  FROM bills
  WHERE id = p_bill_id;

  RETURN COALESCE(v_balance, 0);
END$$

CREATE PROCEDURE sp_register_patient(
  IN p_first_name VARCHAR(100),
  IN p_last_name VARCHAR(100),
  IN p_date_of_birth DATE,
  IN p_gender VARCHAR(10),
  IN p_email VARCHAR(150),
  IN p_primary_phone VARCHAR(25),
  IN p_emergency_contact_name VARCHAR(150),
  IN p_emergency_contact_phone VARCHAR(25),
  IN p_address_line1 VARCHAR(255),
  IN p_city VARCHAR(100),
  IN p_state VARCHAR(100),
  IN p_constitution_type VARCHAR(20),
  IN p_allergies TEXT,
  IN p_current_medications TEXT,
  IN p_medical_history TEXT,
  IN p_segment VARCHAR(20),
  IN p_lifecycle_stage VARCHAR(20),
  IN p_referral_source VARCHAR(150)
)
BEGIN
  INSERT INTO patients (
    patient_code, first_name, last_name, date_of_birth, gender, email, primary_phone,
    emergency_contact_name, emergency_contact_phone, address_line1, city, state,
    constitution_type, allergies, current_medications, medical_history, segment, lifecycle_stage, referral_source
  ) VALUES (
    CONCAT('PAT', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(1000 + RAND() * 8999), 4, '0')),
    p_first_name, p_last_name, p_date_of_birth, p_gender, p_email, p_primary_phone,
    p_emergency_contact_name, p_emergency_contact_phone, p_address_line1, p_city, p_state,
    p_constitution_type, p_allergies, p_current_medications, p_medical_history, COALESCE(p_segment, 'New'),
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
