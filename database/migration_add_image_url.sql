-- Migration: Add image_url column to products table
-- This migration adds support for Firebase Storage URLs
-- Run this after updating the application code

USE ecommerce_db;

-- Add image_url column to products table
ALTER TABLE products 
ADD COLUMN image_url VARCHAR(500) NULL COMMENT 'Firebase Storage URL' AFTER image_base64;

-- Add image_url column to order_items table for consistency
ALTER TABLE order_items 
ADD COLUMN image_url VARCHAR(500) NULL COMMENT 'Firebase Storage URL' AFTER image_base64;

-- Note: image_base64 is kept for backward compatibility with existing data
-- New products should use image_url (Firebase Storage) instead of image_base64

