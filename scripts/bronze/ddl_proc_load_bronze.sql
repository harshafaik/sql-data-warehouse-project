-- filename: proc_load_bronze.sql

-- Section 1: Schema Management
-- -----------------------------------------------------------------------------
-- Ensures the 'bronze' schema exists. If it already exists, this command does
-- nothing, preventing errors during repeated runs. This is crucial for a
-- plug-and-play setup.
CREATE SCHEMA IF NOT EXISTS bronze;


-- Section 2: Table Creation (DDL - Data Definition Language)
-- -----------------------------------------------------------------------------
-- These statements create the tables in the 'bronze' schema.
-- Using CREATE TABLE IF NOT EXISTS makes the script idempotent,
-- meaning it can be run multiple times without error if tables already exist.
--
-- !!! IMPORTANT !!!
-- You must review and update the column definitions (names and data types)
-- for all tables except 'crm_cust_info' to accurately match your CSV files.
-- Placeholder columns are provided as examples.


-- 1. Create crm_cust_info table
--    Schema inferred from previous 'head' output
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
    cst_id             INTEGER,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(100),
    cst_lastname       VARCHAR(100),
    cst_marital_status CHAR(1),
    cst_gndr           CHAR(1),
    cst_create_date    DATE
);

-- 2. Create crm_prd_info table
--    !!! PLACEHOLDER COLUMNS - UPDATE ACCORDING TO YOUR 'prd_info.csv' HEADER !!!
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
     prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt TIMESTAMP,  -- Changed DATETIME to TIMESTAMP for PostgreSQL
    prd_end_dt   TIMESTAMP   -- Changed DATETIME to TIMESTAMP for PostgreSQL
    -- Add more columns as per your prd_info.csv file
);

-- 3. Create crm_sales_details table
--    !!! PLACEHOLDER COLUMNS - UPDATE ACCORDING TO YOUR 'sales_details.csv' HEADER !!!
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details (
     sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
    -- Add more columns as per your sales_details.csv file
);

-- 4. Create erp_cust_az12 table
--    !!! PLACEHOLDER COLUMNS - UPDATE ACCORDING TO YOUR 'CUST_AZ12.csv' HEADER !!!
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
    -- Add more columns as per your CUST_AZ12.csv file
);

-- 5. Create erp_loc_a101 table
--    !!! PLACEHOLDER COLUMNS - UPDATE ACCORDING TO YOUR 'LOC_A101.csv' HEADER !!!
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
    -- Add more columns as per your LOC_A101.csv file
);

-- 6. Create erp_px_cat_g1v2 table
--    !!! PLACEHOLDER COLUMNS - UPDATE ACCORDING TO YOUR 'PX_CAT_G1V2.csv' HEADER !!!
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
    -- Add more columns as per your PX_CAT_G1V2.csv file
);


-- Section 3: Data Loading into Bronze Layer Tables (DML - Data Manipulation Language)
-- -----------------------------------------------------------------------------
-- This section truncates existing data in each bronze table and then loads
-- fresh data from the corresponding CSV files using the psql \copy meta-command.
--
-- \copy is a psql-specific command that runs on the client side, reading the
-- file from the local filesystem where psql is executed and streaming it to the
-- PostgreSQL server. This avoids server-side file access issues.
--
-- Paths are relative to the directory from where the 'psql -f' command is run.
-- Ensure you run psql from the project root:
-- `cd /home/harshafaik/Projects/sql-data-warehouse-project/`
-- then: `psql -U your_username -d your_database_name -f sql/proc_load_bronze.sql`


-- 1. Load crm_cust_info table
TRUNCATE TABLE bronze.crm_cust_info;
\copy bronze.crm_cust_info FROM 'datasets/source_crm/cust_info.csv' DELIMITER ',' CSV HEADER;


-- 2. Load crm_prd_info table
TRUNCATE TABLE bronze.crm_prod_info;
\copy bronze.crm_prd_info FROM 'datasets/source_crm/prd_info.csv' DELIMITER ',' CSV HEADER;


-- 3. Load crm_sales_details table
TRUNCATE TABLE bronze.crm_sales_details;
\copy bronze.crm_sales_details FROM 'datasets/source_crm/sales_details.csv' DELIMITER ',' CSV HEADER;


-- 4. Load erp_cust_az12 table
TRUNCATE TABLE bronze.erp_cust_az12;
\copy bronze.erp_cust_az12 FROM 'datasets/source_erp/CUST_AZ12.csv' DELIMITER ',' CSV HEADER;


-- 5. Load erp_loc_a101 table
TRUNCATE TABLE bronze.erp_loc_a101;
\copy bronze.erp_loc_a101 FROM 'datasets/source_erp/LOC_A101.csv' DELIMITER ',' CSV HEADER;


-- 6. Load erp_px_cat_g1v2 table
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
\copy bronze.erp_px_cat_g1v2 FROM 'datasets/source_erp/PX_CAT_G1V2.csv' DELIMITER ',' CSV HEADER;


-- Section 4: Post-Load Operations (Best Practices)
-- -----------------------------------------------------------------------------
-- After loading large amounts of data, it's good practice to run VACUUM ANALYZE.
-- This updates table statistics, which helps the PostgreSQL query planner make
-- more efficient decisions for future queries on these tables.
VACUUM ANALYZE bronze.crm_cust_info;
VACUUM ANALYZE bronze.crm_prod_info;
VACUUM ANALYZE bronze.crm_sales_details;
VACUUM ANALYZE bronze.erp_cust_az12;
VACUUM ANALYZE bronze.erp_loc_a101;
VACUUM ANALYZE bronze.erp_px_cat_g1v2;

-- Optional: Set search_path back to default if desired, or remove this line
-- if you prefer the custom search_path to persist for the session.
-- SET search_path TO public;
