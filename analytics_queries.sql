-- =============================================================
-- PORTFOLIO ASSET: HEALTHCARE PROVIDER ONBOARDING DATA MODEL
-- ADVANCED OPERATIONAL KPIS (CTEs & WINDOW FUNCTIONS)
-- SYSTEM REFERENCE: SLIDE 13 & SLIDE 19 REPORTING DEPLOYMENTS
-- =============================================================

-- =============================================================
-- QUERY 1: CALCULATING ONBOARDING SLA COMPLIANCE (Slide 13 Metric)
-- Tracks turnaround speeds with built-in system crash protections.
-- =============================================================
WITH SLAProcessingIntervals AS (
    SELECT
        application_id,
        application_status,
        submission_timestamp,
        approval_timestamp,
        EXTRACT(EPOCH FROM (approval_timestamp - submission_timestamp)) / 3600.0 AS turnaround_hours
    FROM OnboardingTransactions
    WHERE application_status = 'Approved' AND approval_timestamp IS NOT NULL
)
SELECT
    COUNT(application_id) AS total_approved_applications,
    COALESCE(ROUND(AVG(turnaround_hours), 2), 0.00) AS average_turnaround_hours,
    -- NULLIF prevents critical Division-by-Zero runtime crashes if table has empty records
    COALESCE(
        ROUND((COUNT(CASE WHEN turnaround_hours <= 24.0 THEN 1 END) * 100.0) / NULLIF(COUNT(application_id), 0), 2), 
        0.00
    ) AS sla_compliance_percentage
FROM SLAProcessingIntervals;


-- =============================================================
-- QUERY 2: IDENTIFYING PIPELINE VERIFICATION BOTTLENECKS (Slide 19 Metric)
-- Ranks operational failure points dynamically using Window Partitioning.
-- =============================================================
SELECT
    rejection_reason,
    COUNT(application_id) AS total_rejected_cases,
    DENSE_RANK() OVER (ORDER BY COUNT(application_id) DESC) AS bottleneck_priority_rank
FROM OnboardingTransactions
WHERE application_status = 'Rejected'
GROUP BY rejection_reason;


-- =============================================================
-- QUERY 3: Provider Onboarding Activity by Specialty
-- Uses advanced Window Logic to track sequence spacing across specialties.
-- =============================================================
SELECT 
    t.application_id,
    p.specialty,
    t.submission_timestamp,
    -- LAG calculates time delta from the prior application within the exact same medical field
    LAG(t.submission_timestamp, 1) OVER (
        PARTITION BY p.specialty 
        ORDER BY t.submission_timestamp ASC
    ) AS previous_specialty_submission,
    t.application_status
FROM OnboardingTransactions t
JOIN ProvidersMaster p ON t.provider_id = p.provider_id;
