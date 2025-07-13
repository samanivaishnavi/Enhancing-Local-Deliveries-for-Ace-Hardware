-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Dec 12, 2024 at 02:34 AM
-- Server version: 8.0.35
-- PHP Version: 8.2.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Ace_Hardware`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AssignPendingDeliveries` ()   BEGIN
    DECLARE available_truck INT;

    -- Find the first available truck
    SELECT TruckID INTO available_truck
    FROM DeliveryTruck
    WHERE Status = 'Available'
    LIMIT 1;

    -- Assign the available truck to all pending local deliveries
    UPDATE LocalDelivery
    SET AssignedTruckID = available_truck
    WHERE AssignedTruckID IS NULL;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Carrier`
--

CREATE TABLE `Carrier` (
  `CarrierID` int NOT NULL,
  `Name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Carrier`
--

INSERT INTO `Carrier` (`CarrierID`, `Name`) VALUES
(1, 'FedEx'),
(2, 'UPS'),
(3, 'DHL'),
(4, 'Amazon Logistics'),
(5, 'USPS'),
(6, 'OnTrac'),
(7, 'LaserShip'),
(8, 'Blue Dart'),
(9, 'Aramex'),
(10, 'Delhivery');

-- --------------------------------------------------------

--
-- Table structure for table `Customer`
--

CREATE TABLE `Customer` (
  `CustomerID` int NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Address` varchar(255) NOT NULL,
  `PostalCode` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Customer`
--

INSERT INTO `Customer` (`CustomerID`, `Name`, `Address`, `PostalCode`) VALUES
(1, 'John Doe', '123 Elm Street', '10001'),
(2, 'Jane Smith', '456 Oak Avenue', '10002'),
(3, 'Alice Johnson', '789 Maple Drive', '10003'),
(4, 'Bob Brown', '321 Pine Road', '10004'),
(5, 'Mary Davis', '654 Cedar Lane', '10005'),
(6, 'Tom Wilson', '987 Birch Blvd', '10006'),
(7, 'Nancy Taylor', '369 Fir Avenue', '10007'),
(8, 'Steve Harris', '741 Ash Circle', '10008'),
(9, 'Linda White', '852 Spruce Way', '10009'),
(10, 'Karen Lee', '963 Maple Street', '10010');

-- --------------------------------------------------------

--
-- Table structure for table `DeliveryOrder`
--

CREATE TABLE `DeliveryOrder` (
  `DeliveryID` int NOT NULL,
  `OrderID` int NOT NULL,
  `DeliveryType` enum('LocalDelivery','ThirdPartyDelivery') NOT NULL,
  `WarehouseID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `DeliveryOrder`
--

INSERT INTO `DeliveryOrder` (`DeliveryID`, `OrderID`, `DeliveryType`, `WarehouseID`) VALUES
(2001, 1001, 'LocalDelivery', 1),
(2002, 1002, 'ThirdPartyDelivery', 2),
(2003, 1003, 'LocalDelivery', 3),
(2004, 1004, 'ThirdPartyDelivery', 4),
(2005, 1005, 'LocalDelivery', 5),
(2006, 1006, 'ThirdPartyDelivery', 6),
(2007, 1007, 'LocalDelivery', 7),
(2008, 1008, 'ThirdPartyDelivery', 8),
(2009, 1009, 'LocalDelivery', 9),
(2010, 1010, 'ThirdPartyDelivery', 10);

-- --------------------------------------------------------

--
-- Table structure for table `DeliveryTruck`
--

