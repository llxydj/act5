<?php
/**
 * Get Buyer Orders
 * GET /orders/get_buyer_orders.php?buyer_id=xxx
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Method not allowed", 405);
}

// Validate required parameter
if (!isset($_GET['buyer_id']) || empty($_GET['buyer_id'])) {
    sendError("Buyer ID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $buyer_id = sanitize($_GET['buyer_id']);

    // Get orders
    $query = "SELECT o.*, buyer.name as buyer_name, buyer.email as buyer_email, 
                     seller.name as seller_name, seller.email as seller_email
              FROM orders o
              LEFT JOIN users buyer ON o.buyer_id = buyer.id
              LEFT JOIN users seller ON o.seller_id = seller.id
              WHERE o.buyer_id = :buyer_id
              ORDER BY o.created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":buyer_id", $buyer_id);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();

    // Get items for each order
    $itemsQuery = "SELECT * FROM order_items WHERE order_id = :order_id";
    $itemsStmt = $db->prepare($itemsQuery);
    
    foreach ($orders as &$order) {
        $itemsStmt->bindParam(":order_id", $order['id']);
        $itemsStmt->execute();
        $order['items'] = $itemsStmt->fetchAll();
    }

    sendSuccess($orders, "Orders retrieved successfully");
} catch (Exception $e) {
    error_log("Get buyer orders error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

