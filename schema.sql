-- =============================================================
-- PORTFOLIO ASSET: HEALTHCARE PROVIDER ONBOARDING DATA MODEL
-- RELATIONAL DATABASE SCHEMA DESIGN (DDL)
-- =============================================================

DROP TABLE IF EXISTS OnboardingTransactions;
DROP TABLE IF EXISTS ProvidersMaster;
DROP TABLE IF EXISTS RegistriesMaster;

-- =============================================================
-- 1. NATIONAL MEDICAL COUNCIL REGISTRY DATA
-- (Simulates External Provider Verification API Source)
-- =============================================================

CREATE TABLE RegistriesMaster (
    registration_number VARCHAR(30) PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    medical_specialty VARCHAR(50) NOT NULL,
    license_status VARCHAR(20) NOT NULL
        CHECK (license_status IN ('Active','Suspended','Expired'))
);

-- =============================================================
-- 2. INTERNAL PROVIDER MASTER
-- =============================================================

CREATE TABLE ProvidersMaster (
    provider_id INT PRIMARY KEY,
    registration_number VARCHAR(30) NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50) NOT NULL,
    network_status VARCHAR(20) NOT NULL
        CHECK (network_status IN ('In-Network','Out-of-Network')),
    activation_status VARCHAR(20) NOT NULL
        CHECK (activation_status IN ('Active','Inactive')),

    CONSTRAINT fk_provider_registry
    FOREIGN KEY (registration_number)
    REFERENCES RegistriesMaster(registration_number)
);

-- =============================================================
-- 3. PROVIDER ONBOARDING TRANSACTION TRACKER
-- =============================================================

CREATE TABLE OnboardingTransactions (
    application_id INT PRIMARY KEY,
    provider_id INT NOT NULL,
    registration_number VARCHAR(30) NOT NULL,

    submission_timestamp TIMESTAMP NOT NULL,
    verification_timestamp TIMESTAMP NULL,
    approval_timestamp TIMESTAMP NULL,

    application_status VARCHAR(20) NOT NULL
        CHECK (application_status IN ('Approved','Rejected','Pending')),

    rejection_reason VARCHAR(100) NULL,

    CONSTRAINT fk_provider_id
    FOREIGN KEY (provider_id)
    REFERENCES ProvidersMaster(provider_id)
    ON DELETE CASCADE,

    CONSTRAINT fk_registration_number
    FOREIGN KEY (registration_number)
    REFERENCES RegistriesMaster(registration_number),

    CONSTRAINT chk_onboarding_dates 
        CHECK (COALESCE(approval_timestamp, verification_timestamp, submission_timestamp) >= submission_timestamp)   

);

-- =============================================================
-- PORTFOLIO ASSET: DATA INITIALIZATION SEED SCRIPTS
-- OBJECTIVE: CORE SEED DATA FOR INTERVIEW DEMONSTRATIONS
-- =============================================================

-- 1. Seed National Registry Master Source Data
INSERT INTO RegistriesMaster (registration_number, doctor_name, medical_specialty, license_status) 
VALUES
('MH12345', 'Dr. Priya Sharma', 'Cardiology', 'Active'),
('MH67890', 'Dr. Raj Mehta', 'Orthopedics', 'Active'),
('KA11223', 'Dr. Sneha Iyer', 'Pediatrics', 'Suspended'),
('DL33445', 'Dr. Arjun Kapoor', 'Dermatology', 'Active'),
('TN55667', 'Dr. Meera Nair', 'Neurology', 'Active'),
('GJ77889', 'Dr. Rohan Shah', 'General Medicine', 'Active'),
('WB99001', 'Dr. Ananya Sen', 'Gynecology', 'Active');

