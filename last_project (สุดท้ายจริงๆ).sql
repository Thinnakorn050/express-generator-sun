-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 02, 2024 at 08:00 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `last_project`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `staff_id` int(20) DEFAULT NULL,
  `roomname` varchar(100) DEFAULT NULL,
  `room_status` varchar(50) DEFAULT NULL,
  `slot_id` int(11) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `approver` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `staff_id`, `roomname`, `room_status`, `slot_id`, `reason`, `approver`, `user_id`, `status`) VALUES
(8, NULL, 'Room C', 'pending', NULL, 'gngfh', 'lecture', NULL, 'accepted'),
(9, NULL, 'Room A', 'pending', NULL, 'rrr', NULL, NULL, NULL),
(10, NULL, 'Room A', 'pending', NULL, 'sef', NULL, NULL, NULL),
(11, NULL, 'Room A', 'pending', NULL, 'yyy', NULL, NULL, NULL),
(12, NULL, 'Room B', 'pending', NULL, 'www', NULL, NULL, NULL),
(13, NULL, 'Room C', 'pending', NULL, 'dsv', NULL, NULL, NULL),
(14, NULL, 'Room A', 'pending', NULL, 'reg', NULL, NULL, NULL),
(15, NULL, 'Room C', 'pending', NULL, 'fff', 'lecture', NULL, 'accepted'),
(16, NULL, 'Room D', 'available', NULL, 'sun', 'lecture', NULL, 'rejected'),
(17, NULL, 'Room B', 'available', NULL, 'bimon', 'lecture', NULL, 'rejected');

-- --------------------------------------------------------

--
-- Table structure for table `booking_confirmation`
--

CREATE TABLE `booking_confirmation` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `approver` varchar(255) DEFAULT NULL,
  `status` enum('accepted','rejected') DEFAULT NULL,
  `confirmed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking_confirmation`
--

INSERT INTO `booking_confirmation` (`id`, `booking_id`, `approver`, `status`, `confirmed_at`) VALUES
(1, 8, 'lecture', 'accepted', '2024-05-01 17:52:40'),
(2, 15, 'lecture', 'accepted', '2024-05-02 04:19:17'),
(3, 16, 'lecture', 'accepted', '2024-05-02 04:25:08'),
(4, 17, 'lecture', 'accepted', '2024-05-02 04:30:15');

-- --------------------------------------------------------

--
-- Table structure for table `time_slot`
--

CREATE TABLE `time_slot` (
  `slot_id` int(11) NOT NULL,
  `room_id` varchar(10) DEFAULT NULL,
  `time_start` time DEFAULT NULL,
  `time_end` time DEFAULT NULL,
  `status` enum('available','pending','reserved','disable') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `time_slot`
--

INSERT INTO `time_slot` (`slot_id`, `room_id`, `time_start`, `time_end`, `status`) VALUES
(1, 'A101', '08:00:00', '10:00:00', 'available'),
(2, 'A101', '10:00:00', '12:00:00', 'disable'),
(3, 'A101', '13:00:00', '15:00:00', 'pending'),
(4, 'A101', '15:00:00', '17:00:00', 'disable'),
(5, 'B201', '08:00:00', '10:00:00', 'available'),
(6, 'B201', '10:00:00', '12:00:00', 'disable'),
(7, 'B201', '12:00:00', '14:00:00', 'available');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `users_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('student','staff','lecture') NOT NULL,
  `username` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`users_id`, `email`, `password`, `role`, `username`) VALUES
(20, 'student@gmail.com', '$2b$10$yLJOwxKHWBiNltlJolgUz.7qHVKWUYqRRAxzrapOZRN3OVIhM9B/W', 'student', 'student'),
(21, 'staff@gmail.com', '$2b$10$BDlC16/pdwUHgB0x4/46V.B5cpWbTVluiMtavgtaATA3s/bOh.36q', 'staff', 'staff'),
(22, 'studentq@gmail.com', '$2b$10$xtzh5yN64sl1m1iua85SxuIteI7dpiRFAABGcBS.I7VOpUoJGlu5G', 'student', 'studentq'),
(23, 'student5@gmaio.com', '$2b$10$lq2/6jD3UysHeIL9kiFeJuBbxK2PQCOJXNApkyh0wi5XvBldqF79G', 'student', 'student5'),
(24, 'studentp@gmail.com', '$2b$10$YKEGYVLbQSCtzh/sX5eg5.GGl44scZ1iEytEWsLfgWLftW/UdI5zO', 'student', 'studentp');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_id` (`user_id`),
  ADD KEY `fk_slot_id` (`slot_id`);

--
-- Indexes for table `booking_confirmation`
--
ALTER TABLE `booking_confirmation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_booking_id` (`booking_id`);

--
-- Indexes for table `time_slot`
--
ALTER TABLE `time_slot`
  ADD PRIMARY KEY (`slot_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`users_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `booking_confirmation`
--
ALTER TABLE `booking_confirmation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `time_slot`
--
ALTER TABLE `time_slot`
  MODIFY `slot_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `users_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `fk_slot_id` FOREIGN KEY (`slot_id`) REFERENCES `time_slot` (`slot_id`),
  ADD CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`users_id`);

--
-- Constraints for table `booking_confirmation`
--
ALTER TABLE `booking_confirmation`
  ADD CONSTRAINT `fk_booking_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
