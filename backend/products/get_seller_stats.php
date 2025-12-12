<?php
/**
 * Get Seller Statistics
 * GET /products/get_seller_stats.php?seller_id=xxx
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
    $stats = [];

    // Total products
    $query = "SELECT COUNT(*) as count FROM products WHERE seller_id = :seller_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":seller_id", $seller_id);
    $stmt->execute();
    $stats['total_products'] = (int) $stmt->fetch()['count'];

    // Total orders
    $query = "SELECT COUNT(*) as count FROM orders WHERE seller_id = :seller_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":seller_id", $seller_id);
    $stmt->execute();
    $stats['total_orders'] = (int) $stmt->fetch()['count'];

    // Pending orders
    $query = "SELECT COUNT(*) as count FROM orders WHERE seller_id = :seller_id AND status = 'pending'";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":seller_id", $seller_id);
    $stmt->execute();
    $stats['pending_orders'] = (int) $stmt->fetch()['count'];

    // Total revenue (completed orders)
    $query = "SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE seller_id = :seller_id AND status = 'completed'";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":seller_id", $seller_id);
    $stmt->execute();
    $stats['total_revenue'] = (float) $stmt->fetch()['total'];

    sendSuccess($stats, "Seller statistics retrieved");
} catch (Exception $e) {
    error_log("Get seller stats error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

