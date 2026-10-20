<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_login();

$code = trim($_GET['id'] ?? '');
if ($code === '') {
    json_out(['ok' => false, 'error' => 'missing_id'], 400);
}

$stmt = $pdo->prepare(
    'SELECT g.*, c.name AS cemetery, c.address AS cemetery_address
     FROM graves g JOIN cemeteries c ON c.id = g.cemetery_id
     WHERE g.grave_code = ?'
);
$stmt->execute([$code]);
$grave = $stmt->fetch();

if (!$grave) {
    json_out(['ok' => false, 'error' => 'grave_not_found'], 404);
}

// Drop internal-only fields we don't want to expose
unset($grave['id'], $grave['created_by']);

json_out(['ok' => true, 'grave' => $grave]);