CREATE TABLE `DeliveryTruck` (
  `TruckID` int NOT NULL,
  `Capacity` int NOT NULL,
  `Status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `DeliveryTruck`
--

INSERT INTO `DeliveryTruck` (`TruckID`, `Capacity`, `Status`) VALUES
(1, 500, 'Available'),
(2, 400, 'In Use'),
(3, 450, 'Maintenance'),
(4, 550, 'Available'),
(5, 600, 'In Use'),
(6, 700, 'Available'),
(7, 800, 'In Use'),
(8, 900, 'Maintenance'),
(9, 650, 'Available'),
(10, 750, 'In Use');

-- --------------------------------------------------------

--
-- Table structure for table `LocalDelivery`
--

CREATE TABLE `LocalDelivery` (
  `DeliveryID` int NOT NULL,
  `AssignedTruckID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `LocalDelivery`
--

INSERT INTO `LocalDelivery` (`DeliveryID`, `AssignedTruckID`) VALUES
(2001, 1),
(2003, 2),
(2005, 3),
(2007, 4),
(2009, 5);

--
-- Triggers `LocalDelivery`
--
DELIMITER $$
CREATE TRIGGER `ValidateTruckCapacity` BEFORE INSERT ON `LocalDelivery` FOR EACH ROW BEGIN
    DECLARE current_delivery_count INT;
    DECLARE max_capacity INT;
    -- Calculate the current number of deliveries assigned to the truck
    SELECT COUNT(*) INTO current_delivery_count
    FROM LocalDelivery
    WHERE AssignedTruckID = NEW.AssignedTruckID;
    -- Get the truck's capacity
    SELECT Capacity INTO max_capacity
    FROM DeliveryTruck
    WHERE TruckID = NEW.AssignedTruckID;

    -- Validate that the truck capacity is not exceeded
    IF (current_delivery_count + 1 > max_capacity) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Truck capacity exceeded';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `OrderHeader`
--

CREATE TABLE `OrderHeader` (
  `OrderID` int NOT NULL,
  `CustomerID` int NOT NULL,
  `OrderDate` date NOT NULL,
  `WarehouseID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `OrderHeader`
--

INSERT INTO `OrderHeader` (`OrderID`, `CustomerID`, `OrderDate`, `WarehouseID`) VALUES
(1001, 1, '2024-12-01', 1),
(1002, 2, '2024-12-02', 2),
(1003, 3, '2024-12-03', 3),
(1004, 4, '2024-12-04', 4),
(1005, 5, '2024-12-05', 5),
(1006, 6, '2024-12-06', 6),
(1007, 7, '2024-12-07', 7),
(1008, 8, '2024-12-08', 8),
(1009, 9, '2024-12-09', 9),
(1010, 10, '2024-12-10', 10);

-- --------------------------------------------------------

--
-- Table structure for table `OrderLine`
--

CREATE TABLE `OrderLine` (
  `OrderLineID` int NOT NULL,
  `OrderID` int NOT NULL,
  `ProductID` int NOT NULL,
  `Quantity` int NOT NULL,
  `Price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `OrderLine`
--

INSERT INTO `OrderLine` (`OrderLineID`, `OrderID`, `ProductID`, `Quantity`, `Price`) VALUES
(1, 1001, 101, 2, 39.98),
(2, 1002, 102, 1, 49.99),
(3, 1003, 103, 3, 89.97),
(4, 1004, 104, 1, 9.99),
(5, 1005, 105, 5, 74.95),
(6, 1006, 106, 2, 23.98),
(7, 1007, 107, 4, 31.96),
(8, 1008, 108, 1, 89.99),
(9, 1009, 109, 2, 119.98),
(10, 1010, 110, 3, 38.97);

-- --------------------------------------------------------

--
-- Table structure for table `Product`
--

CREATE TABLE `Product` (
  `ProductID` int NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Product`
--

INSERT INTO `Product` (`ProductID`, `Name`, `Price`) VALUES
(101, 'Hammer', 19.99),
(102, 'Drill', 49.99),
(103, 'Saw', 29.99),
(104, 'Screwdriver', 9.99),
(105, 'Wrench', 14.99),
(106, 'Pliers', 11.99),
(107, 'Tape Measure', 7.99),
(108, 'Ladder', 89.99),
(109, 'Toolbox', 59.99),
(110, 'Flashlight', 12.99);

-- --------------------------------------------------------

--
-- Table structure for table `RealTimeTracking`
--

CREATE TABLE `RealTimeTracking` (
  `TrackID` int NOT NULL,
  `TruckID` int NOT NULL,
  `GPSData` varchar(255) NOT NULL,
  `Timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `RealTimeTracking`
--

INSERT INTO `RealTimeTracking` (`TrackID`, `TruckID`, `GPSData`, `Timestamp`) VALUES
(1, 1, '40.7128,-74.0060', '2024-12-04 10:00:00'),
(2, 2, '42.3601,-71.0589', '2024-12-04 11:00:00'),
(3, 3, '39.9526,-75.1652', '2024-12-04 12:00:00'),
(4, 4, '41.8781,-87.6298', '2024-12-04 13:00:00'),
(5, 5, '34.0522,-118.2437', '2024-12-04 14:00:00'),
(6, 6, '37.7749,-122.4194', '2024-12-05 09:00:00'),
(7, 7, '47.6062,-122.3321', '2024-12-05 10:30:00'),
(8, 8, '29.7604,-95.3698', '2024-12-05 12:00:00'),
(9, 9, '25.7617,-80.1918', '2024-12-05 13:15:00'),
(10, 10, '39.7392,-104.9903', '2024-12-05 15:00:00');

--
-- Triggers `RealTimeTracking`
--
DELIMITER $$
CREATE TRIGGER `ArchiveOldGPSData` AFTER INSERT ON `RealTimeTracking` FOR EACH ROW BEGIN
    INSERT INTO RealTimeTracking_Archive (TrackID, TruckID, GPSData, Timestamp)
    SELECT TrackID, TruckID, GPSData, Timestamp
    FROM RealTimeTracking
    WHERE Timestamp < DATE_SUB(NOW(), INTERVAL 30 DAY);
    DELETE FROM RealTimeTracking
    WHERE Timestamp < DATE_SUB(NOW(), INTERVAL 30 DAY);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Route`
--

CREATE TABLE `Route` (
  `RouteID` int NOT NULL,
  `WarehouseID` int NOT NULL,
  `CustomerID` int NOT NULL,
  `DistanceToCustomer` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Route`
--

INSERT INTO `Route` (`RouteID`, `WarehouseID`, `CustomerID`, `DistanceToCustomer`) VALUES
(1, 1, 1, 10.50),
(2, 2, 2, 20.30),
(3, 3, 3, 15.00),
(4, 4, 4, 25.50),
(5, 5, 5, 30.00),
(6, 6, 6, 18.20),
(7, 7, 7, 22.80),
(8, 8, 8, 19.40),
(9, 9, 9, 24.70),
(10, 10, 10, 21.60);

-- --------------------------------------------------------

--
-- Table structure for table `Stock`
--

CREATE TABLE `Stock` (
  `StockID` int NOT NULL,
  `WarehouseID` int NOT NULL,
  `ProductID` int NOT NULL,
  `Quantity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Stock`
--

INSERT INTO `Stock` (`StockID`, `WarehouseID`, `ProductID`, `Quantity`) VALUES
(1, 1, 101, 100),
(2, 1, 102, 50),
(3, 2, 103, 200),
(4, 3, 104, 150),
(5, 4, 105, 120),
(6, 5, 106, 180),
(7, 6, 107, 80),
(8, 7, 108, 70),
(9, 8, 109, 90),
(10, 9, 110, 60);

-- --------------------------------------------------------

--
-- Table structure for table `ThirdPartyDelivery`
--

CREATE TABLE `ThirdPartyDelivery` (
  `DeliveryID` int NOT NULL,
  `CarrierID` int NOT NULL,
  `TrackingLink` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Warehouse`
--

CREATE TABLE `Warehouse` (
  `WarehouseID` int NOT NULL,
  `Location` varchar(255) NOT NULL,
  `DeliveryRadius` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Warehouse`
--

INSERT INTO `Warehouse` (`WarehouseID`, `Location`, `DeliveryRadius`) VALUES
(1, 'New York Warehouse', 50.00),
(2, 'Boston Warehouse', 75.00),
(3, 'Philadelphia Warehouse', 60.00),
(4, 'Chicago Warehouse', 80.00),
(5, 'Los Angeles Warehouse', 90.00),
(6, 'San Francisco Warehouse', 85.00),
(7, 'Seattle Warehouse', 70.00),
(8, 'Houston Warehouse', 95.00),
(9, 'Miami Warehouse', 100.00),
(10, 'Denver Warehouse', 65.00);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Carrier`
--
ALTER TABLE `Carrier`
  ADD PRIMARY KEY (`CarrierID`);

--
-- Indexes for table `Customer`
--
ALTER TABLE `Customer`
  ADD PRIMARY KEY (`CustomerID`);

--
-- Indexes for table `DeliveryOrder`
--
ALTER TABLE `DeliveryOrder`
  ADD PRIMARY KEY (`DeliveryID`),
  ADD KEY `OrderID` (`OrderID`),
  ADD KEY `WarehouseID` (`WarehouseID`);

--
-- Indexes for table `DeliveryTruck`
--
ALTER TABLE `DeliveryTruck`
  ADD PRIMARY KEY (`TruckID`);

--
-- Indexes for table `LocalDelivery`
--
ALTER TABLE `LocalDelivery`
  ADD PRIMARY KEY (`DeliveryID`),
  ADD KEY `AssignedTruckID` (`AssignedTruckID`);

--
-- Indexes for table `OrderHeader`
--
ALTER TABLE `OrderHeader`
  ADD PRIMARY KEY (`OrderID`),
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `WarehouseID` (`WarehouseID`);

--
-- Indexes for table `OrderLine`
--
ALTER TABLE `OrderLine`
  ADD PRIMARY KEY (`OrderLineID`),
  ADD KEY `OrderID` (`OrderID`),
  ADD KEY `ProductID` (`ProductID`);

--
-- Indexes for table `Product`
--
ALTER TABLE `Product`
  ADD PRIMARY KEY (`ProductID`);

--
-- Indexes for table `RealTimeTracking`
--
ALTER TABLE `RealTimeTracking`
  ADD PRIMARY KEY (`TrackID`),
  ADD KEY `TruckID` (`TruckID`);

--
-- Indexes for table `Route`
--
ALTER TABLE `Route`
  ADD PRIMARY KEY (`RouteID`),
  ADD KEY `WarehouseID` (`WarehouseID`),
  ADD KEY `CustomerID` (`CustomerID`);

--
-- Indexes for table `Stock`
--
ALTER TABLE `Stock`
  ADD PRIMARY KEY (`StockID`),
  ADD KEY `WarehouseID` (`WarehouseID`),
  ADD KEY `ProductID` (`ProductID`);

--
-- Indexes for table `ThirdPartyDelivery`
--
ALTER TABLE `ThirdPartyDelivery`
  ADD PRIMARY KEY (`DeliveryID`),
  ADD KEY `CarrierID` (`CarrierID`);

--
-- Indexes for table `Warehouse`
--
ALTER TABLE `Warehouse`
  ADD PRIMARY KEY (`WarehouseID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `DeliveryOrder`
--
ALTER TABLE `DeliveryOrder`
  ADD CONSTRAINT `deliveryorder_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `OrderHeader` (`OrderID`),
  ADD CONSTRAINT `deliveryorder_ibfk_2` FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`);

--
-- Constraints for table `LocalDelivery`
--
ALTER TABLE `LocalDelivery`
  ADD CONSTRAINT `localdelivery_ibfk_1` FOREIGN KEY (`DeliveryID`) REFERENCES `DeliveryOrder` (`DeliveryID`),
  ADD CONSTRAINT `localdelivery_ibfk_2` FOREIGN KEY (`AssignedTruckID`) REFERENCES `DeliveryTruck` (`TruckID`);

--
-- Constraints for table `OrderHeader`
--
ALTER TABLE `OrderHeader`
  ADD CONSTRAINT `orderheader_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`),
  ADD CONSTRAINT `orderheader_ibfk_2` FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`);

--
-- Constraints for table `OrderLine`
--
ALTER TABLE `OrderLine`
  ADD CONSTRAINT `orderline_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `OrderHeader` (`OrderID`),
  ADD CONSTRAINT `orderline_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ProductID`);

--
-- Constraints for table `RealTimeTracking`
--
ALTER TABLE `RealTimeTracking`
  ADD CONSTRAINT `realtimetracking_ibfk_1` FOREIGN KEY (`TruckID`) REFERENCES `DeliveryTruck` (`TruckID`);

--
-- Constraints for table `Route`
--
ALTER TABLE `Route`
  ADD CONSTRAINT `route_ibfk_1` FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`),
  ADD CONSTRAINT `route_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`);

--
-- Constraints for table `Stock`
--
ALTER TABLE `Stock`
  ADD CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`),
  ADD CONSTRAINT `stock_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ProductID`);

--
-- Constraints for table `ThirdPartyDelivery`
--
ALTER TABLE `ThirdPartyDelivery`
  ADD CONSTRAINT `thirdpartydelivery_ibfk_1` FOREIGN KEY (`DeliveryID`) REFERENCES `DeliveryOrder` (`DeliveryID`),
  ADD CONSTRAINT `thirdpartydelivery_ibfk_2` FOREIGN KEY (`CarrierID`) REFERENCES `Carrier` (`CarrierID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
