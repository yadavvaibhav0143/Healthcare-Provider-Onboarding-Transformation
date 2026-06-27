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
('KA11223', 'Dr. Sneha Iyer', 'Pediatrics', 'Suspended');

-- 2. Seed Internal Healthcare Provider Profile Management Records
INSERT INTO ProvidersMaster (provider_id, registration_number, provider_name, specialty, network_status, activation_status) 
VALUES
(101, 'MH12345', 'Dr. Priya Sharma', 'Cardiology', 'In-Network', 'Active'),
(102, 'MH67890', 'Dr. Raj Mehta', 'Orthopedics', 'Out-of-Network', 'Inactive');

-- 3. Seed Onboarding Operational Performance Transactions
INSERT INTO OnboardingTransactions (application_id, provider_id, registration_number, submission_timestamp, verification_timestamp, approval_timestamp, application_status, rejection_reason) 
VALUES
(1001, 101, 'MH12345', '2026-06-01 09:00:00', '2026-06-01 11:00:00', '2026-06-02 08:00:00', 'Approved', NULL),
(1002, 102, 'MH67890', '2026-06-03 10:00:00', '2026-06-03 14:00:00', '2026-06-05 09:00:00', 'Approved', NULL),
(1003, 102, 'MH67890', '2026-06-10 12:00:00', '2026-06-10 13:00:00', NULL, 'Rejected', 'Document Mismatch'),
(1004, 101, 'MH12345', '2026-06-15 14:00:00', NULL, NULL, 'Pending', NULL);
