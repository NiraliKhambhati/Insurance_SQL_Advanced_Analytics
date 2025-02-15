# Insurance Data Analysis - SQL Project

## 🚀 Project Overview
This SQL project dives deep into an insurance dataset to analyze customer behaviors, conversion trends, claims patterns, and risk categorization. By leveraging SQL queries and advanced analytics, the project uncovers insights into how different factors like discounts, inquiries, and claims impact conversion rates and policy pricing.

## 📊 Data Overview
The dataset contains 10,000 records with 27 columns, covering customer demographics, policy details, claims history, and conversion metrics. Here’s a brief look at the dataset:
### Key Attributes:
- Demographic Information: Age, Marital_Status, Region, Credit_Score
- Insurance History: Prior_Insurance, Prior_Insurance_Premium_Adjustment
- Policy Details: Policy_Type, Premium_Amount, Safe_Driver_Discount, Bundling_Discount
- Claims Information: Claims_Frequency, Claims_Severity, Claims_Adjustment
- Conversion Metrics: Source_of_Lead, Conversion_Status, Website_Visits, Inquiries, Time_to_Conversion

## Summary Statistics:
- Average Age: 40 years
- Prenium Amount Range: $1,800- $2,936 (Average: $2,219.57)
- Most Common Lead Source: Online(Highest), Referrals(Highest Conversion Rate)
- Highest Discounted Group: Seniors

## 🔍 Key Analysis & Findings
### 1. Conversion Rate by Region
SELECT 
    Region,
    COUNT(*) AS Total_Customers,
    SUM(Conversion_Status) AS Converted_Customers,
    ROUND(AVG(Conversion_Status) * 100, 2) AS Conversion_Rate
FROM insurance_data
GROUP BY Region
ORDER BY Conversion_Rate DESC;

#### This indicates that rural customers are more likely to convert, possibly due to different insurance needs or fewer competitive alternatives.
#### Rural Areas have the highest conversion rate (59.92%), followed by Suburban (57.62%) and Urban (56.76%).
#### Despite Urban regions having the most customers, they show the lowest conversion rate, suggesting differences in engagement strategies.

### 2. Prenium Analysis by Region
WITH RegionPremium AS (
    SELECT 
        Region,
        ROUND(AVG(Premium_Amount), 2) AS Avg_Premium,
        RANK() OVER (ORDER BY AVG(Premium_Amount) DESC) AS Premium_Rank
    FROM insurance_data
    GROUP BY Region
)
SELECT Region, Avg_Premium, Premium_Rank
FROM RegionPremium
WHERE Premium_Rank <= 3;

#### Urban customers pay the highest average premium ($2,256.48), followed by Suburban ($2,201.85) and Rural ($2,157.28).
#### Higher urban premiums might indicate increased risks, traffic density, or higher claim rates.

### 3. Claims Frequency by Policy Type
WITH Claim_Frequency AS (
    SELECT 
        Policy_Type,
        AVG(Claims_Frequency) AS Avg_Claim_Frequency,
        SUM(Claims_Frequency) AS Total_Claim_Frequency
    FROM insurance_data
    GROUP BY Policy_Type
)
SELECT *
FROM Claim_Frequency
ORDER BY Avg_Claim_Frequency DESC;

##### **Insights**
Full Coverage and Liability-Only policies have nearly identical average claims frequency (~0.50).
However, Full Coverage policies generate more total claims (2,987 vs. 1,985) due to a larger customer base.

### 4. High-Risk Customer Identification
SELECT 
    Customer_ID,
    Age,
    Claims_Frequency,
    CASE
        WHEN Claims_Frequency > (SELECT AVG(Claims_Frequency) FROM insurance_data) 
        THEN 'High Risk'
        ELSE 'Low Risk'
    END AS Risk_Category
FROM insurance_data
ORDER BY Risk_Category;

#### Customers exceeding the average Claims Frequency are labeled "High Risk."
#### This insight helps adjust premiums, detect fraud, and implement risk mitigation strategies. 

### 5. Impact of Discounts on Conversion
SELECT 
    Conversion_Status,
    AVG(COALESCE(Safe_Driver_Discount, 0) +
        COALESCE(Multi_Policy_Discount, 0) +
        COALESCE(Bundling_Discount, 0)) AS Avg_Discount
FROM insurance_data
GROUP BY Conversion_Status
ORDER BY Avg_Discount DESC;

#### Customers with higher discounts (Avg: 0.6138) convert more compared to those with lower discounts (0.5863).

### 6. Inquiry Volume & Conversion Patterns
WITH InquiriesRank AS (
    SELECT 
        Customer_ID,
        Inquiries,
        Conversion_Status,
        DENSE_RANK() OVER (ORDER BY Inquiries DESC) AS Inquiry_Rank
    FROM insurance_data
)
SELECT Customer_ID, Inquiries, Conversion_Status, Inquiry_Rank
FROM InquiriesRank
WHERE Inquiry_Rank <= 3
ORDER BY Inquiry_Rank DESC;

#### Customers making 9+ inquiries rarely convert (0% conversion for highest-inquiry customers).
#### Customers with 1-2 inquiries convert the most, suggesting that excessive inquiries indicate hesitation or dissatisfaction.
#### Average conversion time increases as inquiries increase.

## 🛠️ Technologies Used
- SQL Queries: MySQL
- Data Analysis Techniques: Aggregations, CTEs, Subqueries, Window Functions
- Data Cleaning & Transformation: COALESCE, CASE Statements
- Ranking & Categorization: DENSE_RANK, RANK(), AVG(), GROUP BY

## 📩 Contact & Collaboration
Want to collaborate or have insights to share? Let's connect! 🚀
