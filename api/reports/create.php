<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_post();
$user = require_login();

$body = json_in();
$code        = trim($body['grave_code'] ?? '');
$issue_type  = $body['issue_type'] ?? '';
$description = trim($body['description'] ?? '');

// Validation per ERR-GL-103
$valid_types = ['wrong_name', 'wrong_dates', 'wrong_location', 'other'];
if ($code === '' || !in_array($issue_type, $valid_types, true)) {
    json_out(['ok' => false, 'error' => 'invalid_report_data'], 400);
}

// Look up grave
$stmt = $pdo->prepare('SELECT id FROM graves WHERE grave_code = ?');
$stmt->execute([$code]);
$grave = $stmt->fetch();
if (!$grave) json_out(['ok' => false, 'error' => 'grave_not_found'], 404);

$graveId = (int)$grave['id'];
$userId  = (int)$user['id'];

// BR-GL-03: max 5 reports per user per day
$stmt = $pdo->prepare('SELECT COUNT(*) FROM data_reports WHERE user_id = ? AND DATE(created_at) = CURDATE()');
$stmt->execute([$userId]);
$todayCount = (int)$stmt->fetchColumn();

if ($todayCount >= 5) {
    json_out(['ok' => false, 'error' => 'daily_limit_reached'], 429);
}

// Insert report
$stmt = $pdo->prepare(
    'INSERT INTO data_reports (user_id, grave_id, issue_type, description)
     VALUES (?, ?, ?, ?)'
);
$stmt->execute([$userId, $graveId, $issue_type, $description]);
$reportId = (int)$pdo->lastInsertId();

audit($pdo, 'report_submit', 'grave', $code, ['report_id' => $reportId, 'type' => $issue_type]);

json_out(['ok' => true, 'report_id' => $reportId]);