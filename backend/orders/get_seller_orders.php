<?php
/**
 * Get Seller Orders
 * GET /orders/get_seller_orders.php?seller_id=xxx&status=xxx
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Method not allowed", 405);
}

// Validate required parameter
if (!isset($_GET['seller_id']) || empty($_GET['seller_id'])) {
    sendError("Seller ID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $seller_id = sanitize($_GET['seller_id']);

    // Base query
    $query = "SELECT o.*, buyer.name as buyer_name, buyer.email as buyer_email, 
                     seller.name as seller_name, seller.email as seller_email
              FROM orders o
              LEFT JOIN users buyer ON o.buyer_id = buyer.id
              LEFT JOIN users seller ON o.seller_id = seller.id
              WHERE o.seller_id = :seller_id";
    
    $params = [':seller_id' => $seller_id];

    // Filter by status if provided
    if (isset($_GET['status']) && !empty($_GET['status'])) {
        $query .= " AND o.status = :status";
        $params[':status'] = sanitize($_GET['status']);
    }

    $query .= " ORDER BY o.created_at DESC";
    
    $stmt = $db->prepare($query);
    
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    
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
    error_log("Get seller orders error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

