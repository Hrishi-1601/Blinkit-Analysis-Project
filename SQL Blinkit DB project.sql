-- Creating the BlinkitDB Database
CREATE DATABASE BlinkitDB;
GO

-- Selecting the BlinkitDB Database
USE BlinkitDB;
GO
'''
-- Creating Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Salary DECIMAL(10,2),
    Location NVARCHAR(100),
    CustomerType NVARCHAR(50)
);
GO

-- Inserting 5000 Customers
INSERT INTO Customers (Name, Salary, Location, CustomerType)
SELECT 
    CONCAT('Customer_', ROW_NUMBER() OVER (ORDER BY NEWID())),
    ROUND(RAND() * (200000 - 30000) + 30000, 2),
    CASE WHEN RAND() > 0.5 THEN 'Metro' ELSE 'Tier-2' END,
    CASE 
        WHEN RAND() < 0.01 THEN 'Premium'  -- Top 1% High Salary
        ELSE 'Regular' 
    END
FROM master.dbo.spt_values;
GO


-- Creating Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderValue DECIMAL(10,2),
    DeliveryTime INT,  -- in minutes
    ProductCategory NVARCHAR(50),
    PriceHikeApplied BIT,
    DeliveryFee DECIMAL(10,2),
    TotalRevenue DECIMAL(10,2)  -- No direct computation here
);
GO

-- Inserting 5000 Orders
INSERT INTO Orders (CustomerID, OrderValue, DeliveryTime, ProductCategory, PriceHikeApplied, DeliveryFee)
SELECT 
    c.CustomerID,
    ROUND(RAND() * (5000 - 200) + 200, 2) AS OrderValue,
    CAST(RAND() * (60 - 10) + 10 AS INT) AS DeliveryTime, -- Random 10 to 60 mins
    CASE WHEN RAND() > 0.5 THEN 'Groceries' ELSE 'Electronics' END,
    CASE WHEN c.CustomerType = 'Premium' THEN 1 ELSE 0 END, -- Price hike for Premium customers
    ROUND(RAND() * (100 - 20) + 20, 2) AS DeliveryFee -- Random delivery fee
FROM Customers c
ORDER BY NEWID();
GO


UPDATE Orders 
SET TotalRevenue = OrderValue + DeliveryFee;
GO


-- Creating Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Category NVARCHAR(50),
    BasePrice DECIMAL(10,2),
    FinalPrice DECIMAL(10,2),
    Discount DECIMAL(10,2),
    DemandLevel NVARCHAR(50)
);
GO

-- Inserting 5000 Products
INSERT INTO Products (Category, BasePrice, FinalPrice, Discount, DemandLevel)
SELECT TOP 5000
    CASE WHEN RAND() > 0.5 THEN 'Groceries' ELSE 'Electronics' END AS Category,
    ROUND(RAND() * (5000 - 200) + 200, 2) AS BasePrice, -- Generates BasePrice
    ROUND((RAND() * (5000 - 200) + 200) * (1 + RAND() * 0.2), 2) AS FinalPrice, -- FinalPrice with up to 20% markup
    ROUND(RAND() * 15, 2) AS Discount, -- Discount applied
    CASE 
        WHEN RAND() < 0.3 THEN 'High' 
        WHEN RAND() < 0.6 THEN 'Medium' 
        ELSE 'Low' 
    END AS DemandLevel -- Demand categorization
FROM master.dbo.spt_values
WHERE type = 'P';
GO


-- Creating Revenue Streams Table
CREATE TABLE RevenueStreams (
    RevenueID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    RevenueType NVARCHAR(50),
    Amount DECIMAL(10,2)
);
GO

-- Inserting Data into Revenue Streams (Ensuring OrderID exists)
INSERT INTO RevenueStreams (OrderID, RevenueType, Amount)
SELECT 
    o.OrderID, 
    CASE WHEN RAND() > 0.5 THEN 'Delivery Fee' ELSE 'Advertising' END,
    ROUND(RAND() * 500, 2)
FROM Orders o
ORDER BY NEWID();
GO


-- Creating Costs Table
CREATE TABLE Costs (
    CostID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    CostType NVARCHAR(50),
    Amount DECIMAL(10,2)
);
GO '''



