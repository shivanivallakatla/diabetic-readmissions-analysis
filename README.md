# project-diabetic-readmissions-analysis
SQL and Tableau analysis of 25,000 diabetic patient hospital records to identify 
which patients are at highest risk of readmission and why.
## Business Question
A hospital system wants to reduce readmission-related costs and penalties. 
Which patients are most likely to be readmitted, 
what prior history and treatment factors predict it, 
and where should discharge planning resources be focused?
## Dataset
- Source: Kaggle — Hospital Readmissions Dataset
- Size: 25,000 patient records
- Columns: Age Bracket, Time in Hospital, Number of Lab Procedures, Number of Procedures, Number of Medications, Prior Outpatient/Inpatient/Emergency Visits, Medical Specialty, Diagnosis Categories, Glucose Test, A1C Test, Medication Change, Diabetes Medication, Readmitted
- Link: https://www.kaggle.com/datasets/dubradave/hospital-readmissions
## Tools Used
- MySQL — data cleaning, exploration, and analysis (6 SQL queries)
- Tableau Desktop — interactive dashboard with 4 visualizations
## Key Findings
1. BASELINE: Overall readmission rate is 47.02% across 25,000 patients — 
   nearly 1 in 2 patients return to the hospital, matching the published 
   benchmark for this dataset
2. DIAGNOSIS: Diabetes has the highest diagnosis-level readmission rate at 
   53.63%, roughly 6.6 points above baseline; Musculoskeletal is lowest at 
   39.54% — a 14-point spread across diagnosis categories
3. PRIOR UTILIZATION: Patients with 4+ prior inpatient/ER visits are 
   readmitted at 78.91%, compared to 38.92% for patients with zero prior 
   visits — a 40-point spread, the widest gap of any segmentation tested 
   and the strongest predictor identified
4. SPECIALTY PATTERNS: Diabetes ranks as the #1 highest-readmitting 
   diagnosis within 4 of the 7 recorded medical specialties (Emergency/
   Trauma, Internal Medicine, Surgery, and unrecorded "Missing" specialty), 
   confirming it as a consistent driver rather than a one-off aggregate 
   artifact
5. TREATMENT INTENSITY: Splitting patients into 10 deciles by medication + 
   procedure count shows a real but non-linear relationship — lowest-
   intensity decile sits at 37.92%, but the peak is decile 2 at 52.84%, 
   not the highest-intensity decile 1 (43.84%) — intensity alone is not a 
   clean standalone risk predictor
6. LENGTH OF STAY: Surgery patients are most likely to exceed their 
   specialty's average length of stay (44.35%); length-of-stay outliers 
   are otherwise evenly distributed across specialties (38–44% range) — 
   a much weaker signal than prior utilization
## Recommendation
1. Flag patients with 4+ prior inpatient/ER visits for enhanced discharge 
planning — this single factor separates a 78.91% readmission rate from 
38.92%, the widest gap in the analysis
2. Prioritize diabetes management programs — diabetes patients readmit 
at 53.63% overall and rank #1 in 4 of 7 specialties, making it the most 
consistent diagnosis-level risk driver
3. Don't rely on treatment intensity alone as a risk score — the non-
linear decile pattern shows medication/procedure count needs to be 
combined with prior utilization history to be a reliable predictor
## Dashboard
https://public.tableau.com/app/profile/shivani.vallakatla/viz/Superstore_Sales_Performance_Analysis/SuperstoreSalesPerformanceAnalysis
## SQL Queries
All 6 analysis queries with comments are in the /sql folder.
