<?php
/**
 * Update Product
 * PUT /products/update_product.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';
require_once '../helpers/auth.php';

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
    
    // SECURITY FIX: Verify user owns this product (seller) or is admin
    $user = requireAuth($db);
    $productId = sanitize($data['id']);
    
    // Check if user owns the product or is admin
    $checkQuery = "SELECT seller_id FROM products WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(":id", $productId);
    $checkStmt->execute();
    $product = $checkStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$product) {
        sendError("Product not found", 404);
    }
    
    // Only seller who owns the product or admin can update
    if ($product['seller_id'] != $user['id'] && $user['role'] !== 'admin') {
        sendError("Access denied. You don't have permission to update this product.", 403);
    }

    // Build update query dynamically
    $updates = [];
    $params = [':id' => $productId];
    
    // Support both image_url (Firebase Storage) and image_base64 (legacy)
    $allowedFields = ['name', 'description', 'price', 'stock_quantity', 'category_id', 'image_base64', 'image_url', 'is_active'];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field])) {
            $updates[] = "$field = :$field";
            if ($field === 'image_base64') {
                $params[":$field"] = $data[$field];
            } elseif ($field === 'image_url') {
                $params[":$field"] = sanitize($data[$field]);
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

