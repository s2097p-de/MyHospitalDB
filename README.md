# MyHospitalDB: Healthcare Management System
A robust SQL-based relational database system designed to manage hospital operations, including patient tracking, doctor assignments, room allocations, lab reporting, and comprehensive billing.

# 📋 Overview
This project contains the complete schema and sample data for a hospital management system. It is designed to handle both Inpatient and Outpatient workflows, providing a 360-degree view of patient care and hospital revenue.

# 🏗️ Database Schema
The database consists of the following core tables:
Doctor: Information on medical staff across various departments (Cardiology, Orthopedics, etc.).
Patient: Centralized demographic data and assigned primary doctors.
Room: Tracking room types (Deluxe, General, ICU) and availability.
Inpatient/Outpatient: Specific visit logs for hospital admissions vs. routine checkups.
Lab_Report: Records of diagnostic tests, categories, and costs.
Bill: Financial breakdowns of room charges, lab fees, medicine, and operation costs.

🚀 Getting Started
Prerequisites
MySQL, PostgreSQL, or any standard SQL database engine.

📊 Business Insights Included
The project includes complex SQL scripts utilizing Joins and Window Functions to extract high-level business intelligence:

Revenue Performance: Ranking doctors and departments by total revenue generated.

Billing Audits: Comparing individual patient bills against departmental averages to find outliers.

Growth Analytics: Helps identify if certain doctors rely heavily on diagnostics,
which can be used for hospital quality control and equipment allocation.

Resource Management: Analyzing room utilization rates and daily profitability by room category.

# 📂 File Structure
MyHospitalDb.sql: The primary script for database creation, table definitions, and initial data seeding.
bill (1).csv: A raw data export containing 30,000 billing records for large-scale testing.
insert_queries.sql: Pre-formatted INSERT statements for quick data population.

# 🛠️ Sample Query
To find the top 3 highest spending patients per disease category:

SQL
WITH PatientSpending AS (
    SELECT 
        p.F_Name, p.Disease,
        (b.Room_Charges + b.Lab_Charges + b.Medicine_Charges + b.Operation_Charges) AS Total_Bill,
        ROW_NUMBER() OVER(PARTITION BY p.Disease ORDER BY Total_Bill DESC) as Rank
    FROM Patient p
    JOIN Bill b ON p.Pid = b.Pid
)
SELECT * FROM PatientSpending WHERE Rank <= 3;
# Author: SANTANU PATHAK
