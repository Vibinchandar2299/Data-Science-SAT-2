# Data Cleaning and Preparation Report
**Organization:** ShopVista Commerce Pvt. Ltd.  
**Use Case:** 06 — E-Commerce Return Insight  
**Date:** October 2026  

---

## 1. Executive Summary & Record Audit

| Dataset | Raw Records | Clean Records | Records Excluded / Deduplicated | Primary Cleaning Decisions |
| :--- | :--- | :--- | :--- | :--- |
| **orders.csv** | 5,050 | 5,000 | 50 (duplicates) | Removed 50 exact duplicate rows; flagged 18 extreme discount anomalies (<0% or >100%) and imputed them with median discount (13.18%). |
| **products.csv** | 450 | 450 | 0 | Standardized inconsistent sizing across categories; filled 10 missing brand values with 'Generic / Unknown'; non-sized categories labeled 'Not Applicable'. |
| **customers.csv** | 1,800 | 1,800 | 0 | Filled 15 missing region values with 'Unknown'. |
| **delivery.csv** | 5,000 | 5,000 | 0 | Parsed dates; flagged 12 invalid delivery dates (5 unparseable 'not_a_date', 7 delivered prior to order placement) as invalid without dropping orders or fabricating dates. |
| **returns.csv** | 5,000 | 5,000 | 0 | Validated binary target `return_flag` (639 returns, 12.78% return rate). Imputed 85 missing return reasons on returned orders with 'Unknown'. Set non-returns to 'Not Returned'. |
| **Final Merged Analysis File** | **5,050 raw** | **5,000 orders** | **50 duplicates** | Clean 1:1 join grain on `order_id`. No Cartesian explosion. Engineered financial, temporal, and delivery delay metrics. |

---

## 2. Detailed Cleaning Decisions & Rules

### A. Order Deduplication
- **Issue:** `orders.csv` contained 5,050 rows, including 50 exact duplicate order records.
- **Decision:** Deduplicated by `order_id` keeping the first occurrence.
- **Justification:** Retaining duplicate orders artificially inflates order volumes and distorts return percentages.

### B. Extreme & Invalid Discount Values
- **Issue:** Discount percentages ranged from -5.0% to 150.0%.
  - 3 orders had negative discounts (-5.0%).
  - 15 orders had discounts >100% (110%, 125%, 150%).
  - 2 orders had legitimate high discounts (52.16% and 53.06%).
- **Decision:** Flagged invalid values (<0% or >100%) in `is_discount_anomaly`. Imputed clean discount column `discount_pct_clean` using the median discount (13.18%) of valid transactions. Legitimate clearances (52%-53%) were preserved untouched.
- **Justification:** Negative discounts or discounts exceeding product value are physical impossibilities in commercial sales; replacing them with median discount preserves statistical integrity while retaining order records for analysis.

### C. Size Label Harmonization
- **Issue:** Inconsistent casing and naming conventions across sizes ('xs' vs 'XS', 'Small' vs 'S', 'medium' vs 'M', 'Large' vs 'L', 'x-large' vs 'XL', '2XL' vs 'XXL').
- **Decision:** Mapped all variations into a standardized enum: `XS`, `S`, `M`, `L`, `XL`, `XXL`, `One Size`, `Standard`. Items without size requirement (electronics, home goods) were explicitly tagged `Not Applicable`.

### D. Delivery Date Validation
- **Issue:** 5 delivery records had unparseable text `'not_a_date'`. 7 records had delivery timestamps dated prior to the order placement date (`2024-12-01` vs 2025/2026 order dates).
- **Decision:** Created a boolean flag `valid_delivery_date`. Excluded invalid records from delivery delay calculations (`delivery_delay_days` = NaN) and tagged `delivery_status = 'Invalid Date'`. Valid delivery records (4,988) were evaluated for delay.
- **Justification:** In accordance with the assessment requirements, delivery dates were NOT fabricated. Valid order records remain in the dataset for other analyses.

### E. Return Reason Imputation
- **Issue:** 85 returned items had missing (`NaN`) return reasons. Non-returned items legitimately had blank reasons.
- **Decision:** Created `return_reason_descriptive`. For returned orders (`return_flag == 1`), missing values were labeled `'Unknown'`. Non-returned orders were labeled `'Not Returned'`.
- **Justification:** Avoids conflating legitimate non-returns with missing data while acknowledging unrecorded customer feedback.

---

## 3. Join Cardinality & Final Integrity Verification

- **Merge Structure:**
  - Base: `orders_cleaned` (5,000 rows, unique `order_id`)
  - Left Join `products_cleaned` on `product_id` (450 products) -> 5,000 rows
  - Left Join `customers_cleaned` on `customer_id` (1,800 customers) -> 5,000 rows
  - Left Join `delivery_cleaned` on `order_id` (5,000 delivery records) -> 5,000 rows
  - Left Join `returns_cleaned` on `order_id` (5,000 return records) -> 5,000 rows
- **Final Output Dimensions:** Exactly 5,000 rows × 26 columns.
- **Target Distribution:**
  - `return_flag = 0` (Not Returned): 4,361 (87.22%)
  - `return_flag = 1` (Returned): 639 (12.78%)
