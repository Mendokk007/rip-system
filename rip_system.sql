-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 20, 2026 at 07:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rip_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(80) NOT NULL,
  `entity` varchar(40) DEFAULT NULL,
  `entity_id` varchar(40) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity`, `entity_id`, `ip_address`, `meta`, `created_at`) VALUES
(1, 1, 'login', 'user', '1', '::1', NULL, '2026-10-21 00:30:34'),
(2, 1, 'logout', 'user', '1', '::1', NULL, '2026-10-21 00:31:57'),
(3, 1, 'login', 'user', '1', '::1', NULL, '2026-10-21 00:32:15'),
(4, 1, 'login', 'user', '1', '::1', NULL, '2026-10-21 00:37:54'),
(5, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"Juan\",\"type\":\"name\",\"hits\":1}', '2026-10-21 00:38:54'),
(6, 1, 'favorite_add', 'grave', 'RIP-001', '::1', NULL, '2026-10-21 00:44:01'),
(7, 1, 'favorite_remove', 'grave', 'RIP-001', '::1', NULL, '2026-10-21 00:44:10'),
(8, 1, 'favorite_add', 'grave', 'RIP-001', '::1', NULL, '2026-10-21 00:44:19'),
(9, 1, 'report_submit', 'grave', 'RIP-001', '::1', '{\"report_id\":1,\"type\":\"wrong_name\"}', '2026-10-21 00:44:34'),
(10, 1, 'report_submit', 'grave', 'RIP-001', '::1', '{\"report_id\":2,\"type\":\"wrong_name\"}', '2026-10-21 00:44:37'),
(11, 1, 'report_submit', 'grave', 'RIP-001', '::1', '{\"report_id\":3,\"type\":\"wrong_name\"}', '2026-10-21 00:44:37'),
(12, 1, 'report_submit', 'grave', 'RIP-001', '::1', '{\"report_id\":4,\"type\":\"wrong_name\"}', '2026-10-21 00:44:38'),
(13, 1, 'report_submit', 'grave', 'RIP-001', '::1', '{\"report_id\":5,\"type\":\"wrong_name\"}', '2026-10-21 00:44:39'),
(14, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"%%\",\"type\":\"name\",\"hits\":5}', '2026-10-21 00:58:30'),
(15, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"%%\",\"type\":\"name\",\"hits\":5}', '2026-10-21 01:00:09'),
(16, 1, 'logout', 'user', '1', '::1', NULL, '2026-10-21 01:02:06'),
(17, 1, 'login', 'user', '1', '::1', NULL, '2026-10-21 01:05:50'),
(18, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"%%\",\"type\":\"name\",\"hits\":5}', '2026-10-21 01:05:50'),
(19, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"juan\",\"type\":\"name\",\"hits\":1}', '2026-10-21 01:06:41'),
(20, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"juan\",\"type\":\"name\",\"hits\":1}', '2026-10-21 01:06:42'),
(21, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"rip-003\",\"type\":\"name\",\"hits\":0}', '2026-10-21 01:07:02'),
(22, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"rip-003\",\"type\":\"name\",\"hits\":0}', '2026-10-21 01:07:02'),
(23, 1, 'search', 'grave', NULL, '::1', '{\"query\":\"RIP-003\",\"type\":\"id\",\"hits\":1}', '2026-10-21 01:07:15');

-- --------------------------------------------------------

--
-- Table structure for table `cemeteries`
--

CREATE TABLE `cemeteries` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cemeteries`
--

INSERT INTO `cemeteries` (`id`, `name`, `address`, `contact_email`, `created_at`) VALUES
(1, 'Holy Cross Cemetery', '123 Main St, Cebu City', 'holycross@example.com', '2026-10-21 00:23:34'),
(2, 'Riverside Memorial Park', '45 River Rd, Manila', 'riverside@example.com', '2026-10-21 00:23:34');

-- --------------------------------------------------------

--
-- Table structure for table `data_reports`
--

CREATE TABLE `data_reports` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `grave_id` int(10) UNSIGNED NOT NULL,
  `issue_type` enum('wrong_name','wrong_dates','wrong_location','other') NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('open','reviewing','resolved','rejected') NOT NULL DEFAULT 'open',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `data_reports`
--

INSERT INTO `data_reports` (`id`, `user_id`, `grave_id`, `issue_type`, `description`, `status`, `created_at`) VALUES
(1, 1, 1, 'wrong_name', '', 'open', '2026-10-21 00:44:34'),
(2, 1, 1, 'wrong_name', '', 'open', '2026-10-21 00:44:37'),
(3, 1, 1, 'wrong_name', '', 'open', '2026-10-21 00:44:37'),
(4, 1, 1, 'wrong_name', '', 'open', '2026-10-21 00:44:38'),
(5, 1, 1, 'wrong_name', '', 'open', '2026-10-21 00:44:39');

-- --------------------------------------------------------

--
-- Table structure for table `graves`
--

