USE panchakarma_hms;

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

DELIMITER ;
