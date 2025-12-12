# SwiftCart API Documentation

## Base URL
```
http://localhost/ecommerce_api
```

## Response Format
All API responses follow this structure:

```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

## Error Response
```json
{
  "success": false,
  "message": "Error message",
  "data": null
}
```

## HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `405` - Method Not Allowed
- `409` - Conflict
- `500` - Server Error

---

## Users API

### Register User
`POST /users/register.php`

**Request Body:**
```json
{
  "firebase_uid": "abc123xyz",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "buyer",
  "phone": "+1234567890",
  "address": "123 Main St, City"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "firebase_uid": "abc123xyz",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "buyer",
    ...
  }
}
```

### Get User by Firebase UID
`GET /users/get_user.php?firebase_uid=abc123xyz`

**Response (200):**
```json
{
  "success": true,
  "message": "User found",
  "data": {
    "id": 1,
    "firebase_uid": "abc123xyz",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "buyer",
    ...
  }
}
```

### Update User Profile
`PUT /users/update_user.php`

**Request Body:**
```json
{
  "id": 1,
  "name": "John Updated",
  "phone": "+1234567890",
  "address": "456 New St"
}
```

### Get All Users (Admin)
`GET /users/get_all_users.php`
`GET /users/get_all_users.php?role=seller`

### Update User Role (Admin)
`PUT /users/update_user_role.php`

**Request Body:**
```json
{
  "id": 1,
  "role": "seller"
}
```

### Delete User (Admin)
`DELETE /users/delete_user.php?id=1`

### Get Admin Statistics
`GET /users/get_admin_stats.php`

**Response:**
```json
{
  "success": true,
  "data": {
    "total_users": 100,
    "total_sellers": 20,
    "total_buyers": 75,
    "total_products": 500,
    "total_orders": 250,
    "total_revenue": 15000.00
  }
}
```

---

## Products API

### Get All Products
`GET /products/get_products.php`

**Query Parameters:**
- `seller_id` - Filter by seller
- `category_id` - Filter by category
- `search` - Search in name/description
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20, max: 50)

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### Get Single Product
`GET /products/get_product.php?id=1`

### Add Product
`POST /products/add_product.php`

**Request Body:**
```json
{
  "seller_id": 1,
  "name": "Product Name",
  "description": "Product description",
  "price": 29.99,
  "stock_quantity": 100,
  "category_id": 1,
  "image_base64": "base64_encoded_image_string"
}
```

### Update Product
`PUT /products/update_product.php`

**Request Body:**
```json
{
  "id": 1,
  "name": "Updated Name",
  "price": 34.99,
  "stock_quantity": 50,
  "is_active": 1
}
```

### Delete Product
`DELETE /products/delete_product.php?id=1`

### Get Seller Statistics
`GET /products/get_seller_stats.php?seller_id=1`

**Response:**
```json
{
  "success": true,
  "data": {
    "total_products": 25,
    "total_orders": 100,
    "pending_orders": 10,
    "total_revenue": 5000.00
  }
}
```

---

## Categories API

### Get All Categories
`GET /categories/get_categories.php`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Electronics",
      "description": "Phones, Laptops, Gadgets",
      "icon_name": "devices"
    },
    ...
  ]
}
```

---

## Orders API

### Create Order
`POST /orders/create_order.php`

**Request Body:**
```json
{
  "buyer_id": 1,
  "buyer_name": "John Doe",
  "buyer_email": "john@example.com",
  "shipping_address": "123 Main St, City",
  "phone": "+1234567890",
  "notes": "Please handle with care",
  "total_amount": 99.99,
  "items": [
    {
      "product_id": 1,
      "product_name": "Product A",
      "price": 29.99,
      "quantity": 2,
      "image_base64": "..."
    },
    {
      "product_id": 2,
      "product_name": "Product B",
      "price": 40.01,
      "quantity": 1
    }
  ]
}
```

**Note:** Orders are automatically grouped by seller if items belong to different sellers.

### Get Buyer Orders
`GET /orders/get_buyer_orders.php?buyer_id=1`

### Get Seller Orders
`GET /orders/get_seller_orders.php?seller_id=1`
`GET /orders/get_seller_orders.php?seller_id=1&status=pending`

### Get All Orders (Admin)
`GET /orders/get_all_orders.php`
`GET /orders/get_all_orders.php?status=pending`

### Get Single Order
`GET /orders/get_order.php?id=1`

### Update Order Status
`PUT /orders/update_order_status.php`

**Request Body:**
```json
{
  "id": 1,
  "status": "shipped"
}
```

**Valid statuses:** `pending`, `shipped`, `completed`, `cancelled`

**Note:** When status is changed to `cancelled`, product stock is automatically restored.

---

## Database Schema

### users
| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| firebase_uid | VARCHAR(128) | Firebase Auth UID |
| email | VARCHAR(255) | User email |
| name | VARCHAR(255) | Full name |
| role | ENUM | admin/seller/buyer |
| phone | VARCHAR(20) | Phone number |
| address | TEXT | Address |
| profile_image | LONGTEXT | Base64 image |
| is_active | TINYINT | Active status |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

### products
| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| seller_id | INT | FK to users |
| category_id | INT | FK to categories |
| name | VARCHAR(255) | Product name |
| description | TEXT | Description |
| price | DECIMAL(10,2) | Price |
| stock_quantity | INT | Stock count |
| image_base64 | LONGTEXT | Base64 image |
| is_active | TINYINT | Active status |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |

### orders
| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| buyer_id | INT | FK to users |
| seller_id | INT | FK to users |
| status | ENUM | pending/shipped/completed/cancelled |
| total_amount | DECIMAL(10,2) | Total |
| shipping_address | TEXT | Address |
| phone | VARCHAR(20) | Phone |
| notes | TEXT | Notes |
| created_at | TIMESTAMP | Creation date |
| updated_at | TIMESTAMP | Last update |
| shipped_at | TIMESTAMP | Shipped date |
| completed_at | TIMESTAMP | Completion date |

### order_items
| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| order_id | INT | FK to orders |
| product_id | INT | FK to products |
| product_name | VARCHAR(255) | Name at purchase |
| price | DECIMAL(10,2) | Price at purchase |
| quantity | INT | Quantity |
| image_base64 | LONGTEXT | Base64 image |

### categories
| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Category name |
| description | TEXT | Description |
| icon_name | VARCHAR(50) | Icon identifier |
| is_active | TINYINT | Active status |

