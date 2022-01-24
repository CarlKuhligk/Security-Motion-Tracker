-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 24. Jan 2022 um 10:57
-- Server-Version: 10.4.22-MariaDB
-- PHP-Version: 8.1.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `imutracker`
--

DELIMITER $$
--
-- Prozeduren
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addDevice` ()  MODIFIES SQL DATA
BEGIN
	#get last device id and creat new unique tablename
    SET @last_device_id = (SELECT devices.id FROM devices ORDER BY devices.id DESC LIMIT 1);
    
    SET @new_device_id = COALESCE (@last_device_id +1,1);
    SET @new_table_name = CONCAT("device_", @new_device_id,"_log");
    
    #generate api key
    SET @new_api_key = (SELECT SHA2(CONCAT(CURRENT_TIMESTAMP(),@new_table_name),256));
	INSERT INTO devices(devices.id, devices.api_key) VALUES(@new_device_id, @new_api_key);
        
    SET @table_settings = '(`capture_id` int(11) NOT NULL,`timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),       `accX` float NOT NULL,      `accY` float NOT NULL,\r\n        `accZ` float NOT NULL,      `gyrX` float NOT NULL,      `gyrY` float NOT NULL,      `gyrZ` float NOT NULL,       `temp` float NOT NULL, `battery` int(11) NOT NULL, `status` int(11) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4';
    
    #creat new table
    SET @SQL = CONCAT('CREATE TABLE ',@new_table_name, @table_settings);
    PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    
    #setup primary key and autoincrement
    SET @SQL = CONCAT('ALTER TABLE ',@new_table_name, ' ADD PRIMARY KEY (capture_id);');
	PREPARE stmt FROM @SQL;
    EXECUTE stmt;

	SET @SQL = CONCAT('ALTER TABLE ',@new_table_name, ' MODIFY capture_id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;');
	PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    
    # insert new row in device settings
    INSERT INTO device_settings (device_id, acc_min, acc_max, gyr_min, gyr_max,  battery_warning, timeout, sense_freq)SELECT * FROM (SELECT devices.id AS device_id FROM devices ORDER BY id DESC LIMIT 1) AS DEVICEID,(SELECT acc_min, acc_max, gyr_min, gyr_max,  battery_warning, timeout, sense_freq FROM device_settings WHERE id = 0 LIMIT 1) AS DEFAULTSETTINGS;

 
   

    
    DEALLOCATE PREPARE stmt;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_device_data` (IN `days` INT(11))  BEGIN
    DECLARE temp_tablename CHAR(32);
	DECLARE not_done INT DEFAULT TRUE;
    DECLARE db_cursor CURSOR FOR SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE engine = 'innodb' AND table_schema = 'imutracker' AND table_name LIKE 'device_%%_log%';
    
    # condition older 7 Days -> WHERE TIMESTAMPDIFF(DAY, timestamp, CURRENT_TIMESTAMP) >= 7

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET not_done = FALSE;

	OPEN db_cursor;

WHILE not_done DO
    FETCH db_cursor INTO temp_tablename;
    
    SET @SQL = CONCAT('DELETE FROM ',temp_tablename, ' WHERE TIMESTAMPDIFF(DAY, timestamp, CURRENT_TIMESTAMP) >= ',days,';');
	PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    
END WHILE;

DEALLOCATE PREPARE stmt;
COMMIT;
CLOSE db_cursor;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `resetTable` (IN `tableName` VARCHAR(32))  MODIFIES SQL DATA
BEGIN
    SET @SQL = CONCAT('DELETE FROM ', tableName);
    PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    
	SET @SQL = CONCAT('ALTER TABLE ', tableName, ' AUTO_INCREMENT = 1');
    PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `devices`
--

CREATE TABLE `devices` (
  `id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `api_key` char(64) NOT NULL,
  `changed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `online` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `devices`
--

INSERT INTO `devices` (`id`, `staff_id`, `api_key`, `changed`, `created`, `online`) VALUES
(1, 1, 'cceb996336b98f2c9cb6136d96f47457b3dc8b301012d468a4634c8fefafe002', '2022-01-24 09:56:58', '2022-01-17 20:55:21', 0),
(2, 0, '7df6d13e87d8c9d6cbb997ac810bfdb74e4738fac1b98a07560399c9e9d24448', '2022-01-24 09:51:42', '2022-01-24 09:51:42', 0);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `device_1_log`
--

CREATE TABLE `device_1_log` (
  `capture_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `accX` float NOT NULL,
  `accY` float NOT NULL,
  `accZ` float NOT NULL,
  `gyrX` float NOT NULL,
  `gyrY` float NOT NULL,
  `gyrZ` float NOT NULL,
  `temp` float NOT NULL,
  `battery` int(11) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `device_1_log`
