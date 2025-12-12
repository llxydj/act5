<?php
/**
 * Update Order Status
 * PUT /orders/update_order_status.php
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
validateRequired($data, ['id', 'status']);

// Validate status
$validStatuses = ['pending', 'shipped', 'completed', 'cancelled'];
if (!in_array($data['status'], $validStatuses)) {
    sendError("Invalid status. Must be: pending, shipped, completed, or cancelled", 400);
}

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Begin transaction
    $db->beginTransaction();

    $id = sanitize($data['id']);
    $status = sanitize($data['status']);

    // Get current order status
    $currentQuery = "SELECT status FROM orders WHERE id = :id";
    $currentStmt = $db->prepare($currentQuery);
    $currentStmt->bindParam(":id", $id);
    $currentStmt->execute();
    
    $currentOrder = $currentStmt->fetch();
    if (!$currentOrder) {
        $db->rollBack();
        sendError("Order not found", 404);
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

