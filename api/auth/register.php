<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_post();

$body = json_in();
$email     = trim($body['email'] ?? '');
$password  = (string)($body['password'] ?? '');
$full_name = trim($body['full_name'] ?? '');

// Validation
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    json_out(['ok' => false, 'error' => 'invalid_email'], 400);
}
if (strlen($password) < 6) {
    json_out(['ok' => false, 'error' => 'password_too_short'], 400);
}
if ($full_name === '') {
    json_out(['ok' => false, 'error' => 'name_required'], 400);
}

// Duplicate check
$stmt = $pdo->prepare('SELECT id FROM users WHERE email = ?');
$stmt->execute([$email]);
if ($stmt->fetch()) {
    json_out(['ok' => false, 'error' => 'email_taken'], 409);
}

// Insert
$hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $pdo->prepare(
    'INSERT INTO users (email, password_hash, full_name, role)
     VALUES (?, ?, ?, "user")'
);
$stmt->execute([$email, $hash, $full_name]);
$id = (int)$pdo->lastInsertId();

// Auto-login
$_SESSION['user'] = [
    'id'        => $id,
    'email'     => $email,
    'full_name' => $full_name,
    'role'      => 'user',
];

audit($pdo, 'register', 'user', (string)$id);

json_out(['ok' => true, 'user' => $_SESSION['user']]);