<?php
/**
 * Authentication Helper Functions
 * Firebase ID Token Verification
 * SwiftCart E-Commerce API
 */

/**
 * Get Firebase ID Token from Authorization header
 */
function getAuthToken() {
    // Try to get headers (getallheaders() may not be available in all PHP environments)
    $headers = [];
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
    } else {
        // Fallback: manually extract headers from $_SERVER
        foreach ($_SERVER as $key => $value) {
            if (strpos($key, 'HTTP_') === 0) {
                $headerName = str_replace(' ', '-', ucwords(str_replace('_', ' ', strtolower(substr($key, 5)))));
                $headers[$headerName] = $value;
            }
        }
    }
    
    // Check for Authorization header
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
        // Extract token from "Bearer <token>"
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $matches[1];
        }
    }
    
    // Fallback: check for Authorization in $_SERVER (for nginx and other servers)
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $matches[1];
        }
    }
    
    // Additional fallback: check REDIRECT_HTTP_AUTHORIZATION (for some server configs)
    if (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $matches[1];
        }
    }
    
    return null;
}

/**
 * Verify Firebase ID Token
 * Note: This is a basic implementation. For production, use Firebase Admin SDK for PHP
 * or implement proper JWT verification with Firebase's public keys.
 * 
 * @param string $idToken Firebase ID Token
 * @return array|null Returns decoded token payload or null if invalid
 */
function verifyFirebaseToken($idToken) {
    if (empty($idToken)) {
        return null;
    }
    
    // For production, you should:
    // 1. Install Firebase Admin SDK for PHP: composer require kreait/firebase-php
    // 2. Or use JWT library to verify token with Firebase's public keys
    // 3. Or call Firebase REST API to verify token
    
    // Basic validation: Check if token is not empty and has proper format
    // JWT tokens have 3 parts separated by dots
    $parts = explode('.', $idToken);
    if (count($parts) !== 3) {
        return null;
    }
    
    // Decode payload (second part)
    $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1])), true);
    
    if (!$payload) {
        return null;
    }
    
    // Basic checks
    if (!isset($payload['sub']) || !isset($payload['exp'])) {
        return null;
    }
    
    // Check expiration
    if (isset($payload['exp']) && $payload['exp'] < time()) {
        return null;
    }
    
    return $payload;
}

/**
 * Get authenticated user's Firebase UID from token
 * @return string|null Firebase UID or null if not authenticated
 */
function getAuthenticatedUid() {
    $token = getAuthToken();
    if (!$token) {
        return null;
    }
    
    $payload = verifyFirebaseToken($token);
    if (!$payload || !isset($payload['sub'])) {
        return null;
    }
    
    return $payload['sub'];
}

/**
 * Require authentication - middleware function
 * Validates Firebase token and returns user data from database
 * 
 * @param PDO $db Database connection
 * @return array User data from database
 */
function requireAuth($db) {
    $uid = getAuthenticatedUid();
    
    if (!$uid) {
        sendError("Authentication required. Please provide a valid Firebase ID token in Authorization header.", 401);
    }
    
    // Get user from database by firebase_uid
    $query = "SELECT * FROM users WHERE firebase_uid = :firebase_uid AND is_active = 1";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":firebase_uid", $uid);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        sendError("User not found or inactive", 401);
    }
    
    return $user;
}

/**
 * Require specific role
 * @param PDO $db Database connection
 * @param string|array $requiredRoles Role(s) required (e.g., 'admin', ['admin', 'seller'])
 * @return array User data
 */
function requireRole($db, $requiredRoles) {
    $user = requireAuth($db);
    
    if (is_string($requiredRoles)) {
        $requiredRoles = [$requiredRoles];
    }
    
    if (!in_array($user['role'], $requiredRoles)) {
        sendError("Access denied. Required role: " . implode(' or ', $requiredRoles), 403);
    }
    
    return $user;
}

/**
 * Verify user owns resource
 * @param PDO $db Database connection
 * @param string $table Table name
 * @param string $resourceId Resource ID
 * @param string $userIdField Field name for user ID (e.g., 'seller_id', 'buyer_id')
 * @param string $idField Field name for resource ID (default: 'id')
 * @return bool True if user owns the resource
 */
function verifyResourceOwnership($db, $table, $resourceId, $userIdField, $idField = 'id') {
    $user = requireAuth($db);
    
    $query = "SELECT $userIdField FROM $table WHERE $idField = :resource_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":resource_id", $resourceId);
    $stmt->execute();
    
    $resource = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$resource) {
        sendError("Resource not found", 404);
    }
    
    // Check if user owns the resource
    if ($resource[$userIdField] != $user['id']) {
        sendError("Access denied. You don't have permission to access this resource.", 403);
    }
    
    return true;
}
?>

