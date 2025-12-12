<?php
/**
 * Update User Profile
 * PUT /users/update_user.php
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

// Validate required field
validateRequired($data, ['id']);

try {
    $database = new Database();
    $db = $database->getConnection();

    // Build update query dynamically
    $updates = [];
    $params = [':id' => sanitize($data['id'])];
    
    $allowedFields = ['name', 'phone', 'address', 'profile_image'];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field])) {
            $updates[] = "$field = :$field";
            $params[":$field"] = $field === 'profile_image' ? $data[$field] : sanitize($data[$field]);
        }
    }

    if (empty($updates)) {
        sendError("No fields to update", 400);
    }

    $query = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = :id";
    $stmt = $db->prepare($query);

    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }

    if ($stmt->execute()) {
        // Get updated user
        $getQuery = "SELECT * FROM users WHERE id = :id";
        $getStmt = $db->prepare($getQuery);
        $getStmt->bindParam(":id", $params[':id']);
        $getStmt->execute();
        
        $user = $getStmt->fetch();
        
        sendSuccess($user, "User updated successfully");
    } else {
        sendError("Failed to update user", 500);
    }
} catch (Exception $e) {
    error_log("Update user error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

