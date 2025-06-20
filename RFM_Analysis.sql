-- Create a database for RFM analysis
CREATE DATABASE SUPERRFM;

-- Select all data from the sales_data table
SELECT * FROM `superrfm`.sales_data;

-- Count total rows in sales_data
SELECT COUNT(*) FROM `superrfm`.sales_data;

-- Disable safe updates to allow date conversion
SET sql_safe_updates = 0;

-- Convert ORDERDATE from string to MySQL date format (e.g., 15/01/22 → 2022-01-15)
UPDATE sales_data
    SET ORDERDATE = STR_TO_DATE(ORDERDATE, '%d/%m/%y');

-- Check the latest order date (used for recency calculation)
SELECT MAX(ORDERDATE) FROM sales_data;

-- View updated sales data
SELECT * FROM sales_data;

-- Create a view that calculates Recency, Frequency, and Monetary (RFM) scores for each customer
CREATE OR REPLACE VIEW RFM_SCORE_DATA AS
WITH CUSTOMER_AGGREGATED_DATA AS (
    -- Aggregate data: latest order, number of purchases, and total sales
    SELECT 
        CUSTOMERNAME,
        DATEDIFF((SELECT MAX(ORDERDATE) FROM SALES_DATA), MAX(ORDERDATE)) AS RECENCY,         -- Days since last purchase
        COUNT(DISTINCT ORDERLINENUMBER) AS FREQUENCY_VALUE,                                    -- Number of orders
        ROUND(SUM(SALES), 0) AS MONETARY_VALUE                                                 -- Total sales amount
    FROM sales_data
    GROUP BY CUSTOMERNAME
),

RFM_SCORE AS (
    -- Assign RFM scores from 1 (low) to 4 (high) using quartiles
    SELECT
        C.*,
        NTILE(4) OVER (ORDER BY RECENCY DESC) AS RECENCY_SCORE,          -- More recent = higher score
        NTILE(4) OVER (ORDER BY FREQUENCY_VALUE ASC) AS FREQUENCY_SCORE, -- Higher frequency = higher score
        NTILE(4) OVER (ORDER BY MONETARY_VALUE ASC) AS MONETARY_SCORE    -- Higher spend = higher score
    FROM CUSTOMER_AGGREGATED_DATA AS C
)

-- Final selection of RFM values, scores, total score, and score combination
SELECT
    R.CUSTOMERNAME,
    R.RECENCY,
    R.RECENCY_SCORE,
    R.FREQUENCY_VALUE,
    R.FREQUENCY_SCORE,
    R.MONETARY_VALUE,
    R.MONETARY_SCORE,
    (RECENCY_SCORE + FREQUENCY_SCORE + MONETARY_SCORE) AS TOTAL_RFM_SCORE,                -- Total score out of 12
    CONCAT_WS('', RECENCY_SCORE, FREQUENCY_SCORE, MONETARY_SCORE) AS RFM_SCORE_COMBINATION -- e.g., 444 = top customer
FROM RFM_SCORE AS R;

-- Segment customers based on RFM combinations using business rules
CREATE OR REPLACE VIEW RFM_ANALYSIS AS
SELECT 
    RFM_SCORE_DATA.*,
    CASE
        WHEN RFM_SCORE_COMBINATION IN (111, 112, 121, 132, 211, 212, 114, 141) THEN 'CHURNED CUSTOMER'
        WHEN RFM_SCORE_COMBINATION IN (133, 134, 143, 224, 334, 343, 344, 144) THEN 'SLIPPING AWAY, CANNOT LOSE'
        WHEN RFM_SCORE_COMBINATION IN (311, 411, 331) THEN 'NEW CUSTOMERS'
        WHEN RFM_SCORE_COMBINATION IN (222, 231, 221, 223, 233, 322) THEN 'POTENTIAL CHURNERS'
        WHEN RFM_SCORE_COMBINATION IN (323, 333, 321, 341, 422, 332, 432) THEN 'ACTIVE'
        WHEN RFM_SCORE_COMBINATION IN (433, 434, 443, 444) THEN 'LOYAL'
        ELSE 'Other'
    END AS CUSTOMER_SEGMENT
FROM RFM_SCORE_DATA;

-- Final summary report showing number of customers and performance metrics by segment
SELECT
    CUSTOMER_SEGMENT,
    COUNT(*) AS NUMBER_OF_CUSTOMERS,                      -- Number of customers in this segment
    ROUND(AVG(MONETARY_VALUE), 0) AS AVERAGE_MONETARY_VALUE, -- Average spend per customer
    ROUND(SUM(MONETARY_VALUE), 0) AS TOTAL_SALES,          -- Total revenue from this segment
    ROUND(AVG(RECENCY), 0) AS AVG_RECENCY,                 -- Average days since last purchase
    ROUND(AVG(FREQUENCY_VALUE), 0) AS AVG_FREQUENCY        -- Average number of purchases
FROM RFM_ANALYSIS
GROUP BY CUSTOMER_SEGMENT
ORDER BY TOTAL_SALES DESC;                                -- Show highest value segments first
