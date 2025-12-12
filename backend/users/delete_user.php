<?php
/**
 * Delete User (Admin)
 * DELETE /users/delete_user.php?id=xxx
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow DELETE
if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    sendError("Method not allowed", 405);
}

// Validate required parameter
if (!isset($_GET['id']) || empty($_GET['id'])) {
    sendError("User ID is required", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $id = sanitize($_GET['id']);

    $query = "DELETE FROM users WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $id);

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, "User deleted successfully");
        } else {
            sendError("User not found", 404);
        }
    } else {
        sendError("Failed to delete user", 500);
    }
} catch (Exception $e) {
    error_log("Delete user error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

