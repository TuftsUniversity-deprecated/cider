-- MySQL dump 10.13  Distrib 5.1.54, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: cider
-- ------------------------------------------------------
-- Server version	5.1.54-1ubuntu4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `authority_name`
--

DROP TABLE IF EXISTS `authority_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authority_name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9720 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collection_relationship`
--

DROP TABLE IF EXISTS `collection_relationship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collection_relationship` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection` int(11) NOT NULL,
  `predicate` int(11) NOT NULL,
  `pid` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `collection` (`collection`),
  KEY `predicate` (`predicate`),
  CONSTRAINT `collection_relationship_ibfk_2` FOREIGN KEY (`predicate`) REFERENCES `relationship_predicate` (`id`),
  CONSTRAINT `collection_relationship_ibfk_1` FOREIGN KEY (`collection`) REFERENCES `object` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geographic_term`
--

DROP TABLE IF EXISTS `geographic_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `geographic_term` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1780 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_format`
--

DROP TABLE IF EXISTS `item_format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_format` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_restrictions`
--

DROP TABLE IF EXISTS `item_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_restrictions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_type`
--

DROP TABLE IF EXISTS `item_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location` (
  `barcode` char(16) NOT NULL,
  `unit_type` int(11) NOT NULL,
  PRIMARY KEY (`barcode`),
  KEY `unit_type` (`unit_type`),
  CONSTRAINT `location_ibfk_1` FOREIGN KEY (`unit_type`) REFERENCES `location_unit_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location_collection_number`
--

DROP TABLE IF EXISTS `location_collection_number`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_collection_number` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` char(16) NOT NULL,
  `number` char(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `location` (`location`),
  CONSTRAINT `location_collection_number_ibfk_1` FOREIGN KEY (`location`) REFERENCES `location` (`barcode`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location_series_number`
--

