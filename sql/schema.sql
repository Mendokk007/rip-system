-- =====================================================================
-- Rest in Place (RIP System) — MySQL schema
-- Run this ONCE in phpMyAdmin before seed.sql
-- =====================================================================

DROP DATABASE IF EXISTS rip_system;
CREATE DATABASE rip_system
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rip_system;

-- ---------- Users ----------
CREATE TABLE users (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email           VARCHAR(255) NOT NULL UNIQUE,
  password_hash   VARCHAR(255) NOT NULL,
  full_name       VARCHAR(120) NOT NULL,
  role            ENUM('user','admin') NOT NULL DEFAULT 'user',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------- Cemeteries ----------
CREATE TABLE cemeteries (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(150) NOT NULL,
  address         VARCHAR(255) NULL,
  contact_email   VARCHAR(255) NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_cemetery_name (name)
) ENGINE=InnoDB;

-- ---------- Graves ----------
CREATE TABLE graves (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  grave_code      VARCHAR(20) NOT NULL UNIQUE,
  full_name       VARCHAR(150) NOT NULL,
  gender          ENUM('M','F','O') NULL,
  birth_date      DATE NULL,
  death_date      DATE NULL,
  age_at_death    SMALLINT UNSIGNED NULL,
  address         VARCHAR(255) NULL,
  cemetery_id     INT UNSIGNED NOT NULL,
  area            VARCHAR(80) NULL,
  section         VARCHAR(80) NULL,
  plot_number     VARCHAR(40) NULL,
  burial_date     DATE NULL,
  next_of_kin     VARCHAR(150) NULL,
  notes           TEXT NULL,
  latitude        DECIMAL(10,7) NULL,
  longitude       DECIMAL(10,7) NULL,
  created_by      INT UNSIGNED NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                              ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_graves_cemetery
    FOREIGN KEY (cemetery_id) REFERENCES cemeteries(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_graves_creator
    FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,

  INDEX idx_graves_death_date (death_date),
  INDEX idx_graves_cemetery   (cemetery_id),
  INDEX idx_graves_name       (full_name)
) ENGINE=InnoDB;

-- ---------- Favorites ----------
CREATE TABLE user_favorites (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  grave_id        INT UNSIGNED NOT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_fav_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_fav_grave
    FOREIGN KEY (grave_id) REFERENCES graves(id) ON DELETE CASCADE,

  UNIQUE KEY uq_fav_user_grave (user_id, grave_id),
  INDEX idx_fav_user (user_id)
) ENGINE=InnoDB;

-- ---------- Data correction reports ----------
CREATE TABLE data_reports (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  grave_id        INT UNSIGNED NOT NULL,
  issue_type      ENUM('wrong_name','wrong_dates','wrong_location','other') NOT NULL,
  description     TEXT NULL,
  status          ENUM('open','reviewing','resolved','rejected') NOT NULL DEFAULT 'open',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_rep_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_rep_grave
    FOREIGN KEY (grave_id) REFERENCES graves(id) ON DELETE CASCADE,

  INDEX idx_rep_user_day (user_id, created_at),
  INDEX idx_rep_status   (status)
) ENGINE=InnoDB;

-- ---------- Audit logs ----------
CREATE TABLE audit_logs (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NULL,
  action          VARCHAR(80) NOT NULL,
  entity          VARCHAR(40) NULL,
  entity_id       VARCHAR(40) NULL,
  ip_address      VARCHAR(45) NULL,
  meta            JSON NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_audit_user
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,

  INDEX idx_audit_user_time (user_id, created_at),
  INDEX idx_audit_action    (action),
  INDEX idx_audit_time      (created_at)
) ENGINE=InnoDB;