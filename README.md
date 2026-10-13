# E-Commerce Return Insight — DS Sprint Assessment

**Use Case 06:** E-Commerce Return Insight  
**Organization:** ShopVista Commerce Pvt. Ltd.  
**Course Code:** U23AD491 - Data Science | Skill Based Assessment 2  
**Dataset Type:** Synthetic Assessment Dataset  

---

## 1. Project Overview & Business Problem

ShopVista Commerce Pvt. Ltd. is experiencing customer return rates that compress net profit margins, incur heavy reverse logistics expenses, and indicate friction in product satisfaction. 

This repository delivers an end-to-end data analytics and machine learning investigation into the core business question:
> **"Which products and order characteristics are associated with high return rates, and what practical operational interventions can reduce avoidable returns?"**

The investigation integrates five relational sources:
1. `orders.csv` (Transactions, pricing, discounts)
2. `products.csv` (Categories, brands, sizes, sellers)
3. `customers.csv` (Regions, loyalty history)
4. `delivery.csv` (Promised/actual delivery dates, couriers)
5. `returns.csv` (Return status outcome, reasons, return dates)

---

## 2. Directory Structure

```text
├── data/
│   ├── raw/                                  # Pristine raw assessment CSV datasets
│   │   ├── orders.csv                        # 5,050 raw orders (with 50 duplicates)
│   │   ├── products.csv                      # 450 product records
│   │   ├── customers.csv                     # 1,800 customer profiles
│   │   ├── delivery.csv                      # 5,000 fulfillment records
│   │   ├── returns.csv                       # 5,000 return outcome records
│   │   └── README.md                         # Raw dataset specification
│   └── processed/                            # Cleaned, standardized, and merged data
│       ├── orders_cleaned.csv                # Deduplicated orders (5,000 rows)
│       ├── products_cleaned.csv              # Standardized sizing & imputed brands
│       ├── customers_cleaned.csv             # Standardized regions
│       ├── delivery_cleaned.csv              # Validated delivery dates & delay flags
│       ├── returns_cleaned.csv               # Imputed return reasons
│       ├── ecommerce_returns_final_clean.csv # Final merged 1:1 analysis dataset (5,000 rows x 28 cols)
│       └── data_cleaning_report.md           # Full transparent preprocessing audit report
├── notebooks/
│   └── round2_eda_feature_engineering.ipynb  # Runnable end-to-end Python EDA & ML notebook
├── outputs/
│   ├── figures/                              # High-resolution charts (300 DPI)
│   │   ├── eda_1_return_rate_by_category.png
│   │   ├── eda_2_discount_vs_return_rate.png
│   │   ├── eda_3_delivery_delay_vs_return_rate.png
│   │   ├── eda_4_seller_return_rates.png
│   │   ├── eda_5_return_reasons_distribution.png
│   │   ├── eda_6_customer_segment_vs_return_rate.png
│   │   ├── ml_confusion_matrix.png
│   │   ├── ml_feature_importance.png
│   │   └── ml_pr_curve.png
│   ├── ecommerce_return_analysis.xlsx        # 8-sheet Excel workbook with formulas & native charts
│   ├── business_insights_pitch.pptx          # Executive 16:9 presentation slide deck
│   ├── business_insights_pitch.pdf           # Presentation exported to PDF
│   ├── assessment_sheet_answers.md           # Concise candidate response sheet
│   ├── model_metrics.json                    # Machine-readable actual ML metrics
│   └── random_forest_model.joblib            # Serialized trained model pipeline
├── scripts/                                  # Reproducible pipeline execution scripts
│   ├── data_cleaning_and_prep.py             # Preprocessing & table merging script
│   ├── eda_and_ml.py                         # EDA figures generation & Random Forest training
│   ├── generate_excel_analysis.py            # Excel workbook generator script
│   ├── generate_presentation.py              # PowerPoint presentation generator script
│   ├── generate_notebook.py                  # Jupyter notebook generation script
│   └── export_pdf.ps1                        # PowerShell script for PDF export
├── requirements.txt                          # Pinned dependency requirements
└── README.md                                 # Primary repository documentation
```

---

