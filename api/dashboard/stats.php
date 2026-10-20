<?php
require __DIR__ . '/../db.php';
require __DIR__ . '/../_helpers.php';

require_login();

$total      = (int)$pdo->query('SELECT COUNT(*) FROM graves')->fetchColumn();
$searchable = (int)$pdo->query('SELECT COUNT(*) FROM graves WHERE full_name IS NOT NULL')->fetchColumn();
$locations  = (int)$pdo->query('SELECT COUNT(DISTINCT cemetery_id) FROM graves')->fetchColumn();

// Stand-in for the BRD's "birthday/anniversary notifications" — which we defer to V2
$upcoming = $pdo->query(
    "SELECT grave_code, full_name, death_date
     FROM graves
     WHERE MONTH(death_date) = MONTH(CURDATE())
       AND DAY(death_date) >= DAY(CURDATE())
     ORDER BY DAY(death_date)
     LIMIT 5"
)->fetchAll();

json_out([
    'ok'                      => true,
    'total_records'           => $total,
    'searchable'              => $searchable,
    'locations'               => $locations,
    'upcoming_anniversaries'  => $upcoming,
]);