-- Inserting Data into Costs Table (Ensuring OrderID exists)
INSERT INTO Costs (OrderID, CostType, Amount)
SELECT 
    o.OrderID, 
    CASE WHEN RAND() > 0.5 THEN 'Fixed' ELSE 'Variable' END,
    ROUND(RAND() * 300, 2)
FROM Orders o
ORDER BY NEWID();
GO


select * from RevenueStreams
select * from Costs
select * from Products
select * from Customers
select * from Orders

DROP TABLE IF EXISTS RevenueStreams;
DROP TABLE IF EXISTS Costs;
DROP TABLE IF EXISTS Orders;
GO

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),  -- Linking Orders to Products
    OrderValue DECIMAL(10,2),
    DeliveryTime INT,  -- in minutes
    ProductCategory NVARCHAR(50),
    PriceHikeApplied BIT,
    DeliveryFee DECIMAL(10,2),
    TotalRevenue DECIMAL(10,2)
);
GO

CREATE TABLE RevenueStreams (
    RevenueID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),  -- Now linked to Orders
    RevenueType NVARCHAR(50),
    Amount DECIMAL(10,2)
);
GO


CREATE TABLE Costs (
    CostID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),  -- Now linked to Orders
    CostType NVARCHAR(50),
    Amount DECIMAL(10,2)
);
GO



-- Insert Customers (Assuming Customer Data Exists)
INSERT INTO Customers (Name, Salary, Location, CustomerType)
SELECT 
    'Customer ' + CAST(ROW_NUMBER() OVER (ORDER BY NEWID()) AS NVARCHAR),
    ROUND(RAND() * (500000 - 50000) + 50000, 2),
    CASE WHEN RAND() > 0.5 THEN 'Metro' ELSE 'Tier-2' END,
    CASE WHEN RAND() > 0.8 THEN 'Premium' ELSE 'Regular' END
FROM master.dbo.spt_values WHERE type = 'P';

-- Insert Products
INSERT INTO Products (Category, BasePrice, FinalPrice, Discount, DemandLevel)
SELECT TOP 5000
    CASE WHEN RAND() > 0.5 THEN 'Groceries' ELSE 'Electronics' END,
    ROUND(RAND() * (5000 - 200) + 200, 2),
    ROUND((RAND() * (5000 - 200) + 200) * (1 + RAND() * 0.2), 2),
    ROUND(RAND() * 15, 2),
    CASE WHEN RAND() < 0.3 THEN 'High' WHEN RAND() < 0.6 THEN 'Medium' ELSE 'Low' END
FROM master.dbo.spt_values WHERE type = 'P';

-- Insert Orders (After Customers and Products Exist)
INSERT INTO Orders (CustomerID, ProductID, OrderValue, DeliveryTime, ProductCategory, PriceHikeApplied, DeliveryFee)
SELECT 
    c.CustomerID,
    p.ProductID,
    ROUND(RAND() * (5000 - 200) + 200, 2),
    CAST(RAND() * (60 - 10) + 10 AS INT),
    p.Category,
    CASE WHEN c.CustomerType = 'Premium' THEN 1 ELSE 0 END,
    ROUND(RAND() * (100 - 20) + 20, 2)
FROM Customers c
JOIN Products p ON p.ProductID % 10 = c.CustomerID % 10 
ORDER BY NEWID();

-- Update TotalRevenue
UPDATE Orders 
SET TotalRevenue = OrderValue + DeliveryFee;

-- Insert RevenueStreams (After Orders Exist)
INSERT INTO RevenueStreams (OrderID, RevenueType, Amount)
SELECT 
    o.OrderID,
    CASE WHEN RAND() > 0.5 THEN 'Delivery Fee' ELSE 'Advertising' END,
    ROUND(RAND() * (1000 - 100) + 100, 2)
