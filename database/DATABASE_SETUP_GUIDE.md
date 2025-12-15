# Database Setup Guide for Firestore Image Storage

This guide explains how to set up your MySQL database to support Firestore Base64 image storage.

## Overview

The application uses a **hybrid image storage approach** with three methods (in priority order):

1. **Firestore Base64** (Primary) - `firestore_image_id` column stores Firestore document ID
2. **Firebase Storage URL** (Legacy) - `image_url` column stores Firebase Storage URLs
3. **MySQL Base64** (Legacy) - `image_base64` column stores Base64 strings directly in MySQL

## Setup Instructions

### Option 1: Fresh Database Installation

If you're creating a **new database**, use the main schema file:

```bash
# In phpMyAdmin or MySQL command line:
mysql -u root -p < database/ecommerce_db.sql
```

The main schema (`ecommerce_db.sql`) now includes the `firestore_image_id` column in both `products` and `order_items` tables.

### Option 2: Existing Database Migration

If you have an **existing database**, run the migration:

```bash
# In phpMyAdmin or MySQL command line:
mysql -u root -p < database/migration_add_firestore_image_id.sql
```

**OR** manually in phpMyAdmin:
1. Select your `ecommerce_db` database
2. Go to SQL tab
3. Copy and paste the contents of `migration_add_firestore_image_id.sql`
4. Click "Go"

**Note:** If you get a "Duplicate column name" error, the migration was already applied - you can ignore it.

## Database Schema

### Products Table

```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    image_base64 LONGTEXT NULL COMMENT 'Base64 encoded product image (legacy)',
    image_url VARCHAR(500) NULL COMMENT 'Firebase Storage URL (legacy)',
    firestore_image_id VARCHAR(100) NULL COMMENT 'Firestore document ID for Base64 image (preferred)',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- ... foreign keys and indexes
);
```

### Order Items Table

```sql
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    image_base64 LONGTEXT NULL COMMENT 'Base64 encoded image (legacy)',
    image_url VARCHAR(500) NULL COMMENT 'Firebase Storage URL (legacy)',
    firestore_image_id VARCHAR(100) NULL COMMENT 'Firestore document ID for Base64 image (preferred)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- ... foreign keys and indexes
);
```

## Verification

After running the migration, verify the columns exist:

```sql
USE ecommerce_db;

-- Check products table
DESCRIBE products;
-- Should show: firestore_image_id | varchar(100) | YES | NULL

-- Check order_items table
DESCRIBE order_items;
-- Should show: firestore_image_id | varchar(100) | YES | NULL
```

## How It Works

### Image Storage Flow

1. **Upload**: When a seller adds/edits a product:
   - Image is compressed (300-500px width, JPEG quality 75)
   - Base64 string is stored in Firestore `images` collection
   - Firestore document ID is saved in MySQL `firestore_image_id` column

2. **Display**: When displaying products:
   - App checks `firestore_image_id` first
   - If present, fetches Base64 from Firestore
   - Falls back to `image_url` (Firebase Storage) if not found
   - Falls back to `image_base64` (MySQL) as last resort

### Backend PHP Support

All backend PHP files support `firestore_image_id`:

- ✅ `add_product.php` - Inserts `firestore_image_id`
- ✅ `update_product.php` - Updates `firestore_image_id`
- ✅ `get_products.php` - Returns `firestore_image_id` (via `SELECT p.*`)
- ✅ `get_product.php` - Returns `firestore_image_id` (via `SELECT p.*`)
- ✅ `create_order.php` - Copies `firestore_image_id` to order items

## Troubleshooting

### Error: "Duplicate column name 'firestore_image_id'"

**Solution:** The migration was already applied. Your database is up to date. No action needed.

### Error: "Table 'products' doesn't exist"

**Solution:** Run the main schema file first:
```bash
mysql -u root -p < database/ecommerce_db.sql
```

### Images Not Displaying

1. **Check Firestore**: Ensure Firestore is enabled in Firebase Console
2. **Check Column**: Verify `firestore_image_id` column exists:
   ```sql
   DESCRIBE products;
   ```
3. **Check Data**: Verify products have `firestore_image_id` values:
   ```sql
   SELECT id, name, firestore_image_id FROM products LIMIT 5;
   ```

## Migration Files

- `ecommerce_db.sql` - Main schema (includes `firestore_image_id` for new installations)
- `migration_add_firestore_image_id.sql` - Migration for existing databases
- `migration_add_image_url.sql` - Legacy migration (for reference)

## Next Steps

After database setup:

1. ✅ Run `flutter pub get` to install dependencies
2. ✅ Ensure Firestore is enabled in Firebase Console
3. ✅ Test adding a product with an image
4. ✅ Verify image displays correctly in product list

## Support

If you encounter issues:
1. Check the Flutter console for errors
2. Check PHP error logs (XAMPP/phpMyAdmin)
3. Verify Firestore rules allow read/write access
4. Ensure Firebase project is properly configured

