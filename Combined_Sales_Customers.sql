
--Cleaning Both Tables

-- For Sales_Orders
DELETE FROM Sales_Orders
WHERE OrderID NOT IN (
  SELECT MIN(OrderID)
  FROM Sales_Orders
  GROUP BY OrderID, CustomerID, OrderDate, Product, Quantity, UnitPrice, Region
);

-- For Customer_Info
DELETE FROM Customer_Info
WHERE CustomerID NOT IN (
  SELECT MIN(CustomerID)
  FROM Customer_Info
  GROUP BY CustomerID, CustomerName, Email, JoinDate, Country, City, Segment
);

--Setting Quantity 1 where Quantity is null

UPDATE Sales_Orders
SET Quantity = 1
WHERE Quantity IS NULL;

--Updating Unit Price 1 where its null

UPDATE Sales_Orders
SET UnitPrice = 0.00
WHERE UnitPrice IS NULL;

--Updating Unkown as region where its null

UPDATE Sales_Orders
SET Region = 'Unknown'
WHERE Region IS NULL OR LTRIM(RTRIM(Region)) = '';

--Updating CustomerID -1 where its null

UPDATE Sales_Orders
SET CustomerID = -1
WHERE CustomerID IS NULL;

--Setting Email Unknown where its null

UPDATE Customer_Info
SET Email = 'unknown@email.com'
WHERE Email IS NULL;

--Setting Country Unknown where its null

UPDATE Customer_Info
SET Country = 'Unknown'
WHERE Country IS NULL OR LTRIM(RTRIM(Country)) = '';

--Setting Segment Unknown where its null

UPDATE Customer_Info
SET Segment = 'Unknown'
WHERE Segment IS NULL OR LTRIM(RTRIM(Segment)) = '';

---Standardize text case, trim extra spaces

UPDATE Sales_Orders
SET
    Region = UPPER(LTRIM(RTRIM(Region))),
    Product = LTRIM(RTRIM(Product));

UPDATE Customer_Info
SET
    CustomerName = LTRIM(RTRIM(CustomerName)),
    Country = UPPER(LTRIM(RTRIM(Country))),
    Segment = LOWER(LTRIM(RTRIM(Segment)));

-- Add new columns for clean dates
ALTER TABLE Sales_Orders ADD CleanOrderDate DATE;
ALTER TABLE Customer_Info ADD CleanJoinDate DATE;

-- Update date columns with clean, standardized DATE values.
-- Using TRY_CONVERT instead of CONVERT prevents errors when encountering invalid date formats:
--   - If OrderDate/JoinDate is a valid date, it is converted to DATE using style 120 (YYYY-MM-DD).
--   - If the value is invalid, TRY_CONVERT returns NULL instead of raising an error.
-- This ensures the update runs safely even with messy or inconsistent source data.

UPDATE Sales_Orders
SET CleanOrderDate = TRY_CONVERT(DATE, OrderDate, 120);

UPDATE Customer_Info
SET CleanJoinDate = TRY_CONVERT(DATE, JoinDate, 120);


--Fix category typos

UPDATE Customer_Info
SET Segment =
  CASE 
    WHEN Segment IN ('retal', 'retail', 'retail ') THEN 'Retail'
    WHEN Segment LIKE '%corporate%' THEN 'Corporate'
    ELSE Segment
  END;

--
--Combined both the table into one 
SELECT 
    s.OrderID, 
    c.CustomerName, 
    s.Product, 
    s.Quantity, 
    s.UnitPrice, 
    (s.Quantity * s.UnitPrice) AS TotalSales, 
    c.Country, 
    s.Region, 
    s.CleanOrderDate
INTO Combined_Sales_Customers
FROM Sales_Orders s
INNER JOIN Customer_Info c ON s.CustomerID = c.CustomerID;




