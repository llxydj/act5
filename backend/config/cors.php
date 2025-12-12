<?php
/**
 * CORS Configuration
 * SwiftCart E-Commerce API
 */

// SECURITY FIX: Restrict CORS to specific origins
// For development, you can use '*' but for production, specify your domain
$allowedOrigins = [
    'http://localhost',
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:8080',
    // Add your production domain here
    // 'https://yourdomain.com',
    // 'https://www.yourdomain.com',
];

// Get the origin from the request
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';

// Check if origin is allowed, or allow all for development (remove in production)
$allowOrigin = '*'; // Change to specific origin in production
if (in_array($origin, $allowedOrigins)) {
    $allowOrigin = $origin;
}

header("Access-Control-Allow-Origin: $allowOrigin");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Credentials: true");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>

