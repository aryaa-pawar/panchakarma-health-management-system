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