FROM Orders o;

-- Insert Costs (After Orders Exist)
INSERT INTO Costs (OrderID, CostType, Amount)
SELECT 
    o.OrderID,
    CASE WHEN RAND() > 0.5 THEN 'Fixed' ELSE 'Variable' END,
    ROUND(RAND() * (500 - 50) + 50, 2)
FROM Orders o;


DROP TABLE IF EXISTS RevenueStreams;
DROP TABLE IF EXISTS Costs;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
GO

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Category NVARCHAR(50),
    BasePrice DECIMAL(10,2),
    FinalPrice DECIMAL(10,2),
    Discount DECIMAL(10,2),
    DemandLevel NVARCHAR(20)
);
GO


CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),  -- Establishing Correct Relationship
    OrderValue DECIMAL(10,2),
    DeliveryTime INT,
    ProductCategory NVARCHAR(50),
    PriceHikeApplied BIT,
    DeliveryFee DECIMAL(10,2),
    TotalRevenue DECIMAL(10,2)
);
GO



-- Revenue Streams Table
CREATE TABLE RevenueStreams (
    RevenueID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    RevenueType NVARCHAR(50),
    Amount DECIMAL(10,2)
);
GO


-- Costs Table
CREATE TABLE Costs (
    CostID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    CostType NVARCHAR(50),
    Amount DECIMAL(10,2)
);
GO


INSERT INTO Products (Category, BasePrice, FinalPrice, Discount, DemandLevel)
SELECT TOP 5000
    CASE WHEN RAND() > 0.5 THEN 'Groceries' ELSE 'Electronics' END,
    ROUND(RAND() * (5000 - 200) + 200, 2),
    ROUND((RAND() * (5000 - 200) + 200) * (1 + RAND() * 0.2), 2),
    ROUND(RAND() * 15, 2),
    CASE WHEN RAND() < 0.3 THEN 'High' WHEN RAND() < 0.6 THEN 'Medium' ELSE 'Low' END
FROM master.dbo.spt_values WHERE type = 'P';



INSERT INTO Orders (CustomerID, ProductID, OrderValue, DeliveryTime, ProductCategory, PriceHikeApplied, DeliveryFee)
SELECT TOP 5000
    c.CustomerID,
    p.ProductID,  -- Ensuring Orders are linked to Products
    ROUND(RAND() * (5000 - 200) + 200, 2),
    CAST(RAND() * (60 - 10) + 10 AS INT),
    p.Category,
    CASE WHEN c.CustomerType = 'Premium' THEN 1 ELSE 0 END,
    ROUND(RAND() * (100 - 20) + 20, 2)
FROM Customers c
JOIN Products p ON p.ProductID % 10 = c.CustomerID % 10  -- Matching Products to Orders
ORDER BY NEWID();


UPDATE Orders 
SET TotalRevenue = OrderValue + DeliveryFee;


INSERT INTO RevenueStreams (OrderID, RevenueType, Amount)
SELECT 
    o.OrderID,
    CASE WHEN RAND() > 0.5 THEN 'Delivery Fee' ELSE 'Advertising' END,
    ROUND(RAND() * (1000 - 100) + 100, 2)
FROM Orders o;


INSERT INTO Costs (OrderID, CostType, Amount)
SELECT 
    o.OrderID,
    CASE WHEN RAND() > 0.5 THEN 'Fixed' ELSE 'Variable' END,
    ROUND(RAND() * (500 - 50) + 50, 2)
FROM Orders o;


SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Orders';

SELECT * FROM BlinkitDB.dbo.Orders;

SELECT * FROM BlinkitDB.dbo.Orders;

USE BlinkitDB;
GO
SELECT * FROM dbo.Orders;


ALTER TABLE Orders ADD OrderDate DATE DEFAULT GETDATE();

select * from Orders




CREATE TABLE DateTable (
    Date DATE PRIMARY KEY,
    Year INT,
    Month VARCHAR(3),
    MonthYear VARCHAR(7)
);

