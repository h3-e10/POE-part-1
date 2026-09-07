-- ============================================================================
-- RaceDay Database Creation & Seeding Script (SQL Server / SSMS)
-- ============================================================================

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

-- Drop tables if they already exist to ensure a clean setup
IF OBJECT_ID('Results', 'U') IS NOT NULL DROP TABLE Results;
IF OBJECT_ID('EventEnrolments', 'U') IS NOT NULL DROP TABLE EventEnrolments;
IF OBJECT_ID('EventCategories', 'U') IS NOT NULL DROP TABLE EventCategories;
IF OBJECT_ID('Events', 'U') IS NOT NULL DROP TABLE Events;
IF OBJECT_ID('UserProfiles', 'U') IS NOT NULL DROP TABLE UserProfiles;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- 1. Users Table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 2. UserProfiles Table
CREATE TABLE UserProfiles (
    ProfileID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    Gender NVARCHAR(10) NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    EmergencyContact NVARCHAR(100) NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- 3. Events Table
CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    Title NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(150) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (OrganiserID) REFERENCES Users(UserID)
);

-- 4. EventCategories Table
CREATE TABLE EventCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL,
    DistanceKM DECIMAL(5,2) NOT NULL CHECK (DistanceKM > 0),
    EntryFee DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (EntryFee >= 0),
    FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE
);

-- 5. EventEnrolments Table
CREATE TABLE EventEnrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    PaymentStatus NVARCHAR(20) DEFAULT 'Paid' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Cancelled')),
    CONSTRAINT UQ_Participant_Category UNIQUE (ParticipantID, CategoryID),
    FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES EventCategories(CategoryID)
);

-- 6. Results Table
CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NOT NULL,
    OverallRank INT NOT NULL CHECK (OverallRank > 0),
    CategoryRank INT NOT NULL CHECK (CategoryRank > 0),
    FOREIGN KEY (EnrolmentID) REFERENCES EventEnrolments(EnrolmentID) ON DELETE CASCADE
);
GO

-- ============================================================================
-- DATA SEEDING (Minimum: 2 Organisers, 2 Participants, 3 Events, Categories, Enrolments)
-- ============================================================================

-- Seed Users (2 Organisers, 2 Participants)
INSERT INTO Users (FullName, Email, PasswordHash, Role)
VALUES
('Sipho Ndlovu', 'sipho.organiser@raceday.co.za', 'HashedPass123!', 'Organiser'),
('Anika Meyer', 'anika.events@raceday.co.za', 'HashedPass123!', 'Organiser'),
('Kagiso Mokoena', 'kagiso.runner@gmail.com', 'HashedPass123!', 'Participant'),
('Liesl van Zyl', 'liesl.v@gmail.com', 'HashedPass123!', 'Participant');

-- Seed User Profiles
INSERT INTO UserProfiles (UserID, PhoneNumber, DateOfBirth, Gender, EmergencyContact)
VALUES
(1, '0821112222', '1985-04-12', 'Male', 'Nomsa Ndlovu - 0823334444'),
(2, '0832223333', '1990-09-25', 'Female', 'Peter Meyer - 0834445555'),
(3, '0713334444', '1998-01-15', 'Male', 'Teboho Mokoena - 0715556666'),
(4, '0724445555', '2001-06-30', 'Female', 'Johan van Zyl - 0726667777');

-- Seed 3 Events
INSERT INTO Events (OrganiserID, Title, Description, EventDate, Location)
VALUES
(1, 'Soweto City Marathon 2026', 'Premier road running event in Soweto Township.', '2026-11-01 06:00:00', 'Soweto, Johannesburg'),
(1, 'Gauteng Cycling Challenge', 'Fast-paced highway road cycling race.', '2026-12-05 07:00:00', 'Midrand, Gauteng'),
(2, 'Cape Peninsula Walk & Run', 'Scenic coastal charity walk and road race.', '2026-10-15 06:30:00', 'Cape Town, Western Cape');

-- Seed Event Categories
INSERT INTO EventCategories (EventID, CategoryName, DistanceKM, EntryFee)
VALUES
(1, '10km Road Race', 10.00, 150.00),
(1, '21km Half Marathon', 21.10, 250.00),
(1, '42km Full Marathon', 42.20, 380.00),
(2, '90km Classic Cycle', 90.00, 450.00),
(3, '5km Fun Walk', 5.00, 80.00);

-- Seed Event Enrolments
INSERT INTO EventEnrolments (ParticipantID, CategoryID, PaymentStatus)
VALUES
(3, 2, 'Paid'), -- Kagiso enrolled in Soweto 21km
(4, 1, 'Paid'), -- Liesl enrolled in Soweto 10km
(3, 5, 'Paid'); -- Kagiso enrolled in Cape 5km Walk

-- Seed Results
INSERT INTO Results (EnrolmentID, FinishTime, OverallRank, CategoryRank)
VALUES
(1, '01:32:15', 15, 4),
(2, '00:48:10', 8, 2);
GO 