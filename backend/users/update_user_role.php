<?php
/**
 * Update User Role (Admin)
 * PUT /users/update_user_role.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow PUT
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    sendError("Method not allowed", 405);
}

// Get input data
$data = getJsonInput();

// Validate required fields
validateRequired($data, ['id', 'role']);

// Validate role
$validRoles = ['admin', 'seller', 'buyer'];
if (!in_array($data['role'], $validRoles)) {
    sendError("Invalid role. Must be: admin, seller, or buyer", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    $id = sanitize($data['id']);
    $role = sanitize($data['role']);

    $query = "UPDATE users SET role = :role WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $id);
    $stmt->bindParam(":role", $role);

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, "User role updated successfully");
        } else {
            sendError("User not found", 404);
        }
    } else {
        sendError("Failed to update role", 500);
    }
} catch (Exception $e) {
    error_log("Update role error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

