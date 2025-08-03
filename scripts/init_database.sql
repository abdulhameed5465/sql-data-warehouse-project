-- ================================================
-- 🗃️ DATA WAREHOUSE DATABASE INITIALIZATION SCRIPT
-- Description: Drops existing DataWarehouse DB if present,
-- creates a new one, and sets up schema layers (bronze, silver, gold)
-- ================================================

-- ================================================
-- Connect to the master database
-- ================================================
USE master;
GO

/* ================================================
 Drop existing 'DataWarehouse' database if it exists
    
    WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
 ================================================ */
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- ================================================
-- Create a new 'DataWarehouse' database
-- ================================================
CREATE DATABASE DataWarehouse;
GO

-- ================================================
-- Switch to 'DataWarehouse' database context
-- ================================================
USE DataWarehouse;
GO

-- ================================================
-- Create schema layers for data warehousing
-- Bronze
-- Silver
-- Gold
-- ================================================
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
