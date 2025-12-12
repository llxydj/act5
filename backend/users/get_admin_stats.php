<?php
/**
 * Get Admin Statistics
 * GET /users/get_admin_stats.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Method not allowed", 405);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $stats = [];

    // Total users
    $query = "SELECT COUNT(*) as count FROM users";
    $stmt = $db->query($query);
    $stats['total_users'] = (int) $stmt->fetch()['count'];

    // Total sellers
    $query = "SELECT COUNT(*) as count FROM users WHERE role = 'seller'";
    $stmt = $db->query($query);
    $stats['total_sellers'] = (int) $stmt->fetch()['count'];

    // Total buyers
    $query = "SELECT COUNT(*) as count FROM users WHERE role = 'buyer'";
    $stmt = $db->query($query);
    $stats['total_buyers'] = (int) $stmt->fetch()['count'];

    // Total products
    $query = "SELECT COUNT(*) as count FROM products";
    $stmt = $db->query($query);
    $stats['total_products'] = (int) $stmt->fetch()['count'];

    // Total orders
    $query = "SELECT COUNT(*) as count FROM orders";
    $stmt = $db->query($query);
    $stats['total_orders'] = (int) $stmt->fetch()['count'];

    // Total revenue (completed orders)
    $query = "SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE status = 'completed'";
    $stmt = $db->query($query);
    $stats['total_revenue'] = (float) $stmt->fetch()['total'];

    sendSuccess($stats, "Admin statistics retrieved");
} catch (Exception $e) {
    error_log("Get admin stats error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

