SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

CREATE DATABASE IF NOT EXISTS `grades-views` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `grades-views`;

CREATE TABLE IF NOT EXISTS `assignment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unitId` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=101 ;
CREATE TABLE IF NOT EXISTS `assignment_meangrades` (
`id` int(11)
,`unitId` int(11)
,`meanGrade` decimal(18,8)
);
CREATE TABLE IF NOT EXISTS `student` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1001 ;
CREATE TABLE IF NOT EXISTS `studentunit_meangrades_assignmentonly` (
`id` int(11)
,`parentId` int(11)
,`studentId` int(11)
,`meanGrade` decimal(18,8)
);CREATE TABLE IF NOT EXISTS `studentunit_meangrades_level1` (
`id` int(11)
,`parentId` int(11)
,`studentId` int(11)
,`meanGrade` decimal(22,12)
);CREATE TABLE IF NOT EXISTS `studentunit_meangrades_level2` (
`id` int(11)
,`parentId` int(11)
,`studentId` int(11)
,`meanGrade` decimal(26,16)
);CREATE TABLE IF NOT EXISTS `studentunit_meangrades_union` (
`id` int(11)
,`parentId` int(11)
,`studentId` int(11)
,`meanGrade` decimal(26,16)
);CREATE TABLE IF NOT EXISTS `student_assignment` (
`studentId` int(11)
,`assignmentId` int(11)
,`data` text
,`grade` decimal(14,4)
,`unitId` int(11)
);
CREATE TABLE IF NOT EXISTS `submission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `studentId` int(11) NOT NULL,
  `assignmentId` int(11) NOT NULL,
  `data` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=100001 ;
CREATE TABLE IF NOT EXISTS `submission_graded` (
`id` int(11)
,`studentId` int(11)
,`assignmentId` int(11)
,`data` text
,`grade` decimal(14,4)
);
CREATE TABLE IF NOT EXISTS `unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parentId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=26 ;
CREATE TABLE IF NOT EXISTS `unit_meangrades_assignmentonly` (
`id` int(11)
,`parentId` int(11)
,`meanGrade` decimal(22,12)
);CREATE TABLE IF NOT EXISTS `unit_meangrades_level1` (
`id` int(11)
,`parentId` int(11)
,`meanGrade` decimal(26,16)
);CREATE TABLE IF NOT EXISTS `unit_meangrades_level2` (
`id` int(11)
,`parentId` int(11)
,`meanGrade` decimal(30,20)
);CREATE TABLE IF NOT EXISTS `unit_meangrades_union` (
`id` int(11)
,`parentId` int(11)
,`meanGrade` decimal(30,20)
);DROP TABLE IF EXISTS `assignment_meangrades`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `assignment_meangrades` AS select `assignment`.`id` AS `id`,`assignment`.`unitId` AS `unitId`,avg(`submission_graded`.`grade`) AS `meanGrade` from (`assignment` join `submission_graded`) where (`assignment`.`id` = `submission_graded`.`assignmentId`) group by `assignment`.`id`;
DROP TABLE IF EXISTS `studentunit_meangrades_assignmentonly`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studentunit_meangrades_assignmentonly` AS select `u`.`id` AS `id`,`u`.`parentId` AS `parentId`,`sa`.`studentId` AS `studentId`,avg(`sa`.`grade`) AS `meanGrade` from (`student_assignment` `sa` join `unit` `u`) where (`sa`.`unitId` = `u`.`id`) group by `u`.`id`,`sa`.`studentId`;
DROP TABLE IF EXISTS `studentunit_meangrades_level1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studentunit_meangrades_level1` AS select `u`.`id` AS `id`,`u`.`parentId` AS `parentId`,`su`.`studentId` AS `studentId`,avg(`su`.`meanGrade`) AS `meanGrade` from (`studentunit_meangrades_assignmentonly` `su` join `unit` `u`) where (`su`.`parentId` = `u`.`id`) group by `u`.`id`,`su`.`studentId`;
DROP TABLE IF EXISTS `studentunit_meangrades_level2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studentunit_meangrades_level2` AS select `u`.`id` AS `id`,`u`.`parentId` AS `parentId`,`su`.`studentId` AS `studentId`,avg(`su`.`meanGrade`) AS `meanGrade` from (`studentunit_meangrades_level1` `su` join `unit` `u`) where (`su`.`parentId` = `u`.`id`) group by `u`.`id`,`su`.`studentId`;
DROP TABLE IF EXISTS `studentunit_meangrades_union`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studentunit_meangrades_union` AS select `studentunit_meangrades_assignmentonly`.`id` AS `id`,`studentunit_meangrades_assignmentonly`.`parentId` AS `parentId`,`studentunit_meangrades_assignmentonly`.`studentId` AS `studentId`,`studentunit_meangrades_assignmentonly`.`meanGrade` AS `meanGrade` from `studentunit_meangrades_assignmentonly` union select `studentunit_meangrades_level1`.`id` AS `id`,`studentunit_meangrades_level1`.`parentId` AS `parentId`,`studentunit_meangrades_level1`.`studentId` AS `studentId`,`studentunit_meangrades_level1`.`meanGrade` AS `meanGrade` from `studentunit_meangrades_level1` union select `studentunit_meangrades_level2`.`id` AS `id`,`studentunit_meangrades_level2`.`parentId` AS `parentId`,`studentunit_meangrades_level2`.`studentId` AS `studentId`,`studentunit_meangrades_level2`.`meanGrade` AS `meanGrade` from `studentunit_meangrades_level2`;
DROP TABLE IF EXISTS `student_assignment`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `student_assignment` AS select `su`.`studentId` AS `studentId`,`su`.`assignmentId` AS `assignmentId`,`su`.`data` AS `data`,`su`.`grade` AS `grade`,`a`.`unitId` AS `unitId` from ((`assignment` `a` join `submission_graded` `su`) join `student` `st`) where ((`a`.`id` = `su`.`assignmentId`) and (`st`.`id` = `su`.`studentId`));
DROP TABLE IF EXISTS `submission_graded`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `submission_graded` AS select `submission`.`id` AS `id`,`submission`.`studentId` AS `studentId`,`submission`.`assignmentId` AS `assignmentId`,`submission`.`data` AS `data`,((cast(substr(`submission`.`data`,11) as decimal(10,0)) / 10) % 10) AS `grade` from `submission`;
DROP TABLE IF EXISTS `unit_meangrades_assignmentonly`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `unit_meangrades_assignmentonly` AS select `unit`.`id` AS `id`,`unit`.`parentId` AS `parentId`,avg(`assignment_meangrades`.`meanGrade`) AS `meanGrade` from (`unit` join `assignment_meangrades`) where (`unit`.`id` = `assignment_meangrades`.`unitId`) group by `unit`.`id`;
DROP TABLE IF EXISTS `unit_meangrades_level1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `unit_meangrades_level1` AS select `u1`.`id` AS `id`,`u1`.`parentId` AS `parentId`,avg(`u2`.`meanGrade`) AS `meanGrade` from (`unit` `u1` join `unit_meangrades_assignmentonly` `u2`) where (`u1`.`id` = `u2`.`parentId`) group by `u1`.`id`;
DROP TABLE IF EXISTS `unit_meangrades_level2`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `unit_meangrades_level2` AS select `u1`.`id` AS `id`,`u1`.`parentId` AS `parentId`,avg(`u2`.`meanGrade`) AS `meanGrade` from (`unit` `u1` join `unit_meangrades_level1` `u2`) where (`u1`.`id` = `u2`.`parentId`) group by `u1`.`id`;
DROP TABLE IF EXISTS `unit_meangrades_union`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `unit_meangrades_union` AS select `unit_meangrades_assignmentonly`.`id` AS `id`,`unit_meangrades_assignmentonly`.`parentId` AS `parentId`,`unit_meangrades_assignmentonly`.`meanGrade` AS `meanGrade` from `unit_meangrades_assignmentonly` union select `unit_meangrades_level1`.`id` AS `id`,`unit_meangrades_level1`.`parentId` AS `parentId`,`unit_meangrades_level1`.`meanGrade` AS `meanGrade` from `unit_meangrades_level1` union select `unit_meangrades_level2`.`id` AS `id`,`unit_meangrades_level2`.`parentId` AS `parentId`,`unit_meangrades_level2`.`meanGrade` AS `meanGrade` from `unit_meangrades_level2`;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