INSERT INTO DateTable
SELECT 
    CAST(DATEADD(DAY, number, '2020-01-01') AS DATE) AS Date,
    YEAR(DATEADD(DAY, number, '2020-01-01')) AS Year,
    FORMAT(DATEADD(DAY, number, '2020-01-01'), 'MMM') AS Month,
    FORMAT(DATEADD(DAY, number, '2020-01-01'), 'MMM yyyy') AS MonthYear
FROM master.dbo.spt_values
WHERE type = 'P' AND number BETWEEN 0 AND DATEDIFF(DAY, '2020-01-01', GETDATE());


ALTER TABLE BlinkitDB.dbo.DateTable 
ALTER COLUMN MonthYear VARCHAR(10);


WITH RankedCustomers AS (
    SELECT 
        CustomerID, 
        Name, 
        Salary, 
        Location, 
        CustomerType,
        NTILE(100) OVER (ORDER BY Salary DESC) AS SalaryPercentile
    FROM Customers
)
UPDATE c
SET c.CustomerType = 'Premium'
FROM Customers c
JOIN RankedCustomers r ON c.CustomerID = r.CustomerID
WHERE r.SalaryPercentile = 1;

SELECT * FROM BlinkitDB.dbo.Customers;

USE BlinkitDB;
GO

select * from Customers


SELECT CustomerType, COUNT(CustomerID)
FROM Customers
GROUP BY CustomerType;


SELECT c.CustomerType, COUNT(o.OrderID) AS TotalOrders
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerType;



INSERT INTO Orders (CustomerID, OrderValue, DeliveryTime, ProductCategory, PriceHikeApplied, DeliveryFee, TotalRevenue)
SELECT 
    CustomerID, 
    ROUND(RAND() * (5000 - 1000) + 1000, 2), 
    '00:30:00', 
    'Groceries', 
    20, 
    ROUND(RAND() * (100 - 50) + 50, 2), 
    Ordervalue + DeliveryFee
FROM Customers WHERE CustomerType = 'Premium';


SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Orders';

ALTER TABLE Orders ADD OrderValue DECIMAL(10,2), DeliveryFee DECIMAL(10,2);


INSERT INTO Orders (CustomerID, OrderValue, DeliveryTime, ProductCategory, PriceHikeApplied, DeliveryFee, TotalRevenue)
SELECT 
    CustomerID, 
    ROUND(RAND() * (5000 - 1000) + 1000, 2),  -- OrderValue
    '00:30:00',  -- DeliveryTime
    'Groceries',  -- ProductCategory
    20,  -- PriceHikeApplied
    ROUND(RAND() * (100 - 50) + 50, 2) AS DeliveryFee,  -- DeliveryFee
    ROUND(RAND() * (5000 - 1000) + 1000, 2) + ROUND(RAND() * (100 - 50) + 50, 2)  -- TotalRevenue = OrderValue + DeliveryFee
FROM Customers WHERE CustomerType = 'Premium';


SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'DeliveryTime';

ALTER TABLE Orders ALTER COLUMN DeliveryTime TIME;

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'DeliveryTime';

ALTER TABLE Orders ALTER COLUMN DeliveryTime TIME;


ALTER TABLE Orders DROP COLUMN DeliveryTime;

ALTER TABLE Orders ADD DeliveryTime TIME;

INSERT INTO Orders (CustomerID, OrderValue, DeliveryTime, ProductCategory, PriceHikeApplied, DeliveryFee, TotalRevenue)
SELECT 
    CustomerID, 
    ROUND(RAND() * (5000 - 1000) + 1000, 2) AS OrderValue,  
    CONVERT(TIME, DATEADD(SECOND, RAND() * 86400, '00:00:00')) AS DeliveryTime,  
    'Groceries',  
    20,  
    ROUND(RAND() * (100 - 50) + 50, 2) AS DeliveryFee,  
    (ROUND(RAND() * (5000 - 1000) + 1000, 2) + ROUND(RAND() * (100 - 50) + 50, 2)) AS TotalRevenue  
