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
    REFERENCES RegistriesMaster(registration_number)
);