-- 2. Seed Internal Healthcare Provider Profile Management Records
INSERT INTO ProvidersMaster (provider_id, registration_number, provider_name, specialty, network_status, activation_status) 
VALUES
(101, 'MH12345', 'Dr. Priya Sharma', 'Cardiology', 'In-Network', 'Active'),
(102, 'MH67890', 'Dr. Raj Mehta', 'Orthopedics', 'Out-of-Network', 'Inactive'),
(103, 'KA11223', 'Dr. Sneha Iyer', 'Pediatrics', 'In-Network', 'Inactive'),
(104, 'DL33445', 'Dr. Arjun Kapoor', 'Dermatology', 'In-Network', 'Active'),
(105, 'TN55667', 'Dr. Meera Nair', 'Neurology', 'Out-of-Network', 'Active'),
(106, 'GJ77889', 'Dr. Rohan Shah', 'General Medicine', 'In-Network', 'Active'),
(107, 'WB99001', 'Dr. Ananya Sen', 'Gynecology', 'Out-of-Network', 'Active');

-- 3. Seed Onboarding Operational Performance Transactions
INSERT INTO OnboardingTransactions (application_id, provider_id, registration_number, submission_timestamp, verification_timestamp, approval_timestamp, application_status, rejection_reason) 
VALUES
(1001, 101, 'MH12345', '2026-06-01 09:00:00', '2026-06-01 11:00:00', '2026-06-02 08:00:00', 'Approved', NULL),
(1002, 102, 'MH67890', '2026-06-03 10:00:00', '2026-06-03 14:00:00', '2026-06-05 09:00:00', 'Approved', NULL),
(1003, 102, 'MH67890', '2026-06-10 12:00:00', '2026-06-10 13:00:00', NULL, 'Rejected', 'Document Mismatch'),
(1004, 101, 'MH12345', '2026-06-15 14:00:00', NULL, NULL, 'Pending', NULL),
(1005, 104, 'DL33445', '2026-06-18 09:00:00', '2026-06-18 12:00:00', '2026-06-18 20:00:00', 'Approved', NULL),
(1006, 105, 'TN55667', '2026-06-20 10:00:00', '2026-06-20 15:00:00', '2026-06-21 08:00:00', 'Approved', NULL),
(1007, 106, 'GJ77889', '2026-06-22 11:00:00', '2026-06-22 13:00:00', '2026-06-23 16:00:00', 'Approved', NULL),
(1008, 102, 'MH67890', '2026-06-24 09:30:00', '2026-06-24 11:00:00', NULL, 'Rejected', 'Incomplete Documents'),
(1009, 107, 'WB99001', '2026-06-25 14:00:00', '2026-06-26 10:00:00', NULL, 'Pending', NULL),
(1010, 104, 'DL33445', '2026-06-27 10:00:00', '2026-06-27 13:00:00', '2026-06-28 09:00:00', 'Approved', NULL),
(1011, 103, 'KA11223', '2026-06-29 08:30:00', '2026-06-29 11:30:00', NULL, 'Rejected', 'License Verification Failed'),
(1012, 105, 'TN55667', '2026-07-01 12:00:00', '2026-07-01 16:00:00', '2026-07-03 17:00:00', 'Approved', NULL),
(1013, 106, 'GJ77889', '2026-07-03 09:00:00', '2026-07-03 10:30:00', '2026-07-03 18:00:00', 'Approved', NULL),
(1014, 107, 'WB99001', '2026-07-05 11:00:00', '2026-07-05 14:00:00', NULL, 'Pending', NULL),
(1015, 101, 'MH12345', '2026-07-07 10:00:00', '2026-07-07 12:00:00', '2026-07-08 15:00:00', 'Approved', NULL),
(1016, 103, 'KA11223', '2026-07-09 09:00:00', '2026-07-09 11:00:00', NULL, 'Rejected', 'Document Mismatch'),
(1017, 104, 'DL33445', '2026-07-11 13:00:00', '2026-07-11 15:00:00', '2026-07-12 10:00:00', 'Approved', NULL),
(1018, 105, 'TN55667', '2026-07-13 10:00:00', '2026-07-13 14:00:00', '2026-07-14 08:00:00', 'Approved', NULL),
(1019, 107, 'WB99001', '2026-07-15 15:00:00', '2026-07-16 09:00:00', NULL, 'Pending', NULL),
(1020, 106, 'GJ77889', '2026-07-17 09:30:00', '2026-07-17 12:30:00', '2026-07-19 18:00:00', 'Approved', NULL);









