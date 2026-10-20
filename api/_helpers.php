<?php
// api/_helpers.php
// Small helpers shared by every endpoint.

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// ---- JSON output ----
function json_out($data, int $code = 200): void {
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

// ---- Read JSON body from request ----
function json_in(): array {
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') return [];
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

// ---- Auth guards ----
function current_user(): ?array {
    return $_SESSION['user'] ?? null;
}

function require_login(): array {
    $u = current_user();
    if (!$u) json_out(['ok' => false, 'error' => 'not_logged_in'], 401);
    return $u;
}

function require_admin(): array {
    $u = require_login();
    if (($u['role'] ?? '') !== 'admin') {
        json_out(['ok' => false, 'error' => 'admin_only'], 403);
    }
    return $u;
}

// ---- Audit log ----
function audit(PDO $pdo, string $action, ?string $entity = null, ?string $entity_id = null, array $meta = []): void {
    try {
        $stmt = $pdo->prepare(
            'INSERT INTO audit_logs (user_id, action, entity, entity_id, ip_address, meta)
             VALUES (?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $_SESSION['user']['id'] ?? null,
            $action,
            $entity,
            $entity_id,
            $_SERVER['REMOTE_ADDR'] ?? null,
            $meta ? json_encode($meta) : null,
        ]);
    } catch (Throwable $e) {
        // Never let audit failure break the request
    }
}

// ---- Only allow POST ----
function require_post(): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        json_out(['ok' => false, 'error' => 'method_not_allowed'], 405);
    }
}