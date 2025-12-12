<?php
/**
 * Delete Product
 * DELETE /products/delete_product.php?id=xxx
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';
require_once '../helpers/auth.php';

// Only allow DELETE
if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    sendError("Method not allowed", 405);
}

// Validate required parameter
if (!isset($_GET['id']) || empty($_GET['id'])) {
    sendError("Product ID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // SECURITY FIX: Verify user owns this product (seller) or is admin
    $user = requireAuth($db);
    $id = sanitize($_GET['id']);
    
    // Check if user owns the product or is admin
    $checkQuery = "SELECT seller_id FROM products WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(":id", $id);
    $checkStmt->execute();
    $product = $checkStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$product) {
        sendError("Product not found", 404);
    }
    
    // Only seller who owns the product or admin can delete
    if ($product['seller_id'] != $user['id'] && $user['role'] !== 'admin') {
        sendError("Access denied. You don't have permission to delete this product.", 403);
    }

    // Check if product has pending orders
    $checkQuery = "SELECT COUNT(*) as count FROM order_items oi 
                   JOIN orders o ON oi.order_id = o.id 
                   WHERE oi.product_id = :id AND o.status = 'pending'";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(":id", $id);
    $checkStmt->execute();
    
    if ((int) $checkStmt->fetch()['count'] > 0) {
        sendError("Cannot delete product with pending orders", 400);
    }

    $query = "DELETE FROM products WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $id);

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, "Product deleted successfully");
        } else {
            sendError("Product not found", 404);
        }
    } else {
        sendError("Failed to delete product", 500);
    }
} catch (Exception $e) {
    error_log("Delete product error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