FROM Customers WHERE CustomerType = 'Premium';



SELECT TOP 10 * FROM Orders;  -- Check orders data
SELECT COUNT(*) FROM Orders WHERE CustomerID IN (SELECT CustomerID FROM Customers WHERE CustomerType = 'Premium');  -- Check premium customer orders


WITH RankedCustomers AS (
    SELECT 
        CustomerID,
        Salary,
        NTILE(100) OVER (ORDER BY Salary DESC) AS PercentileRank
    FROM Customers
)
UPDATE Customers
SET CustomerType = 
    CASE 
        WHEN PercentileRank <= 15 THEN 'Premium'
        ELSE 'Regular'
    END
FROM RankedCustomers
WHERE Customers.CustomerID = RankedCustomers.CustomerID;


SELECT * FROM BlinkitDB.dbo.Customers;

USE BlinkitDB;
GO

SELECT CustomerType, COUNT(*) AS TotalCustomers
FROM Customers
GROUP BY CustomerType;


SELECT RevenueType, SUM(Amount) AS TotalAmount
FROM RevenueStreams
GROUP BY RevenueType;



INSERT INTO RevenueStreams (RevenueID, OrderID, RevenueType, Amount)
SELECT 
    NEWID(),  -- Generates a unique ID for each revenue record
    OrderID,
    'Product Sales',
    ROUND(RAND() * (4000 - 500) + 500, 2)  -- Random revenue between 500 and 4000
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM RevenueStreams WHERE RevenueType = 'Product Sales');

INSERT INTO RevenueStreams (RevenueID, OrderID, RevenueType, Amount)
SELECT 
    NEWID(),
    OrderID,
    'Delivery Fees',
    ROUND(RAND() * (200 - 50) + 50, 2)  -- Random delivery fee between 50 and 200
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM RevenueStreams WHERE RevenueType = 'Delivery Fees');


SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Orders';

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'RevenueStreams';

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Costs';


SELECT RevenueType, SUM(Amount) AS TotalRevenue
FROM RevenueStreams
GROUP BY RevenueType;


INSERT INTO RevenueStreams (RevenueID, OrderID, RevenueType, Amount)
SELECT 
    NEWID(),  
    OrderID,
    'Product Sales',
    ROUND(RAND() * (4000 - 500) + 500, 2)  
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM RevenueStreams WHERE RevenueType = 'Product Sales');

INSERT INTO RevenueStreams (RevenueID, OrderID, RevenueType, Amount)
SELECT 
    NEWID(),
    OrderID,
    'Delivery Fees',
    ROUND(RAND() * (200 - 50) + 50, 2)  
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM RevenueStreams WHERE RevenueType = 'Delivery Fees');


SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'RevenueStreams' AND COLUMN_NAME = 'RevenueID';


INSERT INTO RevenueStreams (OrderID, RevenueType, Amount)
SELECT 
    OrderID,
    'Product Sales',
    ROUND(RAND() * (4000 - 500) + 500, 2)  
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM RevenueStreams WHERE RevenueType = 'Product Sales');

INSERT INTO RevenueStreams (OrderID, RevenueType, Amount)
SELECT 
    OrderID,
    'Delivery Fees',
    ROUND(RAND() * (200 - 50) + 50, 2)  
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM RevenueStreams WHERE RevenueType = 'Delivery Fees');


SELECT CostType, SUM(Amount) AS TotalCost
FROM Costs
GROUP BY CostType;


INSERT INTO Costs (CostID, OrderID, CostType, Amount)
SELECT 
    NEWID(),  -- Use only if CostID is UNIQUEIDENTIFIER; otherwise, remove this line
    OrderID,
    'Fixed Cost',
    ROUND(RAND() * (1000 - 200) + 200, 2)  -- Generates a random fixed cost between 200-1000
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM Costs WHERE CostType = 'Fixed Cost');


SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Costs' AND COLUMN_NAME = 'CostID';


