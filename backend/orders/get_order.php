<?php
/**
 * Get Single Order
 * GET /orders/get_order.php?id=xxx
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
    sendError("Order ID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $id = sanitize($_GET['id']);

    // Get order
    $query = "SELECT o.*, buyer.name as buyer_name, buyer.email as buyer_email, 
                     seller.name as seller_name, seller.email as seller_email
              FROM orders o
              LEFT JOIN users buyer ON o.buyer_id = buyer.id
              LEFT JOIN users seller ON o.seller_id = seller.id
              WHERE o.id = :id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $order = $stmt->fetch();
        
        // Get order items
        $itemsQuery = "SELECT * FROM order_items WHERE order_id = :order_id";
        $itemsStmt = $db->prepare($itemsQuery);
        $itemsStmt->bindParam(":order_id", $id);
        $itemsStmt->execute();
        
        $order['items'] = $itemsStmt->fetchAll();
        
        sendSuccess($order, "Order found");
    } else {
        sendError("Order not found", 404);
    }
} catch (Exception $e) {
    error_log("Get order error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

