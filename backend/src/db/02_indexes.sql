USE panchakarma_hms;

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