INSERT INTO Costs (OrderID, CostType, Amount)
SELECT 
    OrderID,
    'Fixed Cost',
    ROUND(RAND() * (1000 - 200) + 200, 2)
FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM Costs WHERE CostType = 'Fixed Cost');


SELECT RevenueType, SUM(Amount) AS TotalAmount
FROM RevenueStreams
GROUP BY RevenueType;


SELECT TOP 10 
    C.CustomerID, 
    SUM(O.TotalRevenue) AS TotalSpent
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY TotalSpent DESC


SELECT 
    CustomerID, 
    SUM(TotalRevenue) AS Revenue, 
    RANK() OVER (ORDER BY SUM(TotalRevenue) DESC) AS RevenueRank
FROM Orders
GROUP BY CustomerID



SELECT 
    FORMAT(O.OrderDate, 'MMM yyyy') AS MonthYear, 
    R.RevenueType, 
    SUM(R.Amount) AS TotalRevenue
FROM Orders O
JOIN RevenueStreams R ON O.OrderID = R.OrderID
GROUP BY FORMAT(O.OrderDate, 'MMM yyyy'), R.RevenueType
ORDER BY MonthYear

SELECT * FROM BlinkitDB.dbo.Orders;

USE BlinkitDB;
GO


SELECT 
    O.CustomerID, 
    SUM(O.OrderValue) AS OrderValue, 
    SUM(O.TotalRevenue - C.Amount) AS Profit
FROM Orders O
JOIN Costs C ON O.OrderID = C.OrderID
GROUP BY O.CustomerID;


-- Ensure 20% of TotalRevenue comes from Groceries
UPDATE Orders
SET TotalRevenue = TotalRevenue * 1.5  -- Boost Groceries Revenue by 50%
WHERE ProductCategory = 'Groceries' 
AND OrderID IN (
    SELECT TOP 20 PERCENT OrderID FROM Orders WHERE ProductCategory = 'Groceries'
);




SELECT 
    ProductCategory, 
    SUM(TotalRevenue) AS Total_Revenue,
    CAST(SUM(TotalRevenue) * 100.0 / (SELECT SUM(TotalRevenue) FROM Orders) AS DECIMAL(5,2)) AS Revenue_Percentage
FROM Orders
GROUP BY ProductCategory
ORDER BY Revenue_Percentage DESC;


UPDATE Orders
SET TotalRevenue = TotalRevenue * 3  -- Increase revenue 3x
WHERE ProductCategory = 'Groceries' 
AND OrderID IN (
    SELECT TOP 25 PERCENT OrderID FROM Orders WHERE ProductCategory = 'Groceries'
);



SELECT 
    ProductCategory, 
    SUM(TotalRevenue) AS Total_Revenue,
    CAST(SUM(TotalRevenue) * 100.0 / (SELECT SUM(TotalRevenue) FROM Orders) AS DECIMAL(5,2)) AS Revenue_Percentage
FROM Orders
GROUP BY ProductCategory
ORDER BY Revenue_Percentage DESC;


SELECT 
    ProductCategory, 
    SUM(TotalRevenue) AS Total_Revenue,
    CAST(SUM(TotalRevenue) * 100.0 / (SELECT SUM(TotalRevenue) FROM Orders) AS DECIMAL(5,2)) AS Revenue_Percentage
FROM Orders
GROUP BY ProductCategory
ORDER BY Revenue_Percentage DESC;


UPDATE Orders
SET TotalRevenue = TotalRevenue * 5  -- Increase revenue 5x
WHERE ProductCategory = 'Groceries' 
AND OrderID IN (
    SELECT TOP 30 PERCENT OrderID FROM Orders WHERE ProductCategory = 'Groceries'
);


SELECT * 
FROM Orders 
WHERE ProductCategory IS NULL OR ProductCategory = ''


SELECT * FROM Orders WHERE ProductCategory IS NULL OR ProductCategory = '';

UPDATE Orders
SET ProductCategory = 'Unknown Category'
WHERE ProductCategory IS NULL OR ProductCategory = '';


