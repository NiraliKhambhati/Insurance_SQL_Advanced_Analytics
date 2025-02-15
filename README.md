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

#### Rural Areas have the highest conversion rate (59.92%), followed by Suburban (57.62%) and Urban (56.76%).
