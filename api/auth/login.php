<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_post();

$body     = json_in();
$email    = trim($body['email'] ?? '');
$password = (string)($body['password'] ?? '');

if ($email === '' || $password === '') {
    json_out(['ok' => false, 'error' => 'missing_fields'], 400);
}

$stmt = $pdo->prepare('SELECT id, email, password_hash, full_name, role FROM users WHERE email = ?');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    json_out(['ok' => false, 'error' => 'invalid_credentials'], 401);
}

// Store minimal user in session
$_SESSION['user'] = [
    'id'        => (int)$user['id'],
    'email'     => $user['email'],
    'full_name' => $user['full_name'],
    'role'      => $user['role'],
];

audit($pdo, 'login', 'user', (string)$user['id']);

json_out(['ok' => true, 'user' => $_SESSION['user']]);