# RFM Segmentation with MySQL

This project demonstrates how to perform **RFM (Recency, Frequency, Monetary)** analysis using MySQL on customer transaction data. RFM is a powerful technique for segmenting customers based on their purchasing behavior, and it helps businesses drive personalized marketing and retention strategies.

---

##  Project Structure

- **Database:** `SUPERRFM`
- **Table:** `sales_data`
- **Views Created:**
  - `RFM_SCORE_DATA` – calculates RFM values and scores
  - `RFM_ANALYSIS` – segments customers into business groups
- **Final Output:** Summary table of customer segments with metrics

---

## RFM Concepts Used

- **Recency:** Days since last purchase (lower is better)
- **Frequency:** Number of purchases (higher is better)
- **Monetary:** Total spending amount (higher is better)

Each metric is scored from 1 to 4 using MySQL’s `NTILE(4)` function.

---

## Key SQL Operations

- `DATEDIFF()` – to compute recency
- `NTILE(4)` – to assign RFM scores based on quartiles
- `CASE` – to categorize customers into segments
- `GROUP BY` – for segment-level aggregations

---

##  Customer Segments Defined

| Segment Name              | Example RFM Combination | Description |
|--------------------------|--------------------------|-------------|
| Loyal                    | 444, 443, 434, 433       | Recent, frequent, and big spenders |
| Active                   | 333, 332, 341, 432       | Engaged customers |
| Slipping Away            | 134, 143, 344            | Used to buy, but slowing down |
| Churned                  | 111, 112, 114            | Not buying anymore |
| New Customers            | 311, 411, 331            | Recently joined, not frequent yet |
| Potential Churners       | 222, 223, 233            | Mid-tier, risky |
| Others                   | --                       | Does not match predefined groups |

---

##  Final Report

The final query outputs a summary report showing:

- Number of customers per segment
- Average and total sales per segment
- Average recency and frequency

This helps understand which segments are most valuable and which need attention.

---

## Use Cases

- Target marketing campaigns (e.g., loyalty rewards, re-engagement emails)
- Customer churn prevention
- Business decision-making based on customer behavior

---

##  How to Use

1. Import your sales data into MySQL (table name: `sales_data`)
2. Run the full SQL script (`rfm_analysis.sql`)
3. Query the `RFM_ANALYSIS` view or use the final summary report

---

##  Sample Output (Example)

```sql
+------------------------+---------------------+--------------------------+--------------+--------------+-------------------+
| CUSTOMER_SEGMENT       | NUMBER_OF_CUSTOMERS | AVERAGE_MONETARY_VALUE  | TOTAL_SALES  | AVG_RECENCY  | AVG_FREQUENCY     |
+------------------------+---------------------+--------------------------+--------------+--------------+-------------------+
| Loyal                  | 25                  | 4,200                    | 105,000      | 12           | 8.3               |
| Churned Customer       | 40                  | 950                      | 38,000       | 142          | 2.1               |
| Active                 | 30                  | 2,800                    | 84,000       | 25           | 6.7               |
...
Author
Sayem Mohammad Prince
Software Engineering Student at Daffodil International University
Project Type: Work Portfolio
Tools Used: MySQL