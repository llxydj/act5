<?php
/**
 * User Registration API
 * POST /users/register.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError("Method not allowed", 405);
}

// Get input data
$data = getJsonInput();

// Validate required fields
validateRequired($data, ['firebase_uid', 'email', 'name', 'role']);

try {
    $database = new Database();
    $db = $database->getConnection();

    // Check if user already exists
    $checkQuery = "SELECT id FROM users WHERE firebase_uid = :firebase_uid OR email = :email";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(":firebase_uid", $data['firebase_uid']);
    $checkStmt->bindParam(":email", $data['email']);
    $checkStmt->execute();

    if ($checkStmt->rowCount() > 0) {
        sendError("User already exists", 409);
    }

    // Insert new user
    $query = "INSERT INTO users (firebase_uid, email, name, role, phone, address) 
              VALUES (:firebase_uid, :email, :name, :role, :phone, :address)";
    
    $stmt = $db->prepare($query);
    
    $firebase_uid = sanitize($data['firebase_uid']);
    $email = sanitize($data['email']);
    $name = sanitize($data['name']);
    $role = sanitize($data['role']);
    $phone = isset($data['phone']) ? sanitize($data['phone']) : null;
    $address = isset($data['address']) ? sanitize($data['address']) : null;
    
    $stmt->bindParam(":firebase_uid", $firebase_uid);
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":role", $role);
    $stmt->bindParam(":phone", $phone);
    $stmt->bindParam(":address", $address);

    if ($stmt->execute()) {
        $userId = $db->lastInsertId();
        
        // Get created user
        $getQuery = "SELECT * FROM users WHERE id = :id";
        $getStmt = $db->prepare($getQuery);
        $getStmt->bindParam(":id", $userId);
        $getStmt->execute();
        
        $user = $getStmt->fetch();
        
        sendSuccess($user, "User registered successfully", 201);
    } else {
        sendError("Failed to register user", 500);
    }
} catch (Exception $e) {
    error_log("Registration error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

