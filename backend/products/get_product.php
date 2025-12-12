<?php
/**
 * Get Single Product
 * GET /products/get_product.php?id=xxx
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Method not allowed", 405);
}

// Validate required parameter
if (!isset($_GET['id']) || empty($_GET['id'])) {
    sendError("Product ID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $id = sanitize($_GET['id']);

    $query = "SELECT p.*, u.name as seller_name, c.name as category_name 
              FROM products p 
              LEFT JOIN users u ON p.seller_id = u.id 
              LEFT JOIN categories c ON p.category_id = c.id 
              WHERE p.id = :id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $product = $stmt->fetch();
        sendSuccess($product, "Product found");
    } else {
        sendError("Product not found", 404);
    }
} catch (Exception $e) {
    error_log("Get product error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

