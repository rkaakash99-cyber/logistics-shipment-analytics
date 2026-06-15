CREATE DATABASE logistics_db;

USE logistics_db;

CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50),
    state         VARCHAR(50),
    email         VARCHAR(100)
);

CREATE TABLE warehouses (
    warehouse_id   INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    city           VARCHAR(50),
    state          VARCHAR(50)
);

CREATE TABLE carriers (
    carrier_id     INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name   VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15)
);

CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    unit_price   DECIMAL(10,2)
);

CREATE TABLE shipments (
    shipment_id       INT AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT,
    warehouse_id      INT,
    carrier_id        INT,
    shipment_date     DATE,
    expected_delivery DATE,
    actual_delivery   DATE,
    delivery_status   VARCHAR(20),
    destination_city  VARCHAR(50),
    freight_cost      DECIMAL(10,2),
    FOREIGN KEY (customer_id)  REFERENCES customers(customer_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (carrier_id)   REFERENCES carriers(carrier_id)
);

CREATE TABLE shipment_items (
    item_id     INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    product_id  INT,
    quantity    INT,
    total_price DECIMAL(10,2),
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (product_id)  REFERENCES products(product_id)
);

-- Customers
INSERT INTO customers (customer_name, city, state, email) VALUES
('Arjun Logistics Pvt Ltd',  'Chennai',    'Tamil Nadu',  'arjun@arjunlogistics.in'),
('Meena Traders',             'Madurai',    'Tamil Nadu',  'meena@meenatraders.in'),
('Karthik Enterprises',       'Coimbatore', 'Tamil Nadu',  'karthik@kenterp.in'),
('Priya Exports',             'Bengaluru',  'Karnataka',   'priya@priyaexp.com'),
('Ravi Industrial Supplies',  'Hyderabad',  'Telangana',   'ravi@raviind.com'),
('Lakshmi Textiles',          'Tiruppur',   'Tamil Nadu',  'lakshmi@laktex.in'),
('Suresh Auto Parts',         'Pune',       'Maharashtra', 'suresh@sureshauto.in'),
('Deepa Cold Chain',          'Mumbai',     'Maharashtra', 'deepa@deepacc.com');

-- Warehouses
INSERT INTO warehouses (warehouse_name, city, state) VALUES
('Chennai Central Warehouse',    'Chennai',    'Tamil Nadu'),
('Bengaluru South Hub',          'Bengaluru',  'Karnataka'),
('Mumbai Western Facility',      'Mumbai',     'Maharashtra'),
('Hyderabad Distribution Center','Hyderabad',  'Telangana');

-- Carriers
INSERT INTO carriers (carrier_name, contact_number) VALUES
('Blue Dart Express',  '1800-123-456'),
('Delhivery Pvt Ltd',  '1800-234-567'),
('DTDC Courier',       '1800-345-678'),
('Ecom Express',       '1800-456-789');

-- Products
INSERT INTO products (product_name, category, unit_price) VALUES
('Auto Engine Parts',     'Automobile',   4500.00),
('Cotton Fabric Roll',    'Textile',       800.00),
('Electronic Components', 'Electronics', 12000.00),
('Industrial Chemicals',  'Chemicals',    3200.00),
('Pharma Packaging',      'Healthcare',   1500.00),
('Steel Pipes',           'Construction', 6000.00),
('Plastic Granules',      'Raw Material', 2200.00),
('Refrigerated Food',     'FMCG',          950.00);

-- Shipments (20 rows with realistic dates, statuses, delays)
INSERT INTO shipments 
  (customer_id, warehouse_id, carrier_id, shipment_date, expected_delivery, actual_delivery, delivery_status, destination_city, freight_cost)
VALUES
(1, 1, 1, '2024-01-05', '2024-01-08', '2024-01-08', 'Delivered',  'Chennai',    1200.00),
(2, 1, 2, '2024-01-10', '2024-01-13', '2024-01-15', 'Delayed',    'Madurai',     850.00),
(3, 2, 3, '2024-01-15', '2024-01-18', '2024-01-18', 'Delivered',  'Coimbatore', 1100.00),
(4, 2, 1, '2024-01-20', '2024-01-23', '2024-01-25', 'Delayed',    'Bengaluru',  1400.00),
(5, 3, 4, '2024-02-01', '2024-02-04', '2024-02-04', 'Delivered',  'Hyderabad',  1600.00),
(6, 1, 2, '2024-02-05', '2024-02-08', NULL,          'In Transit', 'Tiruppur',    900.00),
(7, 3, 3, '2024-02-10', '2024-02-13', '2024-02-13', 'Delivered',  'Pune',       1800.00),
(8, 3, 1, '2024-02-14', '2024-02-17', '2024-02-20', 'Delayed',    'Mumbai',     2100.00),
(1, 2, 4, '2024-02-20', '2024-02-23', '2024-02-23', 'Delivered',  'Chennai',    1300.00),
(2, 4, 2, '2024-03-01', '2024-03-04', '2024-03-04', 'Delivered',  'Madurai',     950.00),
(3, 1, 1, '2024-03-05', '2024-03-08', '2024-03-10', 'Delayed',    'Coimbatore', 1050.00),
(4, 4, 3, '2024-03-10', '2024-03-13', '2024-03-13', 'Delivered',  'Bengaluru',  1500.00),
(5, 2, 2, '2024-03-15', '2024-03-18', NULL,          'In Transit', 'Hyderabad',  1700.00),
(6, 3, 4, '2024-03-20', '2024-03-23', '2024-03-23', 'Delivered',  'Tiruppur',    880.00),
(7, 1, 1, '2024-04-01', '2024-04-04', '2024-04-04', 'Delivered',  'Pune',       1900.00),
(8, 2, 3, '2024-04-05', '2024-04-08', '2024-04-11', 'Delayed',    'Mumbai',     2200.00),
(1, 4, 2, '2024-04-10', '2024-04-13', '2024-04-13', 'Delivered',  'Chennai',    1250.00),
(3, 3, 4, '2024-04-15', '2024-04-18', '2024-04-18', 'Delivered',  'Coimbatore', 1150.00),
(5, 1, 1, '2024-04-20', '2024-04-23', NULL,          'In Transit', 'Hyderabad',  1650.00),
(2, 2, 3, '2024-04-25', '2024-04-28', '2024-04-30', 'Delayed',    'Madurai',     870.00);

-- Shipment Items
INSERT INTO shipment_items (shipment_id, product_id, quantity, total_price) VALUES
(1,  1, 2,  9000.00),
(2,  2, 5,  4000.00),
(3,  3, 1, 12000.00),
(4,  4, 3,  9600.00),
(5,  5, 4,  6000.00),
(6,  6, 2, 12000.00),
(7,  7, 6, 13200.00),
(8,  8, 8,  7600.00),
(9,  1, 3, 13500.00),
(10, 2, 4,  3200.00),
(11, 3, 2, 24000.00),
(12, 4, 5, 16000.00),
(13, 5, 3,  4500.00),
(14, 6, 1,  6000.00),
(15, 7, 4,  8800.00),
(16, 8, 6,  5700.00),
(17, 1, 2,  9000.00),
(18, 3, 1, 12000.00),
(19, 5, 5,  7500.00),
(20, 2, 3,  2400.00);

-- Check row counts in all tables
SELECT 'customers'       AS table_name, COUNT(*) AS `rows` FROM customers      UNION ALL
SELECT 'warehouses',                    COUNT(*)            FROM warehouses     UNION ALL
SELECT 'carriers',                      COUNT(*)            FROM carriers       UNION ALL
SELECT 'products',                      COUNT(*)            FROM products       UNION ALL
SELECT 'shipments',                     COUNT(*)            FROM shipments      UNION ALL
SELECT 'shipment_items',                COUNT(*)            FROM shipment_items;

-- Preview shipments with all joined names

SELECT 
    s.shipment_id,
    c.customer_name,
    w.warehouse_name,
    ca.carrier_name,
    s.shipment_date,
    s.delivery_status,
    s.freight_cost
FROM shipments s
JOIN customers  c  ON s.customer_id  = c.customer_id
JOIN warehouses w  ON s.warehouse_id = w.warehouse_id
JOIN carriers   ca ON s.carrier_id   = ca.carrier_id
LIMIT 5;

-- Check delay rate by carrier

SELECT 
    ca.carrier_name,
    COUNT(*) AS total_shipments,
    SUM(CASE WHEN s.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS 'delayed',
    ROUND(SUM(CASE WHEN s.delivery_status = 'Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS delay_pct
FROM shipments s
JOIN carriers ca ON s.carrier_id = ca.carrier_id
GROUP BY ca.carrier_name
ORDER BY delay_pct DESC;

