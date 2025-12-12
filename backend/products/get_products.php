<?php
/**
 * Get Products
 * GET /products/get_products.php?seller_id=xxx&category_id=xxx&search=xxx&page=1&limit=20
 */

require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../helpers/response.php';

// Only allow GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError("Method not allowed", 405);
}

try {
    $database = new Database();
    $db = $database->getConnection();

    // Base query with joins
    $query = "SELECT p.*, u.name as seller_name, c.name as category_name 
              FROM products p 
              LEFT JOIN users u ON p.seller_id = u.id 
              LEFT JOIN categories c ON p.category_id = c.id 
              WHERE p.is_active = 1";
    
    $countQuery = "SELECT COUNT(*) as total FROM products p WHERE p.is_active = 1";
    $params = [];

    // Filter by seller
    if (isset($_GET['seller_id']) && !empty($_GET['seller_id'])) {
        $query .= " AND p.seller_id = :seller_id";
        $countQuery .= " AND p.seller_id = :seller_id";
        $params[':seller_id'] = sanitize($_GET['seller_id']);
    }

    // Filter by category
    if (isset($_GET['category_id']) && !empty($_GET['category_id'])) {
        $query .= " AND p.category_id = :category_id";
        $countQuery .= " AND p.category_id = :category_id";
        $params[':category_id'] = sanitize($_GET['category_id']);
    }

    // Search
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = '%' . sanitize($_GET['search']) . '%';
        $query .= " AND (p.name LIKE :search OR p.description LIKE :search)";
        $countQuery .= " AND (p.name LIKE :search OR p.description LIKE :search)";
        $params[':search'] = $search;
    }

    // Order by
    $query .= " ORDER BY p.created_at DESC";

    // Pagination
    $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
    $limit = isset($_GET['limit']) ? min(50, max(1, (int)$_GET['limit'])) : 20;
    $offset = ($page - 1) * $limit;
    
    $query .= " LIMIT :limit OFFSET :offset";

    $stmt = $db->prepare($query);
    
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    
    $stmt->execute();
    $products = $stmt->fetchAll();

    // Get total count
    $countStmt = $db->prepare($countQuery);
    foreach ($params as $key => $value) {
        if ($key !== ':limit' && $key !== ':offset') {
            $countStmt->bindValue($key, $value);
        }
    }
    $countStmt->execute();
    $total = (int) $countStmt->fetch()['total'];

    sendSuccess([
        'products' => $products,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ], "Products retrieved successfully");
} catch (Exception $e) {
    error_log("Get products error: " . $e->getMessage());
    sendError("Server error", 500);
}
?>