CREATE TABLE `graves` (
  `id` int(10) UNSIGNED NOT NULL,
  `grave_code` varchar(20) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `gender` enum('M','F','O') DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `death_date` date DEFAULT NULL,
  `age_at_death` smallint(5) UNSIGNED DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `cemetery_id` int(10) UNSIGNED NOT NULL,
  `area` varchar(80) DEFAULT NULL,
  `section` varchar(80) DEFAULT NULL,
  `plot_number` varchar(40) DEFAULT NULL,
  `burial_date` date DEFAULT NULL,
  `next_of_kin` varchar(150) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `graves`
--

INSERT INTO `graves` (`id`, `grave_code`, `full_name`, `gender`, `birth_date`, `death_date`, `age_at_death`, `address`, `cemetery_id`, `area`, `section`, `plot_number`, `burial_date`, `next_of_kin`, `notes`, `latitude`, `longitude`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'RIP-001', 'Juan Dela Cruz', 'M', '1940-05-10', '2020-08-15', 80, 'Cebu City', 1, 'North', 'A', '12', '2020-08-20', 'Maria Dela Cruz', 'Beloved father', NULL, NULL, 1, '2026-10-21 00:23:34', '2026-10-21 00:23:34'),
(2, 'RIP-002', 'Ana Reyes', 'F', '1952-02-03', '2021-11-30', 69, 'Manila', 1, 'South', 'B', '7', '2021-12-05', 'Pedro Reyes', NULL, NULL, NULL, 1, '2026-10-21 00:23:34', '2026-10-21 00:23:34'),
(3, 'RIP-003', 'Carlos Santos', 'M', '1930-12-01', '2010-04-22', 79, 'Davao', 2, 'East', 'C', '3', '2010-04-28', 'Luz Santos', NULL, NULL, NULL, 1, '2026-10-21 00:23:34', '2026-10-21 00:23:34'),
(4, 'RIP-004', 'Liza Mendoza', 'F', '1985-07-19', '2022-01-10', 36, 'Quezon City', 2, 'West', 'D', '15', '2022-01-15', 'Jose Mendoza', NULL, NULL, NULL, 1, '2026-10-21 00:23:34', '2026-10-21 00:23:34'),
(5, 'RIP-005', 'Ramon Garcia', 'M', '1948-09-09', '2019-06-01', 70, 'Makati', 1, 'North', 'A', '20', '2019-06-06', 'Elena Garcia', NULL, NULL, NULL, 1, '2026-10-21 00:23:34', '2026-10-21 00:23:34');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `full_name`, `role`, `created_at`) VALUES
(1, 'admin@rip.local', '$2y$10$yRUrxqSO2frnAUThjcwNn.IM06y35rEQOfr8bRKrv9o5ajmJhUfLy', 'System Admin', 'admin', '2026-10-21 00:23:34'),
(2, 'visitor@rip.local', '$2y$10$7HP6CFSNViOi8xbH5sylpe9qew100pgmAeYL1J9CiyiPnGMyRxGqW', 'Demo Visitor', 'user', '2026-10-21 00:23:34');

-- --------------------------------------------------------

--
-- Table structure for table `user_favorites`
--

CREATE TABLE `user_favorites` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `grave_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_favorites`
--

INSERT INTO `user_favorites` (`id`, `user_id`, `grave_id`, `created_at`) VALUES
(2, 1, 1, '2026-10-21 00:44:19');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user_time` (`user_id`,`created_at`),
  ADD KEY `idx_audit_action` (`action`),
  ADD KEY `idx_audit_time` (`created_at`);

--
-- Indexes for table `cemeteries`
--
ALTER TABLE `cemeteries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cemetery_name` (`name`);

--
-- Indexes for table `data_reports`
--
ALTER TABLE `data_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_rep_grave` (`grave_id`),
  ADD KEY `idx_rep_user_day` (`user_id`,`created_at`),
  ADD KEY `idx_rep_status` (`status`);

--
-- Indexes for table `graves`
--
ALTER TABLE `graves`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `grave_code` (`grave_code`),
  ADD KEY `fk_graves_creator` (`created_by`),
  ADD KEY `idx_graves_death_date` (`death_date`),
  ADD KEY `idx_graves_cemetery` (`cemetery_id`),
  ADD KEY `idx_graves_name` (`full_name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_favorites`
--
ALTER TABLE `user_favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fav_user_grave` (`user_id`,`grave_id`),
  ADD KEY `fk_fav_grave` (`grave_id`),
  ADD KEY `idx_fav_user` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `cemeteries`
--
ALTER TABLE `cemeteries`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `data_reports`
--
ALTER TABLE `data_reports`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `graves`
--
ALTER TABLE `graves`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_favorites`
--
ALTER TABLE `user_favorites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `data_reports`
--
ALTER TABLE `data_reports`
  ADD CONSTRAINT `fk_rep_grave` FOREIGN KEY (`grave_id`) REFERENCES `graves` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rep_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `graves`
--
ALTER TABLE `graves`
  ADD CONSTRAINT `fk_graves_cemetery` FOREIGN KEY (`cemetery_id`) REFERENCES `cemeteries` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_graves_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `user_favorites`
--
ALTER TABLE `user_favorites`
  ADD CONSTRAINT `fk_fav_grave` FOREIGN KEY (`grave_id`) REFERENCES `graves` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
