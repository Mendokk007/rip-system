<?php
require __DIR__ . '/../_helpers.php';

$u = current_user();
if (!$u) {
    json_out(['ok' => false, 'error' => 'not_logged_in'], 401);
}
json_out(['ok' => true, 'user' => $u]);