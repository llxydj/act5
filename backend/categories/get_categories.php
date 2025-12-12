<?php
/**
 * Get All Categories
 * GET /categories/get_categories.php
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

    $query = "SELECT * FROM categories WHERE is_active = 1 ORDER BY name ASC";
    $stmt = $db->query($query);
    
    $categories = $stmt->fetchAll();
    
    sendSuccess($categories, "Categories retrieved successfully");
} catch (Exception $e) {
    error_log("Get categories error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

