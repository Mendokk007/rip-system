<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_post();
$user = require_login();

$body = json_in();
$code = trim($body['grave_code'] ?? '');

if ($code === '') {
    json_out(['ok' => false, 'error' => 'missing_grave_code'], 400);
}

// Look up grave internal ID
$stmt = $pdo->prepare('SELECT id FROM graves WHERE grave_code = ?');
$stmt->execute([$code]);
$grave = $stmt->fetch();
if (!$grave) json_out(['ok' => false, 'error' => 'grave_not_found'], 404);

$graveId = (int)$grave['id'];
$userId  = (int)$user['id'];

// Check if already favorited
$stmt = $pdo->prepare('SELECT id FROM user_favorites WHERE user_id = ? AND grave_id = ?');
$stmt->execute([$userId, $graveId]);
$existing = $stmt->fetch();

if ($existing) {
    // Remove favorite
    $pdo->prepare('DELETE FROM user_favorites WHERE id = ?')->execute([$existing['id']]);
    audit($pdo, 'favorite_remove', 'grave', $code);
    json_out(['ok' => true, 'favorited' => false]);
} else {
    // Add favorite
    $pdo->prepare('INSERT INTO user_favorites (user_id, grave_id) VALUES (?, ?)')->execute([$userId, $graveId]);
    audit($pdo, 'favorite_add', 'grave', $code);
    json_out(['ok' => true, 'favorited' => true]);
}