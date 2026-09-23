# Amazon India E-Commerce Sales Performance Analysis

## Executive Overview
This end-to-end business intelligence project analyzes retail operations and fulfillment efficiency for apparel sales on Amazon India. Using a Star Schema data architecture and interactive Power BI dashboards, the project diagnoses sales trends, product category contributions, and shipping fulfillment bottlenecks across ~14,000 orders totaling **₹7.86M** in gross revenue.

---

## Dashboard Preview
*<img width="1213" height="687" alt="Screenshot 2026-09-23 171206" src="https://github.com/user-attachments/assets/3f1a455c-f854-4d56-9aa8-92e9260557e3" />
*

---

## Core Business Problem
1. **Catalog Performance Disparity:** Determining which apparel categories drive the majority of volume versus those tying up working capital with poor stock turn.
2. **Fulfillment Bottlenecks:** Evaluating pre-dispatch cancellation rates (~8.5%) and return leakage (~3.8%) across delivery tiers.
3. **Single-Item Basket Bottleneck:** Average Order Value (AOV) is constrained at **₹561**, driven by a 1.01 units-per-order average.

---

## Architecture & Data Modeling

### 1. Data Cleaning & Transformation (MySQL)
* Standardized casing and whitespace for text fields (`Category`, `Status`, `ship-city`, `ship-state`).
* Handled unassigned logistics records by categorizing blank couriers on cancelled purchases to `'Not Dispatched'`.
* Converted raw string dates (`MM-DD-YY`) into native SQL `DATE` format using `STR_TO_DATE()`.

### 2. Star Schema Design
The data model uses a Star Schema structure optimized for dimensional filtering:
* **`fact_sales`**: Stores transaction-level operational data (`order_id`, `quantity`, `revenue`, `status`, keys).
* **`dim_product`**: Contains product categories, design styles, and SKU hierarchies.
* **`dim_geography`**: State, city, and postal code fulfillment routing.
* **`dim_date`**: Calendar hierarchies (Year, Quarter, Month, Weekday).

---

## Key Metrics & DAX Measures

| Metric | Value | Business Impact |
| :--- | :--- | :--- |
| **Gross Recorded Revenue** | **₹7.86M** | Baseline top-line commercial scale |
| **Total Orders** | **14.0K** | Operational throughput |
| **Average Order Value (AOV)** | **₹561.38** | Standard basket size for women's apparel |
| **Delivery Completion Rate** | **77.4%** | Successfully delivered/in-transit volume |
| **Cancellation & Return Rate** | **12.3%** | Combined operational and customer margin leakage |

### Key DAX Implementations:
```dax
Total Revenue = 
CALCULATE(
    SUM(fact_sales[revenue]),
    fact_sales[is_cancelled] = 0
)

AOV = 
DIVIDE([Total Revenue], [Total Orders], 0)
