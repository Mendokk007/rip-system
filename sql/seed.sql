-- =====================================================================
-- Rest in Place (RIP System) — seed data
-- Run this AFTER schema.sql
-- =====================================================================
USE rip_system;

-- ---------- Users ----------
-- admin@rip.local / admin123
-- visitor@rip.local / visitor123
INSERT INTO users (email, password_hash, full_name, role) VALUES
('admin@rip.local',
 '$2y$10$yRUrxqSO2frnAUThjcwNn.IM06y35rEQOfr8bRKrv9o5ajmJhUfLy',
 'System Admin', 'admin'),
('visitor@rip.local',
 '$2y$10$7HP6CFSNViOi8xbH5sylpe9qew100pgmAeYL1J9CiyiPnGMyRxGqW',
 'Demo Visitor', 'user');

-- ---------- Cemeteries ----------
INSERT INTO cemeteries (name, address, contact_email) VALUES
('Holy Cross Cemetery', '123 Main St, Cebu City', 'holycross@example.com'),
('Riverside Memorial Park', '45 River Rd, Manila', 'riverside@example.com');

-- ---------- Graves (matching the frontend's sample data) ----------
INSERT INTO graves
(grave_code, full_name, gender, birth_date, death_date, age_at_death,
 address, cemetery_id, area, section, plot_number, burial_date,
 next_of_kin, notes, created_by) VALUES
('RIP-001','Juan Dela Cruz','M','1940-05-10','2020-08-15',80,
 'Cebu City',1,'North','A','12','2020-08-20',
 'Maria Dela Cruz','Beloved father',1),
('RIP-002','Ana Reyes','F','1952-02-03','2021-11-30',69,
 'Manila',1,'South','B','7','2021-12-05',
 'Pedro Reyes',NULL,1),
('RIP-003','Carlos Santos','M','1930-12-01','2010-04-22',79,
 'Davao',2,'East','C','3','2010-04-28',
 'Luz Santos',NULL,1),
('RIP-004','Liza Mendoza','F','1985-07-19','2022-01-10',36,
 'Quezon City',2,'West','D','15','2022-01-15',
 'Jose Mendoza',NULL,1),
('RIP-005','Ramon Garcia','M','1948-09-09','2019-06-01',70,
 'Makati',1,'North','A','20','2019-06-06',
 'Elena Garcia',NULL,1);