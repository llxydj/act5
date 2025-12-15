-- Migration: Add firestore_image_id column to products table
-- This migration adds support for Firestore Base64 image storage
-- Run this after updating the application code

USE ecommerce_db;

-- Add firestore_image_id column to products table
ALTER TABLE products 
ADD COLUMN firestore_image_id VARCHAR(100) NULL COMMENT 'Firestore document ID for Base64 image' AFTER image_url;

-- Add firestore_image_id column to order_items table for consistency
ALTER TABLE order_items 
ADD COLUMN firestore_image_id VARCHAR(100) NULL COMMENT 'Firestore document ID for Base64 image' AFTER image_url;

-- Note: 
-- - firestore_image_id is the primary method for new products (Firestore Base64)
-- - image_url is kept for backward compatibility (Firebase Storage)
-- - image_base64 is kept for backward compatibility (MySQL Base64)

