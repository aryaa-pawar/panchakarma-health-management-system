USE panchakarma_hms;

DELIMITER $$

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

DELIMITER ;