DROP TABLE IF EXISTS `location_series_number`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_series_number` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` char(16) NOT NULL,
  `number` char(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `location` (`location`),
  CONSTRAINT `location_series_number_ibfk_1` FOREIGN KEY (`location`) REFERENCES `location` (`barcode`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location_title`
--

DROP TABLE IF EXISTS `location_title`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_title` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` char(16) NOT NULL,
  `title` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `location` (`location`),
  CONSTRAINT `location_title_ibfk_1` FOREIGN KEY (`location`) REFERENCES `location` (`barcode`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location_unit_type`
--

DROP TABLE IF EXISTS `location_unit_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location_unit_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `volume` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` char(16) NOT NULL,
  `timestamp` datetime NOT NULL,
  `user` int(11) NOT NULL,
  `object` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  KEY `object` (`object`),
  CONSTRAINT `log_ibfk_2` FOREIGN KEY (`object`) REFERENCES `object` (`id`) ON DELETE CASCADE,
  CONSTRAINT `log_ibfk_1` FOREIGN KEY (`user`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=593 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object`
--

DROP TABLE IF EXISTS `object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date_from` varchar(10) DEFAULT NULL,
  `date_to` varchar(10) DEFAULT NULL,
  `bulk_date_from` varchar(10) DEFAULT NULL,
  `bulk_date_to` varchar(10) DEFAULT NULL,
  `record_context` int(11) DEFAULT NULL,
  `history` text,
  `scope` text,
  `organization` text,
  `processing_status` tinyint(4) DEFAULT NULL,
  `has_physical_documentation` enum('0','1') DEFAULT NULL,
  `processing_notes` text,
  `description` text,
  `location` char(16) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `format` int(11) DEFAULT NULL,
  `funder` char(128) DEFAULT NULL,
  `handle` char(128) DEFAULT NULL,
  `checksum` char(64) DEFAULT NULL,
  `original_filename` char(255) DEFAULT NULL,
  `accession_by` char(255) DEFAULT NULL,
  `accession_date` varchar(10) DEFAULT NULL,
  `accession_procedure` text,
  `accession_number` char(128) DEFAULT NULL,
  `stabilization_by` char(255) DEFAULT NULL,
  `stabilization_date` varchar(10) DEFAULT NULL,
  `stabilization_procedure` text,
  `stabilization_notes` text,
  `virus_app` char(128) DEFAULT NULL,
  `checksum_app` char(128) DEFAULT NULL,
  `media_app` char(128) DEFAULT NULL,
  `other_app` char(128) DEFAULT NULL,
  `toc` text,
  `rsa` text,
  `technical_metadata` text,
  `file_creation_date` varchar(10) DEFAULT NULL,
  `lc_class` char(255) DEFAULT NULL,
  `file_extension` char(16) DEFAULT NULL,
  `parent` int(11) DEFAULT NULL,
  `number` char(255) NOT NULL,
  `title` char(255) NOT NULL,
  `personal_name` int(11) DEFAULT NULL,
  `corporate_name` int(11) DEFAULT NULL,
  `topic_term` int(11) DEFAULT NULL,
  `geographic_term` int(11) DEFAULT NULL,
  `notes` text,
  `circa` tinyint(1) NOT NULL DEFAULT '0',
  `language` char(3) NOT NULL DEFAULT 'eng',
  `permanent_url` varchar(1024) DEFAULT NULL,
  `pid` varchar(255) DEFAULT NULL,
  `publication_status` varchar(16) DEFAULT NULL,
  `arrangement` varchar(255) DEFAULT NULL,
  `restrictions` int(11) DEFAULT NULL,
  `creator` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number` (`number`),
  KEY `parent` (`parent`),
  KEY `personal_name` (`personal_name`),
  KEY `corporate_name` (`corporate_name`),
  KEY `topic_term` (`topic_term`),
  KEY `geographic_term` (`geographic_term`),
  KEY `type` (`type`),
  KEY `format` (`format`),
  KEY `processing_status` (`processing_status`),
  KEY `record_creator` (`record_context`),
  KEY `location` (`location`),
  KEY `restrictions` (`restrictions`),
  KEY `creator` (`creator`),
  CONSTRAINT `object_ibfk_1` FOREIGN KEY (`parent`) REFERENCES `object` (`id`),
  CONSTRAINT `object_ibfk_11` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`),
  CONSTRAINT `object_ibfk_12` FOREIGN KEY (`record_context`) REFERENCES `record_context` (`id`),
  CONSTRAINT `object_ibfk_13` FOREIGN KEY (`location`) REFERENCES `location` (`barcode`),
  CONSTRAINT `object_ibfk_14` FOREIGN KEY (`restrictions`) REFERENCES `item_restrictions` (`id`),
  CONSTRAINT `object_ibfk_15` FOREIGN KEY (`creator`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_2` FOREIGN KEY (`personal_name`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_3` FOREIGN KEY (`corporate_name`) REFERENCES `authority_name` (`id`),
  CONSTRAINT `object_ibfk_4` FOREIGN KEY (`topic_term`) REFERENCES `topic_term` (`id`),
  CONSTRAINT `object_ibfk_5` FOREIGN KEY (`geographic_term`) REFERENCES `geographic_term` (`id`),
  CONSTRAINT `object_ibfk_6` FOREIGN KEY (`processing_status`) REFERENCES `processing_status` (`id`),
  CONSTRAINT `object_ibfk_8` FOREIGN KEY (`type`) REFERENCES `item_type` (`id`),
  CONSTRAINT `object_ibfk_9` FOREIGN KEY (`format`) REFERENCES `item_format` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object_set`
--

DROP TABLE IF EXISTS `object_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_set` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` char(255) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`),
  CONSTRAINT `object_set_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `object_set_object`
--

DROP TABLE IF EXISTS `object_set_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object_set_object` (
  `object_set` int(11) NOT NULL DEFAULT '0',
  `object` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`object_set`,`object`),
  KEY `object` (`object`),
  CONSTRAINT `object_set_object_ibfk_1` FOREIGN KEY (`object_set`) REFERENCES `object_set` (`id`),
  CONSTRAINT `object_set_object_ibfk_2` FOREIGN KEY (`object`) REFERENCES `object` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `processing_status`
--

DROP TABLE IF EXISTS `processing_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `processing_status` (
  `id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `record_context`
--

DROP TABLE IF EXISTS `record_context`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `record_context` (
  `id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `related_collection`
--

DROP TABLE IF EXISTS `related_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `related_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object` int(11) NOT NULL,
  `name` char(255) DEFAULT NULL,
  `custodian` char(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `object` (`object`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relationship_predicate`
--

DROP TABLE IF EXISTS `relationship_predicate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationship_predicate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `predicate` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `predicate` (`predicate`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `role` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_term`
--

DROP TABLE IF EXISTS `topic_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic_term` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2163 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `role_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` char(64) DEFAULT NULL,
  `password` char(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-07-07 15:12:43
