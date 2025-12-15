<?php
/**
 * Create New Order
 * POST /orders/create_order.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';
require_once '../helpers/auth.php';

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError("Method not allowed", 405);
}

// Get input data
$data = getJsonInput();

// Validate required fields
validateRequired($data, ['shipping_address', 'items']);

// SECURITY FIX: Get buyer info from authenticated user, not from client
try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Require authentication - user must be a buyer
    $user = requireRole($db, ['buyer', 'admin']); // Admin can also create orders for testing
    $buyer_id = $user['id'];
    $buyer_name = $user['name'];
    $buyer_email = $user['email'];

    if (empty($data['items']) || !is_array($data['items'])) {
        sendError("Order must have at least one item", 400);
    }
    
    // Begin transaction
    $db->beginTransaction();

    // Group items by product's seller
    // CRITICAL SECURITY FIX: Fetch prices from database, don't trust client
    $itemsBySeller = [];
    
    foreach ($data['items'] as $item) {
        // Get product details including price and seller
        $productQuery = "SELECT id, seller_id, name, price, stock_quantity, image_base64, image_url, firestore_image_id 
                        FROM products WHERE id = :product_id AND is_active = 1";
        $productStmt = $db->prepare($productQuery);
        $productStmt->bindParam(":product_id", $item['product_id']);
        $productStmt->execute();
        
        $product = $productStmt->fetch(PDO::FETCH_ASSOC);
        if (!$product) {
            $db->rollBack();
            sendError("Product not found or inactive: " . $item['product_id'], 404);
        }
        
        // Validate stock availability
        $requestedQuantity = (int) $item['quantity'];
        if ($requestedQuantity <= 0) {
            $db->rollBack();
            sendError("Invalid quantity for product: " . $item['product_id'], 400);
        }
        
        if ($product['stock_quantity'] < $requestedQuantity) {
            $db->rollBack();
            sendError("Insufficient stock for product: " . $product['name'] . ". Available: " . $product['stock_quantity'], 400);
        }
        
        // SECURITY FIX: Use server-side price, not client-provided price
        $serverPrice = (float) $product['price'];
        $sellerId = $product['seller_id'];
        
        // Override client-provided price with server-side price
        $item['price'] = $serverPrice;
        $item['product_name'] = $product['name'];
        // Priority: Use firestore_image_id if available, then image_url, then image_base64
        if (empty($item['firestore_image_id']) && !empty($product['firestore_image_id'])) {
            $item['firestore_image_id'] = $product['firestore_image_id'];
        }
        if (empty($item['image_url']) && !empty($product['image_url'])) {
            $item['image_url'] = $product['image_url'];
        }
        if (empty($item['image_base64']) && !empty($product['image_base64'])) {
            $item['image_base64'] = $product['image_base64'];
        }
        
        if (!isset($itemsBySeller[$sellerId])) {
            $itemsBySeller[$sellerId] = [];
        }
        $itemsBySeller[$sellerId][] = $item;
    }

    $createdOrders = [];
    
    // Create order for each seller
    foreach ($itemsBySeller as $sellerId => $items) {
        // Calculate total for this seller's items
        $sellerTotal = 0;
        foreach ($items as $item) {
            $sellerTotal += $item['price'] * $item['quantity'];
        }

        // Insert order
        $orderQuery = "INSERT INTO orders (buyer_id, seller_id, status, total_amount, shipping_address, phone, notes) 
                       VALUES (:buyer_id, :seller_id, 'pending', :total_amount, :shipping_address, :phone, :notes)";
        
        $orderStmt = $db->prepare($orderQuery);
        
        $shipping_address = sanitize($data['shipping_address']);
        $phone = isset($data['phone']) ? sanitize($data['phone']) : $user['phone'];
        $notes = isset($data['notes']) ? sanitize($data['notes']) : null;
        
        $orderStmt->bindParam(":buyer_id", $buyer_id);
        $orderStmt->bindParam(":seller_id", $sellerId);
        $orderStmt->bindParam(":total_amount", $sellerTotal);
        $orderStmt->bindParam(":shipping_address", $shipping_address);
        $orderStmt->bindParam(":phone", $phone);
        $orderStmt->bindParam(":notes", $notes);
        
        if (!$orderStmt->execute()) {
            $db->rollBack();
            sendError("Failed to create order", 500);
        }
        
        $orderId = $db->lastInsertId();

        // Insert order items
        foreach ($items as $item) {
            // Support firestore_image_id (preferred), image_url, and image_base64 for backward compatibility
            $itemQuery = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity, image_base64, image_url, firestore_image_id) 
                          VALUES (:order_id, :product_id, :product_name, :price, :quantity, :image_base64, :image_url, :firestore_image_id)";
            
            $itemStmt = $db->prepare($itemQuery);
            
            $product_id = sanitize($item['product_id']);
            $product_name = sanitize($item['product_name']);
            // Price is already validated and set from server-side
            $price = (float) $item['price'];
            $quantity = (int) $item['quantity'];
            $image_base64 = isset($item['image_base64']) ? $item['image_base64'] : null;
            $image_url = isset($item['image_url']) ? sanitize($item['image_url']) : null;
            $firestore_image_id = isset($item['firestore_image_id']) && !empty($item['firestore_image_id']) ? sanitize($item['firestore_image_id']) : null;
            
            $itemStmt->bindParam(":order_id", $orderId);
            $itemStmt->bindParam(":product_id", $product_id);
            $itemStmt->bindParam(":product_name", $product_name);
            $itemStmt->bindParam(":price", $price);
            $itemStmt->bindParam(":quantity", $quantity);
            $itemStmt->bindParam(":image_base64", $image_base64);
            $itemStmt->bindParam(":image_url", $image_url);
            $itemStmt->bindParam(":firestore_image_id", $firestore_image_id);
            
            if (!$itemStmt->execute()) {
                $db->rollBack();
                sendError("Failed to add order item", 500);
            }

            // Update product stock (already validated above)
            $updateStockQuery = "UPDATE products SET stock_quantity = stock_quantity - :quantity WHERE id = :product_id";
            $updateStockStmt = $db->prepare($updateStockQuery);
            $updateStockStmt->bindParam(":quantity", $quantity);
            $updateStockStmt->bindParam(":product_id", $product_id);
            $updateStockStmt->execute();
        }
        
        $createdOrders[] = $orderId;
    }

    // Commit transaction
    $db->commit();

    // Get first created order details
    $getQuery = "SELECT o.*, buyer.name as buyer_name, buyer.email as buyer_email, 
                        seller.name as seller_name, seller.email as seller_email
                 FROM orders o
                 LEFT JOIN users buyer ON o.buyer_id = buyer.id
                 LEFT JOIN users seller ON o.seller_id = seller.id
                 WHERE o.id = :id";
    $getStmt = $db->prepare($getQuery);
    $getStmt->bindParam(":id", $createdOrders[0]);
    $getStmt->execute();
    
    $order = $getStmt->fetch(PDO::FETCH_ASSOC);
    
    // Get order items
    $itemsQuery = "SELECT * FROM order_items WHERE order_id = :order_id";
    $itemsStmt = $db->prepare($itemsQuery);
    $itemsStmt->bindParam(":order_id", $createdOrders[0]);
    $itemsStmt->execute();
    
    $order['items'] = $itemsStmt->fetchAll(PDO::FETCH_ASSOC);

    sendSuccess($order, "Order placed successfully", 201);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Create order error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

