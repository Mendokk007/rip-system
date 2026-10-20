<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

$user = require_login();

$stmt = $pdo->prepare(
    'SELECT g.grave_code, g.full_name, g.birth_date, g.death_date, c.name AS cemetery
     FROM user_favorites f
     JOIN graves g ON g.id = f.grave_id
     JOIN cemeteries c ON c.id = g.cemetery_id
     WHERE f.user_id = ?
     ORDER BY f.created_at DESC'
);
$stmt->execute([(int)$user['id']]);
$rows = $stmt->fetchAll();

json_out(['ok' => true, 'count' => count($rows), 'results' => $rows]);