--

INSERT INTO `device_1_log` (`capture_id`, `timestamp`, `accX`, `accY`, `accZ`, `gyrX`, `gyrY`, `gyrZ`, `temp`, `battery`, `status`) VALUES
(10005, '2022-01-23 12:19:33', 50, 71, 1, 54, 75, 87, 78, 5, 37),
(10006, '2022-01-23 12:19:36', 50, 71, 1, 54, 75, 87, 78, 5, 37),
(10007, '2022-01-23 12:19:39', 50, 71, 1, 54, 75, 87, 78, 5, 37),
(10008, '2022-01-23 12:20:04', 50, 71, 1, 54, 75, 87, 78, 5, 37);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `device_2_log`
--

CREATE TABLE `device_2_log` (
  `capture_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `accX` float NOT NULL,
  `accY` float NOT NULL,
  `accZ` float NOT NULL,
  `gyrX` float NOT NULL,
  `gyrY` float NOT NULL,
  `gyrZ` float NOT NULL,
  `temp` float NOT NULL,
  `battery` int(11) NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `device_settings`
--

CREATE TABLE `device_settings` (
  `id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `acc_min` float NOT NULL,
  `acc_max` float NOT NULL,
  `gyr_min` float NOT NULL,
  `gyr_max` float NOT NULL,
  `battery_warning` int(11) NOT NULL,
  `timeout` int(11) NOT NULL,
  `sense_freq` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `device_settings`
--

INSERT INTO `device_settings` (`id`, `device_id`, `acc_min`, `acc_max`, `gyr_min`, `gyr_max`, `battery_warning`, `timeout`, `sense_freq`) VALUES
(0, 0, 0, 500, 0, 300, 15, 30, 1),
(5, 1, 0, 500, 0, 300, 15, 30, 1),
(6, 2, 0, 500, 0, 300, 15, 30, 1);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `event_log`
--

CREATE TABLE `event_log` (
  `device_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `trigger_capture_id` int(11) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `staff`
--

CREATE TABLE `staff` (
  `id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `pin` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Daten für Tabelle `staff`
--

INSERT INTO `staff` (`id`, `name`, `pin`) VALUES
(1, 'debugger', '12345');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `device_1_log`
--
ALTER TABLE `device_1_log`
  ADD PRIMARY KEY (`capture_id`);

--
-- Indizes für die Tabelle `device_2_log`
--
ALTER TABLE `device_2_log`
  ADD PRIMARY KEY (`capture_id`);

--
-- Indizes für die Tabelle `device_settings`
--
ALTER TABLE `device_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `event_log`
--
ALTER TABLE `event_log`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `devices`
--
ALTER TABLE `devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `device_1_log`
--
ALTER TABLE `device_1_log`
  MODIFY `capture_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10009;

--
-- AUTO_INCREMENT für Tabelle `device_2_log`
--
ALTER TABLE `device_2_log`
  MODIFY `capture_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `device_settings`
--
ALTER TABLE `device_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT für Tabelle `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `event_log`
--
ALTER TABLE `event_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
