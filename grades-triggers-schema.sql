-- phpMyAdmin SQL Dump
-- version 4.0.4.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 24, 2013 at 04:27 PM
-- Server version: 5.6.12
-- PHP Version: 5.5.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `grades-triggers`
--
CREATE DATABASE IF NOT EXISTS `grades-triggers` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `grades-triggers`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `assignment_meanGrade`(IN `paramAssignmentId` INT)
    NO SQL
update assignment
set assignment.derived_meanGrade = (
    select avg(derived_grade)
    from submission
    where assignmentId = paramAssignmentId
)
where id = paramAssignmentId$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `assignment`
--

CREATE TABLE IF NOT EXISTS `assignment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unitId` int(11) NOT NULL,
  `derived_meanGrade` decimal(4,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=101 ;

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE IF NOT EXISTS `student` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `submission`
--

CREATE TABLE IF NOT EXISTS `submission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `studentId` int(11) NOT NULL,
  `assignmentId` int(11) NOT NULL,
  `data` text COLLATE utf8_unicode_ci NOT NULL,
  `derived_grade` decimal(4,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=100001 ;

--
-- Triggers `submission`
--
DROP TRIGGER IF EXISTS `assignment_meanGrade_delete`;
DELIMITER //
CREATE TRIGGER `assignment_meanGrade_delete` AFTER DELETE ON `submission`
 FOR EACH ROW call assignment_meanGrade(OLD.assignmentId)
//
DELIMITER ;
DROP TRIGGER IF EXISTS `assignment_meanGrade_insert`;
DELIMITER //
CREATE TRIGGER `assignment_meanGrade_insert` AFTER INSERT ON `submission`
 FOR EACH ROW call assignment_meanGrade(NEW.assignmentId)
//
DELIMITER ;
DROP TRIGGER IF EXISTS `assignment_meanGrade_update`;
DELIMITER //
CREATE TRIGGER `assignment_meanGrade_update` AFTER UPDATE ON `submission`
 FOR EACH ROW call assignment_meanGrade(NEW.assignmentId)
//
DELIMITER ;
DROP TRIGGER IF EXISTS `submission_grade_insert`;
DELIMITER //
CREATE TRIGGER `submission_grade_insert` BEFORE INSERT ON `submission`
 FOR EACH ROW SET NEW.derived_grade = ((cast(substr(NEW.`data`,11) as decimal(10,0)) / 10) % 10)
//
DELIMITER ;
DROP TRIGGER IF EXISTS `submission_grade_update`;
DELIMITER //
CREATE TRIGGER `submission_grade_update` BEFORE UPDATE ON `submission`
 FOR EACH ROW SET NEW.derived_grade = ((cast(substr(NEW.`data`,11) as decimal(10,0)) / 10) % 10)
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `unit`
--

CREATE TABLE IF NOT EXISTS `unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parentId` int(11) DEFAULT NULL,
  `derived_meanGrade` decimal(4,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=26 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
