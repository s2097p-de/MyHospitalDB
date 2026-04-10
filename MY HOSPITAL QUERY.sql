-- Insight : Which doctors are generating the most revenue for the hospital?
-- Business Value: Identifies top-performing clinicians and departments contributing most to the hospital's financial health.
SELECT 
    d.Doctor_Name, 
    d.Dept,
    SUM(b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) AS Total_Revenue,
    RANK() OVER (ORDER BY SUM(b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) DESC) as Revenue_Rank
FROM Doctor d
JOIN Patient p ON d.DoctorID = p.DoctorID
JOIN Bill b ON p.Pid = b.Pid
GROUP BY d.DoctorID, d.Doctor_Name, d.Dept;

-- Insight: Are certain patients being billed significantly higher than the average for their department?
-- Business Value: Helps in auditing and identifying outliers in billing, ensuring pricing consistency across similar medical cases.
SELECT 
    p.F_Name, 
    p.L_Name, 
    d.Dept,
    (b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) AS Patient_Total_Bill,
    AVG(b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) 
        OVER(PARTITION BY d.Dept) AS Dept_Avg_Bill,
    (b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) - 
    AVG(b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) 
        OVER(PARTITION BY d.Dept) AS Deviation_From_Avg
FROM Patient p
JOIN Doctor d ON p.DoctorID = d.DoctorID
JOIN Bill b ON p.Pid = b.Pid;

-- Insight: How is a doctor's lab revenue growing over time?
-- Business Value: Tracks the velocity of diagnostic services and helps forecast monthly or quarterly revenue per specialist.
SELECT 
    d.Doctor_Name, 
    lr.Date, 
    lr.Amount as Report_Cost,
    SUM(lr.Amount) OVER(PARTITION BY d.DoctorID ORDER BY lr.Date) AS Cumulative_Lab_Revenue
FROM Doctor d
JOIN Lab_Report lr ON d.DoctorID = lr.DoctorID
ORDER BY d.DoctorID, lr.Date;

-- Insight: Who are the top 3 highest-spending patients for every specific disease?
/* Business Value: Provides insights into which diseases are most resource-intensive and helps hospital management focus on optimizing care 
for these high-impact segments.*/
WITH PatientSpending AS (
    SELECT 
        p.Pid, 
        p.F_Name, 
        p.Disease,
        (b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) AS Total_Bill,
        ROW_NUMBER() OVER(PARTITION BY p.Disease ORDER BY (b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) DESC) as Spending_Rank
    FROM Patient p
    JOIN Bill b ON p.Pid = b.Pid
)
SELECT * FROM PatientSpending 
WHERE Spending_Rank <= 3;

-- Insight: What percentage of our current patients have visited before?
-- Business Value: Helps marketing and administration understand patient loyalty and the effectiveness of long-term care.
SELECT 
    p.Pid, 
    p.F_Name, 
    p.L_Name,
    COUNT(b.Bill_No) OVER(PARTITION BY p.Pid) as Visit_Count,
    CASE 
        WHEN COUNT(b.Bill_No) OVER(PARTITION BY p.Pid) > 1 THEN 'Returning Patient'
        ELSE 'New Patient'
    END as Patient_Status
FROM Patient p
JOIN Bill b ON p.Pid = b.Pid;

-- Insight: Which doctors are "Diagnostic Heavy"?
/* Business Value: Helps identify if certain doctors rely heavily on diagnostics,
which can be used for hospital quality control and equipment allocation.*/
SELECT 
    d.Doctor_Name,
    COUNT(DISTINCT p.Pid) as Total_Patients,
    COUNT(lr.Lab_No) as Total_Labs_Ordered,
    CAST(COUNT(lr.Lab_No) AS FLOAT) / COUNT(DISTINCT p.Pid) as Lab_to_Patient_Ratio,
    CUME_DIST() OVER(ORDER BY COUNT(lr.Lab_No) / COUNT(DISTINCT p.Pid) DESC) as Referral_Density
FROM Doctor d
LEFT JOIN Patient p ON d.DoctorID = p.DoctorID
LEFT JOIN Lab_Report lr ON d.DoctorID = lr.DoctorID
GROUP BY d.DoctorID, d.Doctor_Name;

