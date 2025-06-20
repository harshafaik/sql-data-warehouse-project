-- Documentation for Gold Layer Views

-- 1. View: gold.dim_customers
-- Description: This view creates a dimension table for customer information in the gold layer.
--              It consolidates customer data from various silver layer tables, including CRM
--              customer information, ERP customer demographics, and ERP location details.
-- Source Tables:
--   - silver.crm_cust_info: Contains core CRM customer details.
--   - silver.erp_cust_az12: Provides additional ERP customer information, including gender and birthdate.
--   - silver.erp_loc_a101: Contains ERP location information, specifically country.
-- Columns:
--   - customer_key: A unique surrogate key for each customer, generated using ROW_NUMBER().
--   - customer_id: The original customer ID from crm_cust_info.
--   - customer_number: The customer key from crm_cust_info, used for joining with ERP tables.
--   - first_name: The first name of the customer.
--   - last_name: The last name of the customer.
--   - country: The country of the customer, sourced from ERP location data.
--   - marital_status: The marital status of the customer.
--   - gender: The gender of the customer. It prioritizes the gender from crm_cust_info;
--                                if 'n/a', it defaults to the gender from erp_cust_az12, otherwise 'n/a'.
--   - birthdate: The birthdate of the customer, sourced from erp_cust_az12.
--   - create_date: The date the customer record was created in CRM.
-- Relationships:
--   - Joined with silver.erp_cust_az12 on cst_key = eca.cid.
--   - Joined with silver.erp_loc_a101 on cst_key = ela.cid.
-- Transformation Logic:
--   - A surrogate key `customer_key` is generated using `ROW_NUMBER() OVER (ORDER BY cst_id)`.
--   - The `gender` column uses a `CASE WHEN` statement with `COALESCE` to handle missing or 'n/a' values,
--     prioritizing `cst_gndr` and falling back to `eca.gen`.

-- 2. View: gold.dim_products
-- Description: This view creates a dimension table for product information in the gold layer.
--              It combines product details from CRM product information with ERP product
--              category and maintenance details.
-- Source Tables:
--   - silver.crm_prd_info: Contains core CRM product details.
--   - silver.erp_px_cat_g1v2: Provides ERP product category, subcategory, and maintenance information.
-- Columns:
--   - product_key: A unique surrogate key for each product, generated using ROW_NUMBER().
--   - product_id: The original product ID from crm_prd_info.
--   - product_number: The product key from crm_prd_info, used for joining.
--   - product_name: The name of the product.
--   - category_id: The category ID from crm_prd_info.
--   - category: The product category, sourced from ERP product category data.
--   - subcategory: The product subcategory, sourced from ERP product category data.
--   - maintenance: Maintenance information for the product, sourced from ERP.
--   - product_cost: The cost of the product.
--   - product_line: The product line.
--   - start_date: The start date of the product's availability.
-- Relationships:
--   - Joined with silver.erp_px_cat_g1v2 on cpi.cat_id = epcgv.id.
-- Filter:
--   - `WHERE prd_end_dt IS NULL`: Only active products (those without an end date) are included.
-- Transformation Logic:
--   - A surrogate key `product_key` is generated using `ROW_NUMBER() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key)`.

-- 3. View: gold.fact_sales
-- Description: This view creates a fact table for sales transactions in the gold layer.
--              It combines sales details from the CRM sales details table with surrogate keys
--              from the `gold.dim_products` and `gold.dim_customers` dimension tables.
-- Source Tables:
--   - silver.crm_sales_details: Contains detailed sales transaction information.
--   - gold.dim_products: Provides the `product_key` for products involved in sales.
--   - gold.dim_customers: Provides the `customer_key` for customers involved in sales.
-- Columns:
--   - order_number: The sales order number.
--   - product_key: The surrogate key for the product involved in the sale, linked to `gold.dim_products`.
--   - customer_key: The surrogate key for the customer involved in the sale, linked to `gold.dim_customers`.
--   - order_date: The date the sales order was placed.
--   - shipping_date: The date the order was shipped.
--   - due_date: The due date for the sales order.
--   - sales_amount: The total sales amount for the transaction.
--   - quantity: The quantity of products sold in the transaction.
--   - price: The price per unit of the product sold.
-- Relationships:
--   - Joined with `gold.dim_products` on csd.sls_prd_key = dp.product_number to get `product_key`.
--   - Joined with `gold.dim_customers` on csd.sls_cust_id = dc.customer_id to get `customer_key`.
-- Transformation Logic:
--   - This view primarily serves to link sales transaction details with the appropriate dimension keys.

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT row_number() OVER (ORDER BY cst_id) AS customer_key,
cst_id AS customer_id, 
cst_key AS customer_number, 
cst_firstname AS first_name, 
cst_lastname AS last_name, 
ela.cntry AS country,
cst_marital_status AS marital_status,
CASE WHEN cst_gndr != 'n/a' THEN cst_gndr
ELSE coalesce(eca.gen, 'n/a')
END AS gender,
eca.bdate AS birthdate, 
cst_create_date AS create_date
FROM silver.crm_cust_info
LEFT JOIN silver.erp_cust_az12 eca
ON cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela 
ON cst_key = ela.cid;

GO

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT row_number() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
cpi.prd_id AS product_id, 
cpi.prd_key AS product_number,
cpi.prd_nm AS product_name,
cpi.cat_id AS category_id,
epcgv.cat AS category,
epcgv.subcat AS subcategory,
epcgv.maintenance AS maintenance,
cpi.prd_cost AS product_cost, 
cpi.prd_line AS product_line, 
cpi.prd_start_dt AS start_date
FROM silver.crm_prd_info cpi 
LEFT JOIN silver.erp_px_cat_g1v2 epcgv 
ON cpi.cat_id = epcgv.id
WHERE prd_end_dt IS NULL;

GO

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT csd.sls_ord_num AS order_number, 
dp.product_key,
dc.customer_key, 
csd.sls_order_dt AS order_date, 
csd.sls_ship_dt AS shipping_date, 
csd.sls_due_dt AS due_date, 
csd.sls_sales AS sales_amount, 
csd.sls_quantity AS quantity, 
csd.sls_price AS price
FROM silver.crm_sales_details csd
LEFT JOIN gold.dim_products dp 
ON csd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers dc 
ON csd.sls_cust_id = dc.customer_id;

GO