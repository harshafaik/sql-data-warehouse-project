# Data Warehouse & ETL Pipeline 🚀

This project demonstrates a comprehensive data warehousing and analytics solution, encompassing the construction of a data warehouse and the derivation of actionable insights. It adheres to industry best practices in data engineering and analytics.

The project employs the **Medallion Architecture**, structured into three layers:

1. **Bronze Layer**: Stores **raw data** ingested from source systems (e.g., CSV files) into a **SQL Server Database**.
2. **Silver Layer**: Data **cleansing, standardization, and normalization** to prepare for analysis.
3. **Gold Layer**: Contains **business-ready** data modeled into a **star schema** for reporting and analytics.

## 🏗️ Project Components

- **Data Architecture** – Designing a modern **data warehouse** using **Medallion Architecture**.  
- **ETL Pipelines** – **Extracting, transforming, and loading (ETL)** data from source systems into the warehouse.  
- **Data Modeling** – Developing **fact** and **dimension** tables optimized for analytical queries.  
- **Analytics & Reporting** – Creating **SQL-based reports and dashboards** to generate actionable insights.


## 🛠️ Tech Stack
- **PostgreSQL** (Database & Data Warehouse)
- **DBeaver** (SQL Development)
- **Python / Pandas** (Data Transformation)
- **Databricks (Future Upgrade)** (For scaling ETL processes)
- **Power BI / Tableau** (Dashboard Visualization)


## 📂 Project Structure

```
SQL-DATA-WAREHOUSE-PROD/
├── datasets/                # Source data files
│   ├── source_crm/         # CRM system data extracts
│   └── source_erp/         # ERP system data extracts
├── images/                  # Project-related images and diagrams
├── legacy/                  # Legacy SQL scripts (for reference/migration)
│   ├── ddl_bronze.sql       # DDL for Bronze layer (legacy)
│   └── proc_load_bronze.sql # ETL procedure for Bronze layer (legacy)
├── scripts/                 # Main ETL and DDL scripts
│   ├── bronze/              # Scripts for Bronze (raw) layer
│   │   └── ddl_proc_load_bronze.sql
│   ├── silver/              # Scripts for Silver (cleansed) layer
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   └── gold/                # Scripts for Gold (business) layer
├── tests/                   # Unit and integration tests
├── .gitignore               # Git ignore rules
├── LICENSE                  # Project license
└── README.md                # Project documentation
```
