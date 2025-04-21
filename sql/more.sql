CREATE DATABASE  IF NOT EXISTS `flightsystem` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `flightsystem`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: flightsystem
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aircraft`
--

DROP TABLE IF EXISTS `aircraft`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aircraft` (
  `craftNum` int NOT NULL AUTO_INCREMENT,
  `airID` char(2) DEFAULT NULL,
  `firstSeatNum` int DEFAULT NULL,
  `businessSeatNum` int DEFAULT NULL,
  `economySeatNum` int DEFAULT NULL,
  PRIMARY KEY (`craftNum`),
  KEY `airID` (`airID`),
  CONSTRAINT `aircraft_ibfk_1` FOREIGN KEY (`airID`) REFERENCES `airline` (`airID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aircraft`
--

LOCK TABLES `aircraft` WRITE;
/*!40000 ALTER TABLE `aircraft` DISABLE KEYS */;
INSERT INTO `aircraft` VALUES (1,'AA',14,30,200),(2,'DL',14,50,250),(3,'UA',14,70,300),(4,'UA',14,38,154),(5,'DL',11,29,174),(6,'UA',17,24,145),(7,'DL',12,39,163),(8,'UA',13,25,188),(9,'DL',16,29,147),(10,'AA',19,31,128);
/*!40000 ALTER TABLE `aircraft` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `airline`
--

DROP TABLE IF EXISTS `airline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `airline` (
  `airID` char(2) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`airID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `airline`
--

LOCK TABLES `airline` WRITE;
/*!40000 ALTER TABLE `airline` DISABLE KEYS */;
INSERT INTO `airline` VALUES ('AA','American Airlines'),('DL','Delta Airlines'),('UA','United Airlines');
/*!40000 ALTER TABLE `airline` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `airlineassociatedairport`
--

DROP TABLE IF EXISTS `airlineassociatedairport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `airlineassociatedairport` (
  `airID` char(2) NOT NULL,
  `portID` char(3) NOT NULL,
  PRIMARY KEY (`airID`,`portID`),
  KEY `portID` (`portID`),
  CONSTRAINT `airlineassociatedairport_ibfk_1` FOREIGN KEY (`airID`) REFERENCES `airline` (`airID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `airlineassociatedairport_ibfk_2` FOREIGN KEY (`portID`) REFERENCES `airport` (`portID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `airlineassociatedairport`
--

LOCK TABLES `airlineassociatedairport` WRITE;
/*!40000 ALTER TABLE `airlineassociatedairport` DISABLE KEYS */;
INSERT INTO `airlineassociatedairport` VALUES ('UA','DFW'),('AA','JFK'),('UA','JFK'),('AA','LAX'),('DL','LAX'),('UA','LAX'),('AA','LHR'),('DL','LHR'),('AA','ORD'),('DL','ORD'),('UA','ORD');
/*!40000 ALTER TABLE `airlineassociatedairport` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `airport`
--

DROP TABLE IF EXISTS `airport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `airport` (
  `portID` char(3) NOT NULL,
  `location` varchar(40) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`portID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `airport`
--

LOCK TABLES `airport` WRITE;
/*!40000 ALTER TABLE `airport` DISABLE KEYS */;
INSERT INTO `airport` VALUES ('ATL','Atlanta, GA','Hartsfield–Jackson Atlanta International Airport'),('DFW','Dallas, TX','Dallas/Fort Worth International'),('JFK','New York, NY','John F. Kennedy International'),('LAX','Los Angeles, CA','Los Angeles International'),('LHR','London, UK','Heathrow Airport'),('ORD','Chicago, IL','O\'Hare International');
/*!40000 ALTER TABLE `airport` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flight`
--

DROP TABLE IF EXISTS `flight`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flight` (
  `airID` char(2) NOT NULL,
  `flightNum` int NOT NULL,
  `flightType` enum('Domestic','International') DEFAULT NULL,
  `price` double DEFAULT NULL,
  `operating_days` tinyint unsigned DEFAULT NULL COMMENT '1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun',
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `dep_portID` char(3) DEFAULT NULL,
  `arr_portID` char(3) DEFAULT NULL,
  `domestic_reg` varchar(150) DEFAULT NULL,
  `international_reg` varchar(150) DEFAULT NULL,
  `craftNum` int DEFAULT NULL,
  `openFirstSeats` int DEFAULT NULL,
  `openBusinessSeats` int DEFAULT NULL,
  `openEconomySeats` int DEFAULT NULL,
  PRIMARY KEY (`airID`,`flightNum`),
  KEY `craftNum` (`craftNum`),
  KEY `dep_portID` (`dep_portID`),
  KEY `arr_portID` (`arr_portID`),
  CONSTRAINT `flight_ibfk_1` FOREIGN KEY (`airID`) REFERENCES `airline` (`airID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `flight_ibfk_2` FOREIGN KEY (`craftNum`) REFERENCES `aircraft` (`craftNum`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `flight_ibfk_3` FOREIGN KEY (`dep_portID`) REFERENCES `airport` (`portID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `flight_ibfk_4` FOREIGN KEY (`arr_portID`) REFERENCES `airport` (`portID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flight`
--

LOCK TABLES `flight` WRITE;
/*!40000 ALTER TABLE `flight` DISABLE KEYS */;
INSERT INTO `flight` VALUES ('AA',101,'Domestic',299.99,10,'2025-04-15','08:00:00','2025-04-15','11:00:00','JFK','LAX','US Domestic Reg A',NULL,1,15,30,120),('DL',202,'Domestic',199.99,20,'2025-04-16','13:00:00','2025-04-16','16:00:00','ORD','DFW','US Domestic Reg B',NULL,2,13,42,83),('DL',1002,'Domestic',894.99,73,'2025-05-16','16:30:00','2025-05-16','20:21:00','LHR','LAX','US-1195',NULL,1,15,39,170),('DL',1007,'International',709.47,66,'2025-04-22','07:30:00','2025-04-22','22:58:00','LAX','ORD',NULL,'INT-9797',4,14,38,154),('DL',1010,'Domestic',1382.96,22,'2025-05-10','02:18:00','2025-05-10','17:09:00','ATL','LHR','US-6155',NULL,2,20,35,186),('DL',1016,'International',1160.53,83,'2025-04-27','04:02:00','2025-04-27','15:01:00','ATL','LHR',NULL,'INT-9133',3,11,26,102),('DL',3562,'Domestic',1849.34,22,'2025-06-22','04:34:00','2025-06-22','08:30:00','LHR','ATL','US-6155',NULL,3,35,22,100),('UA',303,'International',599.99,40,'2025-04-17','22:00:00','2025-04-18','06:00:00','DFW','JFK',NULL,'INTL Reg Z',3,5,31,267),('UA',1000,'Domestic',602.88,106,'2025-05-06','00:36:00','2025-05-06','03:45:00','LHR','ATL','US-2338',NULL,5,11,29,174),('UA',1018,'International',1311.86,40,'2025-05-17','06:12:00','2025-05-17','17:25:00','ORD','LHR',NULL,'INT-6191',2,20,35,186),('UA',1019,'Domestic',1440.28,12,'2025-04-29','07:06:00','2025-04-29','19:11:00','JFK','LHR','US-3323',NULL,8,13,25,188),('UA',1020,'Domestic',420,20,'2025-04-16','18:00:00','2025-04-16','21:00:00','ATL','JFK','US-4451',NULL,8,16,30,190);
/*!40000 ALTER TABLE `flight` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `postquestions`
--

DROP TABLE IF EXISTS `postquestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `postquestions` (
  `userID` int NOT NULL,
  `questionID` int NOT NULL,
  `postedDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`,`questionID`),
  KEY `questionID` (`questionID`),
  CONSTRAINT `postquestions_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `postquestions_ibfk_2` FOREIGN KEY (`questionID`) REFERENCES `qatable` (`questionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `postquestions`
--

LOCK TABLES `postquestions` WRITE;
/*!40000 ALTER TABLE `postquestions` DISABLE KEYS */;
INSERT INTO `postquestions` VALUES (2,1,'2025-04-01 09:30:00'),(2,5,'2025-04-01 11:00:00'),(2,9,'2025-04-01 12:15:00'),(3,2,'2025-04-01 10:00:00'),(3,6,'2025-04-01 11:10:00'),(3,10,'2025-04-01 12:30:00'),(3,11,'2025-04-20 00:52:00'),(4,3,'2025-04-01 10:15:00'),(4,7,'2025-04-01 11:30:00'),(6,4,'2025-04-01 10:30:00'),(6,8,'2025-04-01 12:00:00');
/*!40000 ALTER TABLE `postquestions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provideanswer`
--

DROP TABLE IF EXISTS `provideanswer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provideanswer` (
  `questionID` int NOT NULL,
  `userID` int NOT NULL,
  `answerDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`questionID`,`userID`),
  KEY `userID` (`userID`),
  CONSTRAINT `provideanswer_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `provideanswer_ibfk_2` FOREIGN KEY (`questionID`) REFERENCES `qatable` (`questionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provideanswer`
--

LOCK TABLES `provideanswer` WRITE;
/*!40000 ALTER TABLE `provideanswer` DISABLE KEYS */;
INSERT INTO `provideanswer` VALUES (1,1,'2025-04-01 13:00:00'),(2,7,'2025-04-01 13:05:00'),(3,1,'2025-04-01 13:10:00'),(4,7,'2025-04-01 13:15:00'),(5,1,'2025-04-01 13:20:00'),(6,7,'2025-04-01 13:25:00'),(7,1,'2025-04-01 13:30:00'),(8,7,'2025-04-01 13:35:00'),(9,1,'2025-04-01 13:40:00'),(10,7,'2025-04-01 13:45:00');
/*!40000 ALTER TABLE `provideanswer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qatable`
--

DROP TABLE IF EXISTS `qatable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qatable` (
  `questionID` int NOT NULL AUTO_INCREMENT,
  `question` varchar(150) DEFAULT NULL,
  `response` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`questionID`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qatable`
--

LOCK TABLES `qatable` WRITE;
/*!40000 ALTER TABLE `qatable` DISABLE KEYS */;
INSERT INTO `qatable` VALUES (1,'How early should I arrive at the airport?','We recommend arriving at least 2 hours before your flight.'),(2,'Can I bring a carry-on bag?','Yes, one carry-on and one personal item are allowed.'),(3,'How can I change my flight?','Log into your account and click \"Manage Booking\" to change your flight.'),(4,'Are meals provided on the flight?','Meals are provided on flights over 3 hours.'),(5,'Can I cancel my flight?','Yes, cancellations are allowed up to 24 hours before departure.'),(6,'What if my flight is delayed?','We will notify you by email and SMS with any updates.'),(7,'Do I need a printed ticket?','No, a digital boarding pass is sufficient.'),(8,'Can I book a round-trip ticket?','Absolutely! Just select \"Round Trip\" during your search.'),(9,'What payment methods do you accept?','We accept all major credit cards and PayPal.'),(10,'Can I choose my seat?','Yes, seat selection is available during checkout.'),(11,'Where is the soda machine?',NULL);
/*!40000 ALTER TABLE `qatable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticketlistsflights`
--

DROP TABLE IF EXISTS `ticketlistsflights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticketlistsflights` (
  `ticketNum` int NOT NULL,
  `airID` char(2) NOT NULL,
  `flightNum` int NOT NULL,
  PRIMARY KEY (`ticketNum`,`airID`,`flightNum`),
  KEY `airID` (`airID`,`flightNum`),
  CONSTRAINT `ticketlistsflights_ibfk_1` FOREIGN KEY (`ticketNum`) REFERENCES `tickets` (`ticketNum`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ticketlistsflights_ibfk_2` FOREIGN KEY (`airID`, `flightNum`) REFERENCES `flight` (`airID`, `flightNum`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticketlistsflights`
--

LOCK TABLES `ticketlistsflights` WRITE;
/*!40000 ALTER TABLE `ticketlistsflights` DISABLE KEYS */;
INSERT INTO `ticketlistsflights` VALUES (4,'AA',101),(5,'AA',101),(6,'AA',101),(7,'AA',101),(3,'DL',1016);
/*!40000 ALTER TABLE `ticketlistsflights` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `ticketNum` int NOT NULL AUTO_INCREMENT,
  `ticket_status` enum('waitlist','ongoing','past') DEFAULT NULL,
  `repName` varchar(30) DEFAULT NULL,
  `class` enum('Economy','Business','First') DEFAULT NULL,
  `flight_trip` enum('Oneway','Roundtrip') DEFAULT NULL,
  `booking_price` double DEFAULT NULL,
  `purchase_date` datetime DEFAULT NULL,
  `userID` int DEFAULT NULL,
  PRIMARY KEY (`ticketNum`),
  KEY `userID` (`userID`),
  CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
INSERT INTO `tickets` VALUES (3,'ongoing',NULL,'First','Oneway',2382.96,'2025-04-21 03:10:00',3),(4,'ongoing',NULL,'First','Oneway',1299.99,'2025-04-21 03:13:00',3),(5,'ongoing',NULL,'First','Oneway',1299.99,'2025-04-21 03:21:00',3),(6,'ongoing',NULL,'First','Oneway',1299.99,'2025-04-21 03:22:00',3),(7,'ongoing',NULL,'First','Oneway',1299.99,'2025-04-21 03:24:00',3);
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `fname` varchar(20) DEFAULT NULL,
  `lname` varchar(20) DEFAULT NULL,
  `email` varchar(25) DEFAULT NULL,
  `phone_num` varchar(15) DEFAULT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(25) NOT NULL,
  `dob` date DEFAULT NULL,
  `userType` enum('customer','customerRep','siteAdmin') DEFAULT NULL,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'carly','chick','cchick@gmail.com','384-245-3421','ccarly','Cchicken242','2004-08-27','siteAdmin'),(2,'nadia','rivera','nadiarivera@gmail.com','8493948392','nadiarivera','testingUser','1993-06-15','customer'),(3,'elyssa','rose','elyrosa@gmail.com','2354323452','elyssa_travels','testingtest','2004-06-22','customer'),(4,'umaiza','mian','umaizeef@gmail.com','453-346-3452','umaizuh','tesingngnggn','1997-06-17','customer'),(5,'randy','chick','rchick111@verizon.net','465-256-2356','randychicken','awhbfjhbwa','2024-02-06','customer'),(6,'mark','zan','markzan@gmail.com','325-236-2367','markz','awfawf','2025-04-02','customer'),(7,'hiloni','patel','hpatel@gmail.com','103-405-2938','hpatel','testing','2004-09-13','customerRep');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitinglist`
--

DROP TABLE IF EXISTS `waitinglist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitinglist` (
  `airID` char(2) NOT NULL,
  `flightNum` int NOT NULL,
  `userID` int NOT NULL,
  PRIMARY KEY (`airID`,`flightNum`,`userID`),
  KEY `userID` (`userID`),
  CONSTRAINT `waitinglist_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE,
  CONSTRAINT `waitinglist_ibfk_2` FOREIGN KEY (`airID`, `flightNum`) REFERENCES `flight` (`airID`, `flightNum`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitinglist`
--

LOCK TABLES `waitinglist` WRITE;
/*!40000 ALTER TABLE `waitinglist` DISABLE KEYS */;
/*!40000 ALTER TABLE `waitinglist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-21  3:27:18
