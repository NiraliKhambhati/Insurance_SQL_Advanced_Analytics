-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS insurance_db;
USE insurance_db;

-- Create the table
CREATE TABLE IF NOT EXISTS insurance_data (
    Age INT,
    Is_Senior INT,
    Marital_Status VARCHAR(10),
    Married_Premium_Discount INT,
    Prior_Insurance VARCHAR(15),
    Prior_Insurance_Premium_Adjustment INT,
    Claims_Frequency INT,
    Claims_Severity VARCHAR(10),
    Claims_Adjustment INT,
    Policy_Type VARCHAR(20),
    Policy_Adjustment INT,
    Premium_Amount INT,
    Safe_Driver_Discount INT,
    Multi_Policy_Discount INT,
    Bundling_Discount INT,
    Total_Discounts INT,
    Source_of_Lead VARCHAR(20),
    Time_Since_First_Contact INT,
    Conversion_Status INT,
    Website_Visits INT,
    Inquiries INT,
    Quotes_Requested INT,
    Time_to_Conversion INT,
    Credit_Score INT,
    Premium_Adjustment_Credit INT,
    Region VARCHAR(15),
    Premium_Adjustment_Region INT
);

-- Confirm the table has been created
SHOW TABLES;

-- Check Table Structure
DESCRIBE insurance_data;

-- Check Total Records
SELECT COUNT(*)
FROM insurance_data;
-- 10000 Records

-- Preview First Few Rows
SELECT *
FROM insurance_data
LIMIT 10;

-- Check For Missing or Anomalous Data
SELECT 
      SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) as Age_Null,
      SUM(CASE WHEN Premium_Amount IS NULL THEN 1 ELSE 0 END) as Prenium_Amount_Null,
      SUM(CASE WHEN Claims_Frequency IS NULL THEN 1 ELSE 0 END) as Claims_Frequency_Null
FROM insurance_data;

-- Identify Outliers
SELECT 
      MIN(Age) as Min_age, 
      MAX(Age) as MAx_Age,
      MIN(Premium_Amount) as Min_Prenium_Amt,
      MAX(Premium_Amount) as Max_Prenium_Amt
FROM insurance_data;

SELECT
      ROUND(AVG(Age), 0) as Avg_Age,
      ROUND(AVG(Premium_Amount),2) as Avg_Prenium_Amt,
      ROUND(AVG(Claims_Frequency),2) as Avg_Claims_Frequency
FROM insurance_data;

-- Distribution Catergorical Data
SELECT 
      Marital_Status,
      COUNT(*) as Count
FROM insurance_data
GROUP By Marital_Status
ORDER BY COUNT DESC;

SELECT 
	  Region,
      COUNT(*) as Count
FROM insurance_data
GROUP BY Region
ORDER BY Count DESC;

-- What is Conversion Rate by Region?
```sql
SELECT 
    Region,
    COUNT(*) AS Total_Customers,
    SUM(Conversion_Status) AS Converted_Customers,
    ROUND(AVG(Conversion_Status) * 100, 2) AS Conversion_Rate
FROM insurance_data
GROUP BY Region
ORDER BY Conversion_Rate DESC;
```

-- What are the top 5 regions with the highest average premium? 
WITH RegionPremium as (
	SELECT 
          Region,
          ROUND(AVG(Premium_Amount), 2) as Avg_Prenium,
          RANK() OVER (ORDER BY  AVG(Premium_Amount) DESC) as Prenium_Rank
	FROM insurance_data
    GROUP BY Region
)
SELECT Region, Avg_Prenium, Prenium_Rank
FROM RegionPremium
WHERE Prenium_Rank <= 3;

-- How does the Claims Frequency vary across policy uses?
WITH Claim_Frequecy as (
     SELECT 
		   Policy_Type,
           AVG(Claims_Frequency) as Avg_Claim_Frequecy,
           SUM(Claims_Frequency) as Total_Claim_Frequency
	FROM insurance_data
    GROUP BY Policy_Type
)
SELECT *
FROM Claim_Frequecy
ORDER BY Avg_Claim_Frequecy DESC;
           
