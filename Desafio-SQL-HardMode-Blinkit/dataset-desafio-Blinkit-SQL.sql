CREATE TABLE orders(
    customer_id INT,
    order_date DATE,
    coupon_code VARCHAR(50)
);

TRUNCATE TABLE orders;

-- ✅ Customer 1: First order in January, valid pattern
INSERT INTO orders VALUES(1, '2025-01-10', NULL);
INSERT INTO orders VALUES(1, '2025-02-05', NULL);
INSERT INTO orders VALUES(1, '2025-02-20', NULL);
INSERT INTO orders VALUES(1, '2025-03-01', NULL);
INSERT INTO orders VALUES(1, '2025-03-10', NULL);
INSERT INTO orders VALUES(1, '2025-03-15', 'DISC10'); -- last order with coupon ✅

-- ✅ Customer 2: First order in February, valid pattern
INSERT INTO orders VALUES(2, '2025-02-02', NULL); -- Month1 = 1
INSERT INTO orders VALUES(2, '2025-02-05', NULL); -- Month1 = 1
INSERT INTO orders VALUES(2, '2025-03-05', NULL); -- Month2 = 2
INSERT INTO orders VALUES(2, '2025-03-18', NULL);
INSERT INTO orders VALUES(2, '2025-03-20', NULL); -- Month2 = 2
INSERT INTO orders VALUES(2, '2025-03-22', NULL);
INSERT INTO orders VALUES(2, '2025-04-02', NULL); -- Month3 = 3
INSERT INTO orders VALUES(2, '2025-04-10', NULL);
INSERT INTO orders VALUES(2, '2025-04-15', 'DISC20'); -- last order with coupon ✅
INSERT INTO orders VALUES(2, '2025-04-16', NULL); -- Month3 = 3
INSERT INTO orders VALUES(2, '2025-04-18', NULL);
INSERT INTO orders VALUES(2, '2025-04-20', 'DISC20'); -- last order with coupon ✅

-- ❌ Customer 3: First order in March, but multiple errors
INSERT INTO orders VALUES(3, '2025-03-05', NULL); -- Month1 = 1
INSERT INTO orders VALUES(3, '2025-04-10', NULL); -- Month2 should have 2, but only 1 ❌
INSERT INTO orders VALUES(3, '2025-05-15', 'DISC30');

-- ❌ Customer 4: First order in February, but missing March (gap)
INSERT INTO orders VALUES(4, '2025-02-01', NULL); -- Month1
INSERT INTO orders VALUES(4, '2025-04-05', 'DISC40'); -- March skipped ❌

-- ❌ Customer 5: Multiple valid, but last order has no coupon
INSERT INTO orders VALUES(5, '2025-01-03', NULL); -- M1 = 1
INSERT INTO orders VALUES(5, '2025-02-05', NULL); -- M2 = 2
INSERT INTO orders VALUES(5, '2025-02-15', NULL);
INSERT INTO orders VALUES(5, '2025-03-01', NULL); -- M3 = 3
INSERT INTO orders VALUES(5, '2025-03-08', 'DISC50'); -- middle coupon
INSERT INTO orders VALUES(5, '2025-03-20', NULL); -- last order without coupon ❌

-- ❌ Customer 6: Skips month 2, should be excluded
INSERT INTO orders VALUES(6, '2025-01-05', NULL); -- Month1 = 1 order
-- (no orders in February, so Month2 is missing ❌)
INSERT INTO orders VALUES(6, '2025-03-02', NULL); -- Month3 = 1st order
INSERT INTO orders VALUES(6, '2025-03-15', NULL); -- Month3 = 2nd order
-- Jump to May (Month5 relative to January)
INSERT INTO orders VALUES(6, '2025-05-05', NULL);
INSERT INTO orders VALUES(6, '2025-05-10', NULL);
INSERT INTO orders VALUES(6, '2025-05-25', 'DISC60'); -- Last order with coupon