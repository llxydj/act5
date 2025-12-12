<?php
/**
 * Add New Product
 * POST /products/add_product.php
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
validateRequired($data, ['seller_id', 'name', 'description', 'price', 'stock_quantity']);

try {
    $database = new Database();
    $db = $database->getConnection();

    // Verify seller exists
    $checkQuery = "SELECT id FROM users WHERE id = :seller_id AND role = 'seller'";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(":seller_id", $data['seller_id']);
    $checkStmt->execute();

    if ($checkStmt->rowCount() === 0) {
        sendError("Invalid seller ID", 400);
    }

    // Insert product
    $query = "INSERT INTO products (seller_id, category_id, name, description, price, stock_quantity, image_base64) 
              VALUES (:seller_id, :category_id, :name, :description, :price, :stock_quantity, :image_base64)";
    
    $stmt = $db->prepare($query);
    
    $seller_id = sanitize($data['seller_id']);
    $category_id = isset($data['category_id']) && !empty($data['category_id']) ? sanitize($data['category_id']) : null;
    $name = sanitize($data['name']);
    $description = sanitize($data['description']);
    $price = (float) $data['price'];
    $stock_quantity = (int) $data['stock_quantity'];
    $image_base64 = isset($data['image_base64']) ? $data['image_base64'] : null;
    
    $stmt->bindParam(":seller_id", $seller_id);
    $stmt->bindParam(":category_id", $category_id);
    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":description", $description);
    $stmt->bindParam(":price", $price);
    $stmt->bindParam(":stock_quantity", $stock_quantity);
    $stmt->bindParam(":image_base64", $image_base64);

    if ($stmt->execute()) {
        $productId = $db->lastInsertId();
        
        // Get created product
        $getQuery = "SELECT p.*, u.name as seller_name, c.name as category_name 
                     FROM products p 
                     LEFT JOIN users u ON p.seller_id = u.id 
                     LEFT JOIN categories c ON p.category_id = c.id 
                     WHERE p.id = :id";
        $getStmt = $db->prepare($getQuery);
        $getStmt->bindParam(":id", $productId);
        $getStmt->execute();
        
        $product = $getStmt->fetch();
        
        sendSuccess($product, "Product added successfully", 201);
    } else {
        sendError("Failed to add product", 500);
    }
} catch (Exception $e) {
    error_log("Add product error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

