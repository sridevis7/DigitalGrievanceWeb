-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.22-community-nt


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema grievance_portal
--

CREATE DATABASE IF NOT EXISTS grievance_portal;
USE grievance_portal;

--
-- Definition of table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `id` int(11) NOT NULL auto_increment,
  `grievance_id` int(11) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `rating` int(11) NOT NULL,
  `comments` varchar(500) default NULL,
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `grievance_id` (`grievance_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`grievance_id`) REFERENCES `grievances` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `feedback`
--

/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;


--
-- Definition of table `grievances`
--

DROP TABLE IF EXISTS `grievances`;
CREATE TABLE `grievances` (
  `id` int(11) NOT NULL auto_increment,
  `user_email` varchar(100) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `category` varchar(100) NOT NULL,
  `priority` varchar(20) NOT NULL,
  `department` varchar(100) NOT NULL,
  `state` varchar(50) NOT NULL,
  `district` varchar(100) NOT NULL,
  `location` text NOT NULL,
  `description` text NOT NULL,
  `expected_resolution` text,
  `attachment` longblob,
  `status` enum('Pending','Processing','In Progress','Resolved') default 'Pending',
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `official_remark` varchar(500) default NULL,
  `official_attachment` longblob,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `grievances`
--

/*!40000 ALTER TABLE `grievances` DISABLE KEYS */;
/*!40000 ALTER TABLE `grievances` ENABLE KEYS */;


--
-- Definition of table `official_logs`
--

DROP TABLE IF EXISTS `official_logs`;
CREATE TABLE `official_logs` (
  `id` int(11) NOT NULL auto_increment,
  `official_name` varchar(100) default NULL,
  `department` varchar(100) default NULL,
  `action` varchar(255) default NULL,
  `log_time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `official_logs`
--

/*!40000 ALTER TABLE `official_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `official_logs` ENABLE KEYS */;


--
-- Definition of table `officials`
--

DROP TABLE IF EXISTS `officials`;
CREATE TABLE `officials` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `department` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL default '123',
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `officials`
--

/*!40000 ALTER TABLE `officials` DISABLE KEYS */;
/*!40000 ALTER TABLE `officials` ENABLE KEYS */;


--
-- Definition of table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `fullname` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) default NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
