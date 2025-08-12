# 🗃️ SQL Server Data Warehouse Project – Customer & Product Details

This project demonstrates the design and implementation of a **Data Warehouse** in **SQL Server** for storing and analyzing **customer and product-related data**.  
It follows a **multi-layer architecture (bronze, silver, gold)** and showcases how to load, clean, and prepare data for analytics.

---

## 📌 Overview
The goal of this project is to simulate a real-world **customer and product data warehouse** using **Excel as the source data**.  
The process includes:
- Creating a `DataWarehouse` database
- Defining **bronze, silver, and gold** schemas
- Loading data from Excel (via CSV export) into SQL Server
- Cleaning and standardizing data
- Building **dimension** and **fact** views for reporting

---

## 🏢 Domain
**Domain**: Customer and Product Management  
Tracks:
- Customer details (CRM and ERP sources)
- Product details (category, pricing, attributes)
- Sales transactions

---

## 🧰 Tools & Technologies
- **SQL Server Management Studio (SSMS)** – Database creation and query execution
- **SQL Server** – Data storage and processing
- **Excel** – Source data
- **Draw.io** – Schema and architecture diagrams
- **BULK INSERT** – Fast data loading

---

## 📥 Data Sources
Data originates from **Excel files**, exported as `.csv` for SQL Server ingestion:
- **CRM Data** – Customer and product info from CRM system
- **ERP Data** – Customer, location, and product category details from ERP system
- **Sales Data** – Transaction-level sales details

---

## 🏗️ Schema & Tables

### 1. **Bronze Layer** – Raw/Staging Data
Holds unprocessed data as imported from source systems:
- `bronze.crm_cust_info`
- `bronze.crm_prd_info`
- `bronze.sales_details`
- `bronze.erp_cust_az12`
- `bronze.erp_loc_a101`
- `bronze.erp_px_cat_g1v2`

### 2. **Silver Layer** – Cleaned Data
Same table structure as bronze but data is cleaned, standardized, and transformed:
- `silver.crm_cust_info`
- `silver.crm_prd_info`
- `silver.sales_details`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`
- `silver.erp_px_cat_g1v2`

### 3. **Gold Layer** – Analytics-Ready Data
Contains **views** designed for reporting and analysis:
- `gold.dim_products`
- `gold.dim_customers`
- `gold.fact_sales`

---

## 🔄 ETL Process

1. **Extract**  
   - Export Excel files as CSV  
   - Load into bronze tables using `BULK INSERT`

2. **Transform**  
   - Clean and standardize data (data type conversion, remove duplicates, unify formats)  
   - Load into silver tables

3. **Load (Analytics)**  
   - Build `gold` layer views by joining and aggregating data from silver tables

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  


## 📂 Repository Structure
```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram
│   ├── data_models.drawio              # Draw.io file for data models (star schema)
|   ├── data_integration.drawio              # Draw.io file for data integration
│   
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
```
---
