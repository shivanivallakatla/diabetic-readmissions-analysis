-- ============================================================
-- Diabetic Patient Hospital Readmissions Analysis
-- Dataset: dubradave/hospital-readmissions (Kaggle), 25,000 records
-- ============================================================

-- ------------------------------------------------------------
-- QUERY 1: Baseline Readmission Rate
-- Purpose: Establish the headline KPI that every other finding is compared against
-- ------------------------------------------------------------
SELECT 
    ROUND(100.0 * SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate_pct
FROM readmissions_raw;
-- RESULT: 47.02% (matches published benchmark for this dataset)


-- ------------------------------------------------------------
-- QUERY 2: Readmission Rate by Diagnosis Category
-- Purpose: Identify which diagnoses drive the overall rate up or down
-- ------------------------------------------------------------
SELECT 
    diag_1,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) AS readmitted_count,
    ROUND(100.0 * SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate_pct
FROM readmissions_raw
GROUP BY diag_1
HAVING COUNT(*) >= 30
ORDER BY readmission_rate_pct DESC;
-- RESULT: Diabetes highest (53.63%), Musculoskeletal lowest (39.54%) - 14pt spread


-- ------------------------------------------------------------
-- QUERY 3: CTE Risk Segmentation by Prior Utilization
-- Purpose: Test whether prior inpatient/ER visits predict readmission risk
-- ------------------------------------------------------------
WITH risk_buckets AS (
    SELECT *,
        CASE 
            WHEN n_inpatient + n_emergency = 0 THEN 'Low prior utilization'
            WHEN n_inpatient + n_emergency BETWEEN 1 AND 3 THEN 'Moderate prior utilization'
            ELSE 'High prior utilization'
        END AS risk_segment
    FROM readmissions_raw
)
SELECT 
    risk_segment,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate_pct
FROM risk_buckets
GROUP BY risk_segment
ORDER BY readmission_rate_pct DESC;
-- RESULT: High utilization 78.91% vs Low utilization 38.92% - 40pt spread (strongest finding)


-- ------------------------------------------------------------
-- QUERY 4: Window Function - Rank Diagnoses Within Each Specialty
-- Purpose: Compare diagnoses within their own specialty context, not the whole dataset
-- ------------------------------------------------------------
SELECT 
    a.total_patients,
    a.diag_1,
    a.medical_specialty,
    a.pat_c_p,
    RANK() OVER (PARTITION BY a.medical_specialty ORDER BY a.pat_c_p DESC) AS specialty_rank
FROM (
    SELECT
        COUNT(*) AS total_patients,
        diag_1,
        medical_specialty,
        ROUND(SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS pat_c_p
    FROM readmissions_raw
    GROUP BY diag_1, medical_specialty
    HAVING COUNT(*) >= 20
) AS a;
-- RESULT: Diabetes ranks #1 in 4 of 7 specialties


-- ------------------------------------------------------------
-- QUERY 5: NTILE - Patient Risk Deciles by Treatment Intensity
-- Purpose: Segment all patients into 10 equal groups by medication + procedure load
-- ------------------------------------------------------------
WITH deciles AS (
    SELECT *,
        NTILE(10) OVER (ORDER BY n_medications + n_procedures DESC) AS risk_decile
    FROM readmissions_raw
)
SELECT 
    risk_decile,
    COUNT(*) AS total_patients,
    ROUND(100.0 * SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate_pct
FROM deciles
GROUP BY risk_decile
ORDER BY risk_decile;
-- RESULT: Non-linear - peak at decile 2 (52.84%), lowest at decile 10 (37.92%)


-- ------------------------------------------------------------
-- QUERY 6: Correlated Subquery vs Window Function - Length of Stay Outliers
-- Purpose: Identify patients exceeding their own specialty's average length of stay
-- ------------------------------------------------------------

-- Version A: Correlated subquery (re-evaluates once per row - slower, but conceptually direct)
SELECT 
    r.patient_id,
    r.medical_specialty,
    r.time_in_hospital
FROM readmissions_raw r
WHERE r.time_in_hospital > (
    SELECT AVG(r2.time_in_hospital)
    FROM readmissions_raw r2
    WHERE r2.medical_specialty = r.medical_specialty
);

-- Version B: Window function equivalent (calculates each specialty's average once - faster)
SELECT 
    medical_specialty,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN time_in_hospital > time_medic THEN 1 ELSE 0 END) AS above_avg_count,
    ROUND(100.0 * SUM(CASE WHEN time_in_hospital > time_medic THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_above_avg
FROM (
    SELECT *, AVG(time_in_hospital) OVER (PARTITION BY medical_specialty) AS time_medic
    FROM readmissions_raw
) aa
GROUP BY medical_specialty
ORDER BY pct_above_avg DESC;
-- RESULT: Surgery highest (44.35%), Missing lowest (38.31%) - 6pt spread (weaker signal)
