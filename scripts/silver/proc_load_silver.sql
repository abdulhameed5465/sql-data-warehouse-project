/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/


CREATE OR ALTER	PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time=GETDATE()
		print '-----------------------------'
		print '----loading silver layer-----'
		print '-----------------------------'
		--1
		print'=============================='
		print'======loading crm tables======'
		print'=============================='
		SET @start_time=GETDATE()
		print 'truncating table silver.crm_cust_info'
		TRUNCATE TABLE silver.crm_cust_info
		print 'inserting data into silver.crm_cust_info'
		insert into silver.crm_cust_info (
			cust_id,
			cust_key,
			cust_firstname,
			cust_lastname,
			cust_material_status,
			cust_gndr,
			cust_create_date
		)
		select 
		cust_id,
		cust_key,
		trim(cust_firstname) as cust_firstname,
		trim(cust_lastname)as cust_lastname,
		CASE WHEN upper(trim(cust_material_status)) = 's' THEN 'Single'
			 WHEN upper(trim(cust_material_status)) = 'M' THEN 'Married'
			 ELSE 'n/a'
		END cust_material_status,
		CASE WHEN upper(trim(cust_gndr)) = 'F' THEN 'Female'
			 WHEN upper(trim(cust_gndr)) = 'M' THEN 'Male'
			 ELSE 'n/a'
		END cust_gndr,
		cust_create_date
		from(
		select
		*,
		ROW_NUMBER() over (partition by cust_id order by cust_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cust_id is not null
		)t 
		where flag_last = 1
		SET @end_time=GETDATE()
		print'loading duration'+cast(datediff(second,@start_time,@end_time)
		AS VARCHAR)+'seconds'
	
		--2
		print 'truncating table silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info
		print 'inserting data into silver.crm_prd_info'
		SET @start_time=GETDATE()
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,	
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			  prd_id,
			  replace(SUBSTRING(prd_key,1,5),'-','_') cat_id,
			  SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
			  prd_nm,
			  isnull(prd_cost, 0) as prd_cost,
			  CASE UPPER(TRIM(prd_line))
				   WHEN  'M' THEN 'Mountain'
				   WHEN  'S' THEN 'Other Sales'
				   WHEN  'R' THEN 'Roads'
				   WHEN  'T' THEN 'Touring'
				   ELSE 'n/a'
			  END prd_line,
			  CAST(prd_start_dt AS DATE) prd_start_dt,
			  DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) as prd_end_dt
		FROM bronze.crm_prd_info
	
		SET @end_time=GETDATE()
		print'loading duration'+cast(datediff(second,@start_time,@end_time)
		AS VARCHAR)+'seconds'
	
		--3
		print'================================'
		print'======loading erp tables========'
		print'================================'
		print 'truncating table silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details
		print 'inserting data into silver.crm_sales_details'
		SET @start_time=GETDATE()
		INSERT INTO silver.crm_sales_details(
			sls_ord_num ,
			sls_prd_num ,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity ,
			sls_price
		)
		select 
			sls_ord_num,
			sls_prd_num,
			sls_cust_id,
			--ORDER DATE
			CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			--SHIPPING DATE 
			CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			--DUE DATE
			CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			--SALES
			CASE WHEN sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity*sls_price
				THEN sls_quantity*abs(sls_price)
				else sls_sales
			end as sls_sales,
			sls_quantity,
			--PRICE
			CASE WHEN sls_price is null or sls_price <=0 
				then sls_sales / nullif(sls_quantity,0)
				else sls_price
			end AS sls_price
		from bronze.crm_sales_details

	
		SET @end_time=GETDATE()
		print'loading duration'+cast(datediff(second,@start_time,@end_time)
		AS VARCHAR)+'seconds'
	
	
		--4
		print 'truncating table silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12
		print 'inserting data into silver.erp_cust_az12'
		SET @start_time=GETDATE()
		insert into silver.erp_cust_az12(cid,bdate,gen)
		select 
			case 
				when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
				Else cid
			end  as cid,
			case 
				when bdate > GETDATE() then null
				else bdate
			end as bdate,
			case 
				when UPPER(trim(gen)) IN ('F','FEMALE') then 'Female'
				when UPPER(trim(gen)) IN ('M','MALE') then 'Male'
				else 'n/a'
			end as gen
		from bronze.erp_cust_az12

	
		SET @end_time=GETDATE()
		print'loading duration'+cast(datediff(second,@start_time,@end_time)
		AS VARCHAR)+'seconds'

		--5
		print 'truncating table silver.erp_ppx_cat_g1v2'
		TRUNCATE TABLE silver.erp_ppx_cat_g1v2
		print 'inserting data into silver.erp_ppx_cat_g1v2'
		SET @start_time=GETDATE()
		insert into silver.erp_ppx_cat_g1v2(id,cat,subcat,maintenance)

		select 
		id,
		cat,
		subcat,
		maintenance 
		from bronze.erp_ppx_cat_g1v2
	
		SET @end_time=GETDATE()
		print'loading duration'+cast(datediff(second,@start_time,@end_time)
		AS VARCHAR)+'seconds'

		--6
		print 'truncating table silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101
		print 'inserting data into silver.erp_loc_a101'
		SET @start_time=GETDATE()
		insert into silver.erp_loc_a101(cid,cntry)
		select 
			replace(cid,'-',''),
			case when trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) in ('USA','US') THEN 'United States'
			when trim(cntry) = '' or cntry is null then 'n/a'
			else trim(cntry)
			end as cntry
		from bronze.erp_loc_a101
	
		SET @end_time=GETDATE()
		print'loading duration'+cast(datediff(second,@start_time,@end_time)
		AS VARCHAR)+'seconds'

		SET @batch_end_time=GETDATE()
		print'loading time for silver layer'+cast(datediff(second,
		@batch_start_time,@batch_end_time) AS VARCHAR)+'Seconds'
	END TRY

	BEGIN CATCH
		print'error occured during loading silver layer';
		print'error message'+error_message();
		print'error line'+cast(error_line() as varchar);
	END CATCH
END
