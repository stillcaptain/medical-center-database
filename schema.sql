CREATE DATABASE IF NOT EXISTS `hospital_db`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `hospital_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `prescription`;
DROP TABLE IF EXISTS `appointment`;
DROP TABLE IF EXISTS `patient`;
DROP TABLE IF EXISTS `doctor`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================
-- Table: doctor
-- ============================
CREATE TABLE `doctor` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `specialty` ENUM('gynecologist','cardiologist','pathologist','radiologist','orthopaedic') NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `surname` VARCHAR(255) NOT NULL,
  `birth_date` DATE NULL,
  PRIMARY KEY (`id`),
  INDEX `doctor_specialty_index` (`specialty`)
);

-- ============================
-- Table: patient
-- ============================
CREATE TABLE `patient` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `surname` VARCHAR(255) NOT NULL,
  `mobile` VARCHAR(15) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `gender` ENUM('M','F') NOT NULL,
  `medication` TEXT NOT NULL,
  `conditions` TEXT NOT NULL,
  `amka` CHAR(11) NOT NULL UNIQUE,
  `birth_date` DATE NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `patient_amka_unique` (`amka`),
  INDEX `patient_surname_index` (`surname`)
);

-- ============================
-- Table: appointment
-- ============================
CREATE TABLE `appointment` (
  `number` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `patient_id` INT UNSIGNED NOT NULL,
  `doctor_id` INT UNSIGNED NULL,
  `scheduled_at` DATETIME NOT NULL,
  `started_at` DATETIME NULL,
  `ended_at` DATETIME NULL,
  `cancel_date` DATETIME NULL,
  `status` ENUM('scheduled','started','completed','cancelled') NOT NULL DEFAULT 'scheduled',
  `medical_report` TEXT NULL,

  PRIMARY KEY (`number`),

  UNIQUE INDEX `appointment_number_patient_unique_index` (`number`, `patient_id`),
  INDEX `appointment_patient_id_index` (`patient_id`),
  INDEX `appointment_doctor_id_index` (`doctor_id`),
  INDEX `appointment_scheduled_at_index` (`scheduled_at`),

  CONSTRAINT `appointment_patient_id_foreign`
    FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT `appointment_doctor_id_foreign`
    FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- ============================
-- Table: prescription
-- ============================
CREATE TABLE `prescription` (
  `number` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `patient_id` INT UNSIGNED NOT NULL,
  `appointment_number` INT UNSIGNED NOT NULL,
  `medicine` VARCHAR(255) NOT NULL,
  `created_date` DATETIME NOT NULL,
  `participation_fee` DECIMAL(6,2) NOT NULL CHECK (`participation_fee` >= 0),

  PRIMARY KEY (`number`),

  INDEX `prescription_patient_id_index` (`patient_id`),
  INDEX `prescription_appointment_index` (`appointment_number`),

  CONSTRAINT `prescription_appointment_patient_foreign`
    FOREIGN KEY (`appointment_number`, `patient_id`) REFERENCES `appointment` (`number`, `patient_id`)
    ON DELETE RESTRICT ON UPDATE CASCADE

);

-- ============================
-- Views
-- ============================
DROP VIEW IF EXISTS `patient_appointments`;

CREATE VIEW `patient_appointments` AS
SELECT
  `patient`.`id`,
  `patient`.`name`,
  `patient`.`surname`,
  `appointment`.`number` AS `appointment_number`,
  `appointment`.`scheduled_at`,
  `doctor`.`surname` AS `doctor_surname`
FROM `patient`
JOIN `appointment` ON `patient`.`id` = `appointment`.`patient_id`
LEFT JOIN `doctor` ON `appointment`.`doctor_id` = `doctor`.`id`;


-- ============================
-- Triggers
-- ============================
DROP TRIGGER IF EXISTS `appointment_status_before_update`;
DROP TRIGGER IF EXISTS `appointment_status_before_insert`;

DELIMITER $$

CREATE TRIGGER `appointment_status_before_update`
BEFORE UPDATE ON `appointment`
FOR EACH ROW
BEGIN
  IF NEW.`cancel_date` IS NOT NULL THEN
    SET NEW.`status` = 'cancelled';
  ELSEIF NEW.`ended_at` IS NOT NULL THEN
    SET NEW.`status` = 'completed';
  ELSEIF NEW.`started_at` IS NOT NULL THEN
    SET NEW.`status` = 'started';
  ELSEIF NEW.`scheduled_at` IS NOT NULL THEN
    SET NEW.`status` = 'scheduled';
  ELSE
    SET NEW.`status` = 'scheduled'; -- safety fallback
  END IF;
END$$

CREATE TRIGGER `appointment_status_before_insert`
BEFORE INSERT ON `appointment`
FOR EACH ROW
BEGIN
  IF NEW.`cancel_date` IS NOT NULL THEN
    SET NEW.`status` = 'cancelled';
  ELSEIF NEW.`ended_at` IS NOT NULL THEN
    SET NEW.`status` = 'completed';
  ELSEIF NEW.`started_at` IS NOT NULL THEN
    SET NEW.`status` = 'started';
  ELSEIF NEW.`scheduled_at` IS NOT NULL THEN
    SET NEW.`status` = 'scheduled';
  ELSE
    SET NEW.`status` = 'scheduled'; -- safety fallback
  END IF;
END$$

DELIMITER ;
