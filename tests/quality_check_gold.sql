use DataWarehouse

-- when we combing two tables using joing if there any 
-- data was diapslying the duplcation records we have to see like this
select cst_id, count(*) from(
select 
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date,
ca.bdate,
ca.gen,
la.cntry
from Silver.crm_cust_info ci
left join Silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join Silver.erp_loc_a101 la
on ci.cst_key=la.cid
)t 
group by cst_id
having count(*)> 1


-- take the gender reference from master tabel of the crm and manupliate the erp gender column vice verse	
select distinct
cst_gndr,
ca.gen,
case when ci.cst_gndr	!= 'n/a' then ci.cst_gndr -- crm is the master for gender inforamtion
		else coalesce(ca.gen,'n/a')
end as new_gen
from Silver.crm_cust_info ci
left join Silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join Silver.erp_loc_a101 la
on ci.cst_key=la.cid
order by 1,2;


/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
