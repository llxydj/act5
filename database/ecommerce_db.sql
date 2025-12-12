-- =====================================================
-- SwiftCart E-Commerce Database Schema
-- MySQL Database for phpMyAdmin (XAMPP)
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

-- =====================================================
-- USERS TABLE
-- Stores all user information (Admin, Seller, Buyer)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firebase_uid VARCHAR(128) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role ENUM('admin', 'seller', 'buyer') NOT NULL DEFAULT 'buyer',
    phone VARCHAR(20) NULL,
    address TEXT NULL,
    profile_image LONGTEXT NULL COMMENT 'Base64 encoded image',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_firebase_uid (firebase_uid),
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- CATEGORIES TABLE
-- Product categories
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    icon_name VARCHAR(50) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_name (name),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PRODUCTS TABLE
-- All product listings
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    image_base64 LONGTEXT NULL COMMENT 'Base64 encoded product image',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    
    INDEX idx_seller (seller_id),
    INDEX idx_category (category_id),
    INDEX idx_active (is_active),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ORDERS TABLE
-- Customer orders
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    status ENUM('pending', 'shipped', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_address TEXT NOT NULL,
    phone VARCHAR(20) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_buyer (buyer_id),
    INDEX idx_seller (seller_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ORDER ITEMS TABLE
-- Individual items within orders
-- =====================================================
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    image_base64 LONGTEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERT DEFAULT CATEGORIES
-- =====================================================
INSERT INTO categories (name, description, icon_name) VALUES
('Electronics', 'Phones, Laptops, Gadgets', 'devices'),
('Fashion', 'Clothing, Shoes, Accessories', 'checkroom'),
('Home & Garden', 'Furniture, Decor, Tools', 'home'),
('Sports', 'Sports Equipment, Fitness', 'sports_soccer'),
('Books', 'Books, Magazines, Educational', 'menu_book'),
('Beauty', 'Cosmetics, Skincare, Personal Care', 'spa'),
('Food & Beverages', 'Groceries, Snacks, Drinks', 'restaurant'),
('Toys & Games', 'Toys, Board Games, Video Games', 'toys'),
('Automotive', 'Car Parts, Accessories', 'directions_car'),
('Health', 'Medical Supplies, Supplements', 'medical_services');

-- =====================================================
-- CREATE ADMIN USER (Optional - for testing)
-- =====================================================
-- Note: In production, create admin through Firebase Auth
-- INSERT INTO users (firebase_uid, email, name, role) VALUES
-- ('admin_uid_placeholder', 'admin@shopease.com', 'Admin User', 'admin');

-- =====================================================
-- VIEWS FOR REPORTING
-- =====================================================

-- View: Product with Seller Info
CREATE OR REPLACE VIEW v_products_with_seller AS
SELECT 
    p.*,
    u.name as seller_name,
    u.email as seller_email,
    c.name as category_name
FROM products p
LEFT JOIN users u ON p.seller_id = u.id
LEFT JOIN categories c ON p.category_id = c.id;

-- View: Orders with User Info
CREATE OR REPLACE VIEW v_orders_with_users AS
SELECT 
    o.*,
    buyer.name as buyer_name,
    buyer.email as buyer_email,
    seller.name as seller_name,
    seller.email as seller_email
FROM orders o
LEFT JOIN users buyer ON o.buyer_id = buyer.id
LEFT JOIN users seller ON o.seller_id = seller.id;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Get Seller Statistics
CREATE PROCEDURE IF NOT EXISTS GetSellerStats(IN p_seller_id INT)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM products WHERE seller_id = p_seller_id) as total_products,
        (SELECT COUNT(*) FROM orders WHERE seller_id = p_seller_id) as total_orders,
        (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE seller_id = p_seller_id AND status = 'completed') as total_revenue,
        (SELECT COUNT(*) FROM orders WHERE seller_id = p_seller_id AND status = 'pending') as pending_orders;
END //

-- Get Admin Statistics
CREATE PROCEDURE IF NOT EXISTS GetAdminStats()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM users) as total_users,
        (SELECT COUNT(*) FROM users WHERE role = 'seller') as total_sellers,
        (SELECT COUNT(*) FROM users WHERE role = 'buyer') as total_buyers,
        (SELECT COUNT(*) FROM products) as total_products,
        (SELECT COUNT(*) FROM orders) as total_orders,
        (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status = 'completed') as total_revenue;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Update stock when order is placed
CREATE TRIGGER IF NOT EXISTS after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity 
    WHERE id = NEW.product_id;
END //

-- Restore stock when order is cancelled
CREATE TRIGGER IF NOT EXISTS after_order_cancelled
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE products p
        INNER JOIN order_items oi ON p.id = oi.product_id
        SET p.stock_quantity = p.stock_quantity + oi.quantity
        WHERE oi.order_id = NEW.id;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- GRANT PERMISSIONS (Adjust as needed)
-- =====================================================
-- GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'your_user'@'localhost';
-- FLUSH PRIVILEGES;

