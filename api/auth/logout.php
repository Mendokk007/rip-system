<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_post();

if (current_user()) {
    audit($pdo, 'logout', 'user', (string)current_user()['id']);
}

$_SESSION = [];
session_destroy();

json_out(['ok' => true]);