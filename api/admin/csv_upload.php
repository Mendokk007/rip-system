<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

// Must be POST, logged in, and ADMIN (per FRD)
require_post();
$user = require_admin();

if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    json_out(['ok' => false, 'error' => 'no_file_uploaded'], 400);
}

// BR-GL-04: File size <= 10MB
if ($_FILES['file']['size'] > 10 * 1024 * 1024) {
    json_out(['ok' => false, 'error' => 'file_too_large_max_10mb'], 400);
}

$file = $_FILES['file']['tmp_name'];
$handle = fopen($file, 'r');
if (!$handle) {
    json_out(['ok' => false, 'error' => 'cannot_open_file'], 500);
}

// Read headers
$headers = fgetcsv($handle);
if (!$headers) {
    fclose($handle);
    json_out(['ok' => false, 'error' => 'empty_csv'], 400);
}

// Normalize headers (lowercase, trim)
$headers = array_map(fn($h) => strtolower(trim($h)), $headers);

// BR-GL-04: Required columns
$required = ['full_name', 'birth_date', 'death_date', 'cemetery_name', 'section', 'plot_number'];
$missing = array_diff($required, $headers);
if (!empty($missing)) {
    fclose($handle);
    json_out(['ok' => false, 'error' => 'missing_columns', 'missing' => array_values($missing)], 400);
}

$inserted = 0;
$skipped = 0;
$errors = [];
$rowNum = 1;

// Prepare statements
$stmtCem = $pdo->prepare('SELECT id FROM cemeteries WHERE name = ?');
$stmtCemIns = $pdo->prepare('INSERT INTO cemeteries (name) VALUES (?)');
$stmtGrave = $pdo->prepare(
    'INSERT INTO graves (grave_code, full_name, birth_date, death_date, cemetery_id, section, plot_number, created_by)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
);

$pdo->beginTransaction();
try {
    while (($row = fgetcsv($handle)) !== false) {
        $rowNum++;
        if (count($row) !== count($headers)) {
            $skipped++;
            $errors[] = "Row $rowNum: column count mismatch";
            continue;
        }
        
        $data = array_combine($headers, $row);
        $fullName = trim($data['full_name']);
        $cemName  = trim($data['cemetery_name']);
        
        if ($fullName === '' || $cemName === '') {
            $skipped++;
            $errors[] = "Row $rowNum: empty full_name or cemetery_name";
            continue;
        }
        
        // Find or create cemetery
        $stmtCem->execute([$cemName]);
        $cemId = $stmtCem->fetchColumn();
        if (!$cemId) {
            $stmtCemIns->execute([$cemName]);
            $cemId = $pdo->lastInsertId();
        }
        
        // Auto-generate grave_code (RIP-006, RIP-007, etc.)
        $nextId = (int)$pdo->query('SELECT MAX(id) FROM graves')->fetchColumn() + 1;
        $graveCode = 'RIP-' . str_pad($nextId, 3, '0', STR_PAD_LEFT);
        
        try {
            $stmtGrave->execute([
                $graveCode,
                $fullName,
                $data['birth_date'] ?: null,
                $data['death_date'] ?: null,
                $cemId,
                $data['section'] ?: null,
                $data['plot_number'] ?: null,
                (int)$user['id']
            ]);
            $inserted++;
        } catch (PDOException $e) {
            $skipped++;
            $errors[] = "Row $rowNum: " . $e->getMessage();
        }
    }
    $pdo->commit();
    audit($pdo, 'csv_upload', 'grave', null, ['inserted' => $inserted, 'skipped' => $skipped]);
} catch (Exception $e) {
    $pdo->rollBack();
    fclose($handle);
    json_out(['ok' => false, 'error' => 'transaction_failed', 'message' => $e->getMessage()], 500);
}
fclose($handle);

json_out([
    'ok' => true,
    'inserted' => $inserted,
    'skipped' => $skipped,
    'errors' => $errors
]);