<?php
/**
 * Get All Users (Admin)
 * GET /users/get_all_users.php?role=xxx
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

    $query = "SELECT id, firebase_uid, email, name, role, phone, address, profile_image, is_active, created_at, updated_at FROM users";
    $params = [];

    // Filter by role if provided
    if (isset($_GET['role']) && !empty($_GET['role'])) {
        $query .= " WHERE role = :role";
        $params[':role'] = sanitize($_GET['role']);
    }

    $query .= " ORDER BY created_at DESC";

    $stmt = $db->prepare($query);
    
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    
    $stmt->execute();
    
    $users = $stmt->fetchAll();
    
    sendSuccess($users, "Users retrieved successfully");
} catch (Exception $e) {
    error_log("Get all users error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

