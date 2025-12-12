<?php
/**
 * Response Helper Functions
 * SwiftCart E-Commerce API
 */

/**
 * Send success response
 */
function sendSuccess($data = null, $message = "Success", $code = 200) {
    http_response_code($code);
    echo json_encode([
        "success" => true,
        "message" => $message,
        "data" => $data
    ]);
    exit();
}

/**
 * Send error response
 */
function sendError($message = "Error", $code = 400) {
    http_response_code($code);
    echo json_encode([
        "success" => false,
        "message" => $message,
        "data" => null
    ]);
    exit();
}

/**
 * Get JSON input data
 */
function getJsonInput() {
    $json = file_get_contents("php://input");
    return json_decode($json, true) ?? [];
}

/**
 * Validate required fields
 */
function validateRequired($data, $fields) {
    $missing = [];
    foreach ($fields as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            $missing[] = $field;
        }
    }
    
    if (!empty($missing)) {
        sendError("Missing required fields: " . implode(", ", $missing), 400);
    }
}

/**
 * Sanitize input string
 */
function sanitize($input) {
    return htmlspecialchars(strip_tags(trim($input)));
}
?>

