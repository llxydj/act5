<?php
/**
 * Update Order Status
 * PUT /orders/update_order_status.php
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';
require_once '../helpers/auth.php';

// Only allow PUT
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    sendError("Method not allowed", 405);
}

// Get input data
$data = getJsonInput();

// Validate required fields
validateRequired($data, ['id', 'status']);

// Validate status
$validStatuses = ['pending', 'shipped', 'completed', 'cancelled'];
if (!in_array($data['status'], $validStatuses)) {
    sendError("Invalid status. Must be: pending, shipped, completed, or cancelled", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // SECURITY FIX: Require authentication
    $user = requireAuth($db);
    
    // Begin transaction
    $db->beginTransaction();

    $id = sanitize($data['id']);
    $status = sanitize($data['status']);

    // Get current order details (including seller_id and buyer_id for permission check)
    $currentQuery = "SELECT status, seller_id, buyer_id FROM orders WHERE id = :id";
    $currentStmt = $db->prepare($currentQuery);
    $currentStmt->bindParam(":id", $id);
    $currentStmt->execute();
    
    $currentOrder = $currentStmt->fetch(PDO::FETCH_ASSOC);
    if (!$currentOrder) {
        $db->rollBack();
        sendError("Order not found", 404);
    }
    
    // SECURITY FIX: Verify user has permission to update this order
    // Only seller who owns the order, buyer who placed it, or admin can update
    if ($currentOrder['seller_id'] != $user['id'] && 
        $currentOrder['buyer_id'] != $user['id'] && 
        $user['role'] !== 'admin') {
        $db->rollBack();
        sendError("Access denied. You don't have permission to update this order.", 403);
    }
    
    // Additional validation: Buyers can only cancel pending orders
    if ($user['role'] === 'buyer' && $currentOrder['buyer_id'] == $user['id']) {
        if ($data['status'] !== 'cancelled' && $currentOrder['status'] !== 'pending') {
            $db->rollBack();
            sendError("Buyers can only cancel pending orders", 400);
        }
    }

    // Build update query
    $query = "UPDATE orders SET status = :status";
    
    if ($status === 'shipped') {
        $query .= ", shipped_at = NOW()";
    } elseif ($status === 'completed') {
        $query .= ", completed_at = NOW()";
    }
    
    $query .= " WHERE id = :id";

    $stmt = $db->prepare($query);
    $stmt->bindParam(":id", $id);
    $stmt->bindParam(":status", $status);

    if ($stmt->execute()) {
        // If order is cancelled, restore product stock
        if ($status === 'cancelled' && $currentOrder['status'] !== 'cancelled') {
            $restoreQuery = "UPDATE products p
                            INNER JOIN order_items oi ON p.id = oi.product_id
                            SET p.stock_quantity = p.stock_quantity + oi.quantity
                            WHERE oi.order_id = :order_id";
            $restoreStmt = $db->prepare($restoreQuery);
            $restoreStmt->bindParam(":order_id", $id);
            $restoreStmt->execute();
        }
        
        $db->commit();
        sendSuccess(null, "Order status updated successfully");
    } else {
        $db->rollBack();
        sendError("Failed to update order status", 500);
    }
} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    error_log("Update order status error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

