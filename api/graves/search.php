<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_post();
require_login();   // per SRS: search requires auth

$body  = json_in();
$query = trim($body['query'] ?? '');
$type  = $body['type'] ?? 'name';   // 'name' | 'id' | 'location'

// BR-GL-01: minimum 2 characters for name and location search
if (in_array($type, ['name', 'location'], true) && mb_strlen($query) < 2) {
    json_out(['ok' => false, 'error' => 'min_2_chars'], 400);
}
if ($type === 'id' && $query === '') {
    json_out(['ok' => false, 'error' => 'empty_query'], 400);
}

// Build query based on search type
if ($type === 'id') {
    $sql = 'SELECT g.grave_code, g.full_name, g.birth_date, g.death_date,
                   g.section, g.plot_number, c.name AS cemetery
            FROM graves g JOIN cemeteries c ON c.id = g.cemetery_id
            WHERE g.grave_code = ?
            LIMIT 50';
    $params = [$query];
} elseif ($type === 'location') {
    $sql = 'SELECT g.grave_code, g.full_name, g.birth_date, g.death_date,
                   g.section, g.plot_number, c.name AS cemetery
            FROM graves g JOIN cemeteries c ON c.id = g.cemetery_id
            WHERE c.name LIKE CONCAT("%", ?, "%")
               OR g.area LIKE CONCAT("%", ?, "%")
            LIMIT 50';
    $params = [$query, $query];
} else { // 'name'
    $sql = 'SELECT g.grave_code, g.full_name, g.birth_date, g.death_date,
                   g.section, g.plot_number, c.name AS cemetery
            FROM graves g JOIN cemeteries c ON c.id = g.cemetery_id
            WHERE g.full_name LIKE CONCAT("%", ?, "%")
            LIMIT 50';
    $params = [$query];
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$rows = $stmt->fetchAll();

audit($pdo, 'search', 'grave', null, ['query' => $query, 'type' => $type, 'hits' => count($rows)]);

if (count($rows) === 0) {
    // ERR-GL-101: no results — still HTTP 200, ok:true, empty list
    json_out(['ok' => true, 'count' => 0, 'results' => [], 'message' => 'no_results']);
}

json_out(['ok' => true, 'count' => count($rows), 'results' => $rows]);