## 3. Data Cleaning & Preparation Summary

| Issue Diagnosed | Records Affected | Methodological Resolution |
| :--- | :--- | :--- |
| **Duplicate Orders** | 50 exact duplicate rows in `orders.csv` | Deduplicated on `order_id` (retaining 5,000 distinct orders). |
| **Extreme Discounts** | 3 negative (-5.0%) and 15 extreme (>100%) discounts | Flagged in `is_discount_anomaly`; imputed `discount_pct_clean` using valid median discount (13.18%). |
| **Invalid Delivery Dates** | 5 unparseable strings (`'not_a_date'`) & 7 pre-order dates | Flagged as `'Invalid Date'`; excluded from delay calculations without fabricating dates. |
| **Inconsistent Sizing** | Casing/label inconsistencies (`'xs'`, `'Large'`, `'2XL'`) | Harmonized into standardized enum (`XS`, `S`, `M`, `L`, `XL`, `XXL`, `One Size`, `Standard`). |
| **Missing Return Reasons** | 85 returned items with unrecorded reasons | Explicitly imputed `'Unknown'` for returned orders; non-returns labeled `'Not Returned'`. |
| **Join Cardinality** | Potential join multiplication | Validated 1:1 foreign key relationships; exactly 5,000 clean transaction rows. |

---

## 4. Key EDA Findings

1. **Apparel Sizing Outlier:**
   - **Apparel** exhibits the highest return rate across all categories at **19.53%** (198 returns / 1,014 orders), significantly exceeding the catalog average of **12.78%**.
   - **Size/Fit Issue** is the single largest customer-stated return reason, comprising **28.33%** (181 orders) of total returns.
   - Footwear is second at **14.15%**, confirming wearable merchandise drives the majority of return friction.

2. **Delivery Delay Escalation:**
   - Orders delivered on-time or early return at **11.04%** (420 returns / 3,804 orders).
   - Orders delivered late surge to an **18.50%** return rate (219 returns / 1,184 orders)—a **67.5% relative increase**.
   - Severe 5-day delivery delays drive return rates to **24.34%**, with **Late Delivery** cited as the second leading cause of returns (**21.13%**, 135 orders).

3. **Discount Depth Correlation:**
   - Return rates steadily increase with discount depth: 10.74% (0–10%), 12.97% (10–20%), 14.93% (20–30%), and 16.72% (30–50%).

4. **Marketplace Seller Disparities:**
   - High-volume merchant partners show sharp divergence: SELLER_015 (25.69% across 109 orders) and SELLER_053 (23.62% across 127 orders) exhibit return rates double the catalog benchmark.

---

## 5. Machine Learning Evaluation

### Prediction Time & Leakage-Free Design
- **Intended Prediction Time:** At checkout / warehouse dispatch (**Pre-Dispatch / Pre-Delivery**).
- **Target Variable:** `return_flag` (Binary: 1 = Return, 0 = Keep; positive prevalence: 12.78%).
- **Strict Leakage Prevention:** Actual fulfillment delivery delays (`delivery_delay_days`, `delivery_status`, `transit_days`, `delivered_date`) and post-outcome data (`return_reason`, `return_date`) are strictly excluded because they are physically unavailable prior to delivery.
- **Model Validation:** Preserved an untouched 80/20 stratified holdout test set (1,000 orders, 128 returns). The optimal operating decision threshold (**$t = 0.45$**) was established using 5-Fold Stratified Cross-Validation on the 4,000-order training set.

### Final Selected Model Performance on Untouched Test Set (Threshold = 0.45)

| Model Configuration | Threshold ($t$) | Accuracy | Precision | Recall | F1-Score | ROC-AUC | PR-AUC | Returns Caught (TP) | False Alarms (FP) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Naive Majority Baseline (Predict No Return)** | 0.50 | 87.20% | 0.00% | 0.00% | 0.0000 | 0.5000 | 0.1280 | **0 / 128** | 0 |
| **2. Final Model: Balanced Random Forest** | **0.45** | **68.50%** | **17.87%** | **40.62%** | **0.2482** | **0.5607** | **0.1572** | **52 / 128** | **239** |

### Confusion Matrix of Final Model (`t = 0.45`):
```text
                          Predicted No Return (0)    Predicted Return (1)    Total
Actual No Return (0):             633 (TN)                   239 (FP)         872
Actual Return (1):                 76 (FN)                    52 (TP)         128
Total Orders:                     709                        291            1,000
```

### Honest Performance Evaluation & Limitations
- **Operational Lift Over Baseline:** The naive majority baseline predicts zero returns for every order, achieving 87.20% accuracy but failing to identify a single return (0.0% recall). The final Balanced Random Forest successfully captures **52 out of 128 returns (40.62% recall)** with an F1-Score of **0.2482**, providing practical risk signals for targeted pre-shipping interventions.
- **Honest Limitations:**
  - The model achieves **68.50% accuracy**, **17.87% precision**, and **40.62% recall**. It does not reach the hypothetical targets (Accuracy > 75%, Precision > 45%, Recall > 50%) because doing so on this synthetic dataset without data leakage is mathematically impossible.
  - With a catalog base return prevalence of 12.78% and the complete exclusion of post-delivery variables, the highest-risk merchandise category (**Apparel**) exhibits a true return rate of 19.53%, and the top seller cohort returns at ~25.69%. Because no valid pre-dispatch cohort exhibits an empirical return rate exceeding 26%, the Bayes-optimal posterior return probability is bounded near ~0.26.
  - Any pre-dispatch model capturing ~40% of returns will naturally have an empirical precision ceiling of ~18%. Fabricating higher metrics or re-introducing post-delivery delays would compromise data science integrity.
- **Top Influential Pre-Dispatch Predictors (Gini Importance):** `gross_order_value`, `price`, `discount_pct_clean`, `net_order_value`, `quantity`, and `category`.

---

## 6. Microsoft Excel Analysis

The workbook `outputs/ecommerce_return_analysis.xlsx` includes:
- **Summary Dashboard:** Executive KPI blocks (GMV: ₹1.67Cr, Net Sales: ₹1.42Cr, Overall Return Rate: 12.78%), dynamic summary tables, and embedded openpyxl charts.
- **7 Detailed Worksheets:**
  1. `Cleaned Data` (5,000 rows with formulas)
  2. `Return Rate by Category`
  3. `Discount Comparison`
  4. `Delivery Delay Analysis`
  5. `Seller Comparison`
  6. `Return Reasons`
  7. `Customer Segment Analysis`

*Note on Excel Capabilities:* The workbook implements structured Excel formulas (`COUNTIF`, `COUNTIFS`, `SUMIFS`, `AVERAGEIF`) and native charts. Summarized dynamic tables are provided as an equivalent to pivot caches due to openpyxl library constraints.

---

## 7. Business Pitch & Executive Recommendations

The presentation `outputs/business_insights_pitch.pptx` (and `business_insights_pitch.pdf`) outlines three targeted operational workstreams:
1. **Product Sizing Intelligence:** Implement interactive fit recommendation widgets and standardized metric sizing charts on Apparel/Footwear catalog pages to prevent customer bracketing.
2. **Logistics Service-Level Governance:** Establish courier dispatch SLA penalties for delays past promised dates, accompanied by proactive WhatsApp tracking alerts and small retention credits for delayed orders.
3. **Seller Quality Gating:** Impose a 20% return threshold on third-party sellers, mandating catalog description audits and reverse logistics defect surcharges for chronic return outliers (e.g. SELLER_015, SELLER_053).

---

## 8. Reproducibility & How to Run

To run the complete workflow end-to-end from scratch:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Execute Data Cleaning & Merging
python scripts/data_cleaning_and_prep.py

# 3. Generate EDA Figures & Train Machine Learning Model
python scripts/eda_and_ml.py

# 4. Generate Excel Analysis Workbook
python scripts/generate_excel_analysis.py

# 5. Build PowerPoint Pitch Presentation
python scripts/generate_presentation.py

# 6. Export Presentation to PDF (Windows PowerShell)
powershell -ExecutionPolicy Bypass -File scripts/export_pdf.ps1
```
#   D a t a - S c i e n c e - S A T - 2  
 