-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 01, 2024 at 09:11 PM
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
(8, NULL, 'Room C', 'pending', NULL, 'gngfh', 'lecture', NULL, 'accepted');

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
(1, 8, 'lecture', 'accepted', '2024-05-01 17:52:40');

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
(4, 'student@example.com', '$2b$10$BxMsuA3XXxG5mAb/l7Df2.vfhN0cG45VtJnAYJVWms6yliugUHSqi', 'student', 'student'),
(5, 'student@eample.com', '$2b$10$5p2uYAdgjeAQrJe2LncwyeUfgZ2qBQ.4uUDfgyAJ02J6m0X6t9WT6', 'student', 'studentt'),
(6, 'student@exmple.com', '$2b$10$ok/.WuRDUscArFWFR7wkDuV6uWMw4rawTf75aemb455SlTQJUqZUG', 'student', 'studenttt'),
(7, 'student@exampe.com', '$2b$10$9/DDWUtApJUVdk4OnUg95uMSuznF4zKqlqFwGKtUFJ1RtLlUpL/A2', 'student', 'studentttt'),
(8, 'student@exaple.com', '$2b$10$7dj/mfj9OPlBXDS2EBHN0.r9yLcmr2b3CD1lBn1P3T3VvaAidfek2', 'student', 'studentyy'),
(9, 'studentpp@gmail.com', '$2b$10$Bncsn9FH7bTEPngRVnCPRe0PvdqasJte6k6ucnbLOwqGEYEeLjHsK', 'student', 'studentpp'),
(10, 'studentoo@gmail.com', '$2b$10$I.t/f/BWTTaUn96Lit6P4.R2jrDggBeFz.JwMw.fftYLdFvnbFV/C', 'student', 'studentoo'),
(11, 'studentj@example.com', '$2b$10$cr9gsR16HnWCi12pvpBGm.7BrTCFRmJP5Oy6ZFIhnOSkonXgU.6be', 'student', 'studentj');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `booking_confirmation`
--
ALTER TABLE `booking_confirmation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `time_slot`
--
ALTER TABLE `time_slot`
  MODIFY `slot_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `users_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
