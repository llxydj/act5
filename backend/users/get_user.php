<?php
/**
 * Get User by Firebase UID
 * GET /users/get_user.php?firebase_uid=xxx
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Method not allowed", 405);
}

// Validate required parameter
if (!isset($_GET['firebase_uid']) || empty($_GET['firebase_uid'])) {
    sendError("Firebase UID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $firebase_uid = sanitize($_GET['firebase_uid']);

    $query = "SELECT * FROM users WHERE firebase_uid = :firebase_uid";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":firebase_uid", $firebase_uid);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch();
        sendSuccess($user, "User found");
    } else {
        sendError("User not found", 404);
    }
} catch (Exception $e) {
    error_log("Get user error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

