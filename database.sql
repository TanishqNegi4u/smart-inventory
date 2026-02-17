CREATE DATABASE IF NOT EXISTS inventory_pro;
USE inventory_pro;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255),
    role ENUM('ADMIN', 'MANAGER')
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    stock INT,
    price DECIMAL(10,2),
    sales_30d INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO users (username, password, role) VALUES 
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN'),
('manager', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'MANAGER');
-- Default password for both: admin123

INSERT INTO products (name, category, stock, price, sales_30d) VALUES 
('iPhone 15', 'Electronics', 50, 79999, 120),
('Laptop Dell', 'Electronics', 25, 65999, 80),
('T-Shirt', 'Apparel', 200, 599, 450),
('Samsung TV 55"', 'Electronics', 15, 54999, 40),
('Running Shoes', 'Footwear', 80, 3999, 200),
('Coffee Maker', 'Appliances', 30, 4599, 60),
('Wireless Headphones', 'Electronics', 45, 8999, 150),
('Yoga Mat', 'Sports', 100, 1299, 300);