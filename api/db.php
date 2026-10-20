<?php
// api/db.php
// Single PDO connection. Every other API file includes this first.

$DB_HOST = 'localhost';
$DB_NAME = 'rip_system';
$DB_USER = 'root';
$DB_PASS = '';          // XAMPP default: empty password

try {
    $pdo = new PDO(
        "mysql:host=$DB_HOST;dbname=$DB_NAME;charset=utf8mb4",
        $DB_USER,
        $DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );
} catch (PDOException $e) {
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode(['ok' => false, 'error' => 'db_connection_failed']);
    exit;
}