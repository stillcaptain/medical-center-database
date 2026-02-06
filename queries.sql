-- show all appointments
SELECT
  `patient`.`name`,
  `patient`.`surname`,
  `patient`.`amka`,
  `appointment`.`scheduled_at`,
  `doctor`.`surname` AS `doctor_surname`,
  `doctor`.`specialty` AS `specialty`
FROM `patient`
JOIN `appointment` ON `patient`.`id` = `appointment`.`patient_id`
LEFT JOIN `doctor` ON `appointment`.`doctor_id` = `doctor`.`id`;

-- all patients for Dr Kostas:
SELECT
  `doctor`.`name` AS `doctor_name`,
  `doctor`.`surname` AS `doctor_surname`,
  `patient`.`name`,
  `patient`.`surname`
FROM `patient`
JOIN `appointment` ON `patient`.`id` = `appointment`.`patient_id`
JOIN `doctor` ON `appointment`.`doctor_id` = `doctor`.`id`
WHERE `doctor`.`id` = 3;

-- search patients by surname prefix (fast because of index)
SELECT `id`, `name`, `surname`, `mobile`, `amka`
FROM `patient`
WHERE `surname` LIKE 'Pa%';

-- show patients born after 1995
SELECT `id`, `name`, `surname`, `birth_date`
FROM `patient`
WHERE `birth_date` > '1995-01-01'
ORDER BY `birth_date`;

-- list doctors by specialty
SELECT `id`, `name`, `surname`, `birth_date`
FROM `doctor`
WHERE `specialty` = 'cardiologist'
ORDER BY `surname`, `name`;

-- show upcoming appointments
SELECT
  `appointment`.`number`,
  `appointment`.`scheduled_at`,
  `patient`.`name`,
  `patient`.`surname`,
  `doctor`.`name` AS `doctor_name`,
  `doctor`.`surname` AS `doctor_surname`,
  `appointment`.`status`
FROM `appointment`
JOIN `patient` ON `patient`.`id` = `appointment`.`patient_id`
LEFT JOIN `doctor` ON `doctor`.`id` = `appointment`.`doctor_id`
WHERE `appointment`.`scheduled_at` >= NOW()
  AND `appointment`.`scheduled_at` < (NOW() + INTERVAL 7 DAY)
ORDER BY `appointment`.`scheduled_at`;

-- history for patient id 1
SELECT
  `appointment`.`number`,
  `appointment`.`scheduled_at`,
  `appointment`.`started_at`,
  `appointment`.`ended_at`,
  `appointment`.`cancel_date`,
  `appointment`.`status`,
  `doctor`.`name` AS `doctor_name`,
  `doctor`.`surname` AS `doctor_surname`,
  `appointment`.`medical_report`
FROM `appointment`
LEFT JOIN `doctor` ON `doctor`.`id` = `appointment`.`doctor_id`
WHERE `appointment`.`patient_id` = 1
ORDER BY `appointment`.`scheduled_at` DESC;

-- perscriptions tied to specific appointment
SELECT
  `prescription`.`number`,
  `prescription`.`created_date`,
  `prescription`.`medicine`,
  `prescription`.`participation_fee`
FROM `prescription`
WHERE `prescription`.`appointment_number` = 10
ORDER BY `prescription`.`created_date`;
