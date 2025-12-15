-- =====================================================
-- Migration: Add firestore_image_id column
-- This migration adds support for Firestore Base64 image storage
-- Run this on existing databases that were created before Firestore image support
-- =====================================================

USE ecommerce_db;

-- Add firestore_image_id column to products table
-- Note: If column already exists, you'll get an error - that's okay, just skip it
ALTER TABLE products 
ADD COLUMN firestore_image_id VARCHAR(100) NULL COMMENT 'Firestore document ID for Base64 image' AFTER image_url;

-- Add firestore_image_id column to order_items table
-- Note: If column already exists, you'll get an error - that's okay, just skip it
ALTER TABLE order_items 
ADD COLUMN firestore_image_id VARCHAR(100) NULL COMMENT 'Firestore document ID for Base64 image' AFTER image_url;

-- =====================================================
-- Migration Notes:
-- =====================================================
-- - firestore_image_id is the PRIMARY method for new products (Firestore Base64)
-- - image_url is kept for backward compatibility (Firebase Storage URLs)
-- - image_base64 is kept for backward compatibility (MySQL Base64 storage)
-- 
-- Image Display Priority (in Flutter app):
-- 1. firestore_image_id (fetch Base64 from Firestore)
-- 2. image_url (Firebase Storage URL)
-- 3. image_base64 (MySQL Base64 - legacy)
--
-- If you get "Duplicate column name" error, the migration was already applied.

