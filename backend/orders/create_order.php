<?php
/**
 * Create New Order
 * POST /orders/create_order.php
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
validateRequired($data, ['buyer_id', 'buyer_name', 'buyer_email', 'shipping_address', 'total_amount', 'items']);

if (empty($data['items']) || !is_array($data['items'])) {
    sendError("Order must have at least one item", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Begin transaction
    $db->beginTransaction();

    // Group items by product's seller
    $itemsBySeller = [];
    
    foreach ($data['items'] as $item) {
        // Get product's seller
        $productQuery = "SELECT seller_id FROM products WHERE id = :product_id";
        $productStmt = $db->prepare($productQuery);
        $productStmt->bindParam(":product_id", $item['product_id']);
        $productStmt->execute();
        
        $product = $productStmt->fetch();
        if (!$product) {
            $db->rollBack();
            sendError("Product not found: " . $item['product_id'], 404);
        }
        
        $sellerId = $product['seller_id'];
        
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
        
        $buyer_id = sanitize($data['buyer_id']);
        $shipping_address = sanitize($data['shipping_address']);
        $phone = isset($data['phone']) ? sanitize($data['phone']) : null;
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
            $itemQuery = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity, image_base64) 
                          VALUES (:order_id, :product_id, :product_name, :price, :quantity, :image_base64)";
            
            $itemStmt = $db->prepare($itemQuery);
            
            $product_id = sanitize($item['product_id']);
            $product_name = sanitize($item['product_name']);
            $price = (float) $item['price'];
            $quantity = (int) $item['quantity'];
            $image_base64 = isset($item['image_base64']) ? $item['image_base64'] : null;
            
            $itemStmt->bindParam(":order_id", $orderId);
            $itemStmt->bindParam(":product_id", $product_id);
            $itemStmt->bindParam(":product_name", $product_name);
            $itemStmt->bindParam(":price", $price);
            $itemStmt->bindParam(":quantity", $quantity);
            $itemStmt->bindParam(":image_base64", $image_base64);
            
            if (!$itemStmt->execute()) {
                $db->rollBack();
                sendError("Failed to add order item", 500);
            }

            // Update product stock
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
    
    $order = $getStmt->fetch();
    
    // Get order items
    $itemsQuery = "SELECT * FROM order_items WHERE order_id = :order_id";
    $itemsStmt = $db->prepare($itemsQuery);
    $itemsStmt->bindParam(":order_id", $createdOrders[0]);
    $itemsStmt->execute();
    
    $order['items'] = $itemsStmt->fetchAll();

    sendSuccess($order, "Order placed successfully", 201);
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Create order error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

