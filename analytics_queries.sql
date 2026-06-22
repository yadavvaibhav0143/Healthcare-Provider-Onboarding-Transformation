-- PORTFOLIO ASSET: HEALTHCARE PROVIDER ONBOARDING DATA MODEL  
-- ADVANCED OPERATIONAL KPIS (CTEs & WINDOW FUNCTIONS)
-- Slide 13 Reference

-- QUERY 1: CALCULATING ONBOARDING SLA COMPLIANCE
WITH SLAProcessingIntervals AS (
    SELECT
        application_id,
        application_status,
        submission_timestamp,
        approval_timestamp,
        EXTRACT(EPOCH FROM (approval_timestamp - submission_timestamp))/3600 AS turnaround_hours
    FROM OnboardingTransactions
    WHERE application_status = 'Approved' AND approval_timestamp IS NOT NULL
)
SELECT
    COUNT(application_id) AS total_approved_applications,
    ROUND(AVG(turnaround_hours), 2) AS average_turnaround_hours,
    ROUND((COUNT(CASE WHEN turnaround_hours <= 24 THEN 1 END) * 100.0) / COUNT(application_id), 2) AS sla_compliance_percentage
FROM SLAProcessingIntervals;

-- QUERY 2: IDENTIFYING PIPELINE VERIFICATION BOTTLENECKS
SELECT
    rejection_reason,
    COUNT(application_id) AS total_rejected_cases,
    DENSE_RANK() OVER (ORDER BY COUNT(application_id) DESC) AS bottleneck_priority_rank
FROM OnboardingTransactions
WHERE application_status = 'Rejected'
GROUP BY rejection_reason;
