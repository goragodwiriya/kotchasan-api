-- ============================================================
-- Kotchasan API Framework — Database Schema
-- Engine  : InnoDB
-- Charset : utf8mb4_unicode_ci
-- ============================================================

-- ------------------------------------------------------------
-- ตาราง user
-- ใช้โดย: auth/login, auth/me, auth/register, auth/update,
--          auth/forgot, auth/resetpassword, auth/verify,
--          auth/activate
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
  `id`            INT(11)       NOT NULL AUTO_INCREMENT,
  `username`      VARCHAR(100)  NOT NULL DEFAULT ''   COMMENT 'ใช้ login (รองรับ email)',
  `password`      VARCHAR(64)   NOT NULL DEFAULT ''   COMMENT 'SHA1(password_key + password + salt)',
  `salt`          VARCHAR(32)   NOT NULL DEFAULT ''   COMMENT 'random salt สำหรับ hash',
  `name`          VARCHAR(200)  NOT NULL DEFAULT ''   COMMENT 'ชื่อแสดง',
  `phone`         VARCHAR(20)   DEFAULT NULL,
  `id_card`       VARCHAR(20)   DEFAULT NULL          COMMENT 'เลขบัตรประชาชน (optional)',
  `telegram_id`   VARCHAR(100)  DEFAULT NULL,
  `status`        TINYINT(1)    NOT NULL DEFAULT 0    COMMENT '0=user, 1=admin',
  `social`        VARCHAR(20)   NOT NULL DEFAULT 'user' COMMENT 'user | google | facebook',
  `active`        TINYINT(1)    NOT NULL DEFAULT 1    COMMENT '1=active, 0=รอยืนยันอีเมล',
  `activatecode`  VARCHAR(64)   NOT NULL DEFAULT ''   COMMENT 'email activation code หรือ password reset token',
  `permission`    TEXT          DEFAULT NULL          COMMENT 'JSON permissions',
  `token`         VARCHAR(512)  DEFAULT NULL          COMMENT 'JWT access token ปัจจุบัน',
  `token_expires` DATETIME      DEFAULT NULL          COMMENT 'วันหมดอายุ access token หรือ reset token',
  `visited`       INT(11)       NOT NULL DEFAULT 0    COMMENT 'จำนวนครั้ง login',
  `created_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `active`  (`active`),
  KEY `status`  (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- ตาราง logs
-- ใช้โดย: auth/login, auth/logout, auth/register,
--          auth/forgot, auth/resetpassword
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `logs` (
  `id`          INT(11)       NOT NULL AUTO_INCREMENT,
  `src_id`      INT(11)       NOT NULL DEFAULT 0    COMMENT 'ID ของ resource ที่ถูกกระทำ (เช่น user.id)',
  `member_id`   INT(11)       NOT NULL DEFAULT 0    COMMENT 'ID ผู้กระทำ (0 = guest)',
  `module`      VARCHAR(50)   NOT NULL DEFAULT ''   COMMENT 'ชื่อโมดูล เช่น index',
  `action`      VARCHAR(50)   NOT NULL DEFAULT ''   COMMENT 'login | logout | register | forgot | reset',
  `topic`       VARCHAR(255)  NOT NULL DEFAULT ''   COMMENT 'ข้อความสรุปกิจกรรม',
  `reason`      VARCHAR(255)  DEFAULT NULL          COMMENT 'เหตุผล (เช่น กรณี reject หรือ error)',
  `datas`       TEXT          DEFAULT NULL          COMMENT 'JSON ข้อมูลเพิ่มเติม',
  `created_at`  DATETIME      DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `member_id`     (`member_id`),
  KEY `module_action` (`module`, `action`),
  KEY `created_at`    (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
