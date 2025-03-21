USE appdb;

DELIMITER //
CREATE PROCEDURE seed_data()
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= 100 DO
    INSERT INTO customers (first_name, last_name, email)
    VALUES (
      CONCAT('First', i),
      CONCAT('Last', i),
      CONCAT('customer', i, '@example.com')
    );
    SET i = i + 1;
  END WHILE;

  SET i = 1;
  WHILE i <= 2000 DO
    INSERT INTO orders (customer_id, order_total, status)
    VALUES (
      1 + MOD(i - 1, 100),
      10.00 + (i % 100),
      'NEW'
    );
    SET i = i + 1;
  END WHILE;

  SET i = 1;
  WHILE i <= 10000 DO
    INSERT INTO order_items (order_id, sku, quantity, price)
    VALUES (
      1 + MOD(i - 1, 2000),
      CONCAT('SKU-', LPAD(i, 6, '0')),
      1 + MOD(i, 5),
      5.00 + (i % 25)
    );
    SET i = i + 1;
  END WHILE;
END//
DELIMITER ;

CALL seed_data();
DROP PROCEDURE seed_data;
