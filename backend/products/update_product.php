<?php
/**
 * Update Product
 * PUT /products/update_product.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow PUT
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    sendError("Method not allowed", 405);
}

// Get input data
$data = getJsonInput();

// Validate required field
validateRequired($data, ['id']);

try {
    $database = new Database();
    $db = $database->getConnection();

    // Build update query dynamically
    $updates = [];
    $params = [':id' => sanitize($data['id'])];
    
    $allowedFields = ['name', 'description', 'price', 'stock_quantity', 'category_id', 'image_base64', 'is_active'];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field])) {
            $updates[] = "$field = :$field";
            if ($field === 'image_base64') {
                $params[":$field"] = $data[$field];
            } elseif ($field === 'price') {
                $params[":$field"] = (float) $data[$field];
            } elseif ($field === 'stock_quantity' || $field === 'is_active') {
                $params[":$field"] = (int) $data[$field];
            } else {
                $params[":$field"] = sanitize($data[$field]);
            }
        }
    }

    if (empty($updates)) {
        sendError("No fields to update", 400);
    }

    $query = "UPDATE products SET " . implode(", ", $updates) . " WHERE id = :id";
    $stmt = $db->prepare($query);

    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, "Product updated successfully");
        } else {
            sendError("Product not found or no changes made", 404);
        }
    } else {
        sendError("Failed to update product", 500);
    }
} catch (Exception $e) {
    error_log("Update product error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