-- As I don't have Cusomer_ID Column, I want to assign one to each

-- ALTER TABLE insurance_data
-- ADD COLUMN Customer_ID INT NOT NULL
-- AUTO_INCREMENT PRIMARY KEY;

-- Checking Cusotmer_ID
SELECT Customer_ID
FROM insurance_data
LIMIT 10;

-- Identify customers eligible for high-risk categorization (Using CASE & Subquery)
SELECT 
	Customer_ID,
    Age,
    Claims_Frequency,
    CASE
        WHEN Claims_Frequency > (SELECT AVG(Claims_Frequency) as Avg_Claims_Frequency FROM insurance_data) 
	    Then 'High Risk'
        ELSE 'Low Risk'
	END as Risk_Catergory
FROM insurance_data
ORDER BY Risk_Catergory;

--  Which customers received the highest discounts above the average?
SELECT 
     Customer_ID,
     COALESCE(Safe_Driver_Discount, 0) +
     COALESCE(Multi_Policy_Discount, 0) +
     coalesce(Bundling_Discount, 0) as Total_Discounts
FROM insurance_data
HAVING Total_Discounts > (SELECT 
                                AVG(
                                COALESCE(Safe_Driver_Discount, 0) +
                                COALESCE(Multi_Policy_Discount, 0) +
                                COALESCE(Bundling_Discount, 0))
                          FROM insurance_data)
ORDER BY Total_Discounts DESC;

-- Does a higher total discount increase conversion rates?
SELECT 
    Conversion_Status,
    AVG(COALESCE(Safe_Driver_Discount, 0) +
        COALESCE(Multi_Policy_Discount, 0) +
        COALESCE(Bundling_Discount, 0)) AS Avg_Discount
FROM insurance_data
GROUP BY Conversion_Status
ORDER BY Avg_Discount DESC;

-- Are younger or older customers getting higher discounts?
SELECT
      CASE
          WHEN Age < 25 THEN 'Young'
          WHEN Age BETWEEN 25 AND 65 THEN 'Middle-Aged'
          ELSE 'Senior'
	  END as Age_Group,
      AVG(COALESCE(Safe_Driver_Discount, 0) +
          COALESCE(Multi_Policy_Discount, 0) +
		  COALESCE(Bundling_Discount, 0)) as Avg_Discount
FROM insurance_data
GROUP BY Age_Group
ORDER BY Avg_Discount DESC;

-- Find the customers with the highest number of inquiries and their conversion status
WITH InquiriesRank as (
       SELECT 
             Customer_ID,
			 Inquiries,
             Conversion_Status,
             DENSE_RANK() OVER (ORDER BY Inquiries DESC) AS Inquiry_Rank
       FROM insurance_data)
SELECT
     Customer_ID, 
     Inquiries, 
     Conversion_Status, 
     Inquiry_Rank
FROM InquiriesRank
WHERE Inquiry_Rank <= 3
ORDER BY Inquiry_Rank DESC;

-- How long does it typically take for a customer to convert based on their number of inquiries? (Using GROUP BY & Aggregate Functions)
SELECT 
    Inquiries, 
    COUNT(*) AS Total_Customers,
    ROUND(AVG(Time_to_Conversion), 2) AS Avg_Time_to_Conversion
FROM insurance_data
WHERE Conversion_Status = 1  
GROUP BY Inquiries
ORDER BY Avg_Time_to_Conversion DESC;

--  Find the most common sources of leads for converted customers
SELECT 
    Source_of_Lead, 
    COUNT(*) AS Total_Leads,
	SUM(CASE WHEN Conversion_Status = 1 THEN 1 ELSE 0 END) AS Converted_Customers,
    ROUND(SUM(CASE WHEN Conversion_Status = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS Conversion_Rate
FROM insurance_data
GROUP BY Source_of_Lead
LIMIT 5;
