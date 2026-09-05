# Diabetic Patient Hospital Readmissions Analysis

## Overview
Analysis of 25,000 diabetic patient hospital records to identify the strongest predictors of 30-day readmission risk. The goal: move past a single "readmission rate" number and surface actionable, segment-level risk signals a hospital could realistically act on.

**Tools:** MySQL (SQL) · Tableau Desktop · GitHub

## Dataset
[Hospital Readmissions Dataset (Kaggle)](https://www.kaggle.com/datasets/dubradave/hospital-readmissions) — 25,000 patient records with demographic, treatment, and diagnosis data, sourced from 10 years of clinical care at 130 US hospitals.

## Methodology
All analysis was done in SQL before moving to visualization, using progressively advanced techniques:
- Aggregate functions and conditional aggregation (`SUM(CASE WHEN...)`)
- CTEs (`WITH`) for risk segmentation
- Window functions (`RANK()`, `NTILE()`, `AVG() OVER (PARTITION BY...)`)
- Correlated subqueries, compared directly against their window-function equivalents for a performance discussion

Full queries: [`sql/readmissions_queries.sql`](sql/readmissions_queries.sql)

## Key Findings

**1. Overall readmission rate: 47.02%** across 25,000 patients — nearly 1 in 2 patients returned to the hospital, matching the published benchmark for this dataset.

**2. Diabetes has the highest diagnosis-level readmission rate (53.63%)**, roughly 6.6 points above baseline. Musculoskeletal diagnoses were lowest at 39.54% — a 14-point spread across diagnosis categories.

**3. Prior utilization is the strongest predictor identified.** Patients with 4+ prior inpatient/ER visits ("high prior utilization") were readmitted at 78.91%, compared to 38.92% for patients with zero prior visits — a 40-point spread, by far the widest gap of any segmentation tested. This is the analysis's headline finding: past hospital utilization predicts future utilization far more strongly than diagnosis or treatment intensity alone.

**4. Diabetes ranks as the #1 highest-readmitting diagnosis within 4 of the 7 recorded medical specialties** (Emergency/Trauma, Internal Medicine, Surgery, and unrecorded/"Missing" specialty), reinforcing it as a consistent cross-specialty driver rather than a one-off aggregate artifact.

**5. Treatment intensity shows a real but non-linear relationship with readmission.** Splitting patients into 10 deciles by medication + procedure count, the lowest-intensity decile sits at 37.92% — but the peak is decile 2 (52.84%), not the highest-intensity decile 1 (43.84%). Rather than force a clean linear story, this is reported as-is: treatment intensity alone is not a clean standalone risk predictor.

**6. Length-of-stay outliers are fairly evenly distributed across specialties (38–44%)**, with Surgery patients most likely to exceed their specialty's typical stay (44.35%). This spread is much narrower than the prior-utilization finding, suggesting length of stay is a comparatively weaker readmission signal.
