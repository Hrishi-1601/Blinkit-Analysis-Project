
SELECT COUNT(*) FROM Blinkit.dbo.Blinkit

UPDATE Blinkit.dbo.Blinkit
SET Item_Fat_Content = 
CASE
WHEN Item_Fat_Content IN ('LF','low fat') THEN 'Low Fat'
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END

SELECT * FROM Blinkit.dbo.Blinkit

SELECT distinct(Item_Fat_Content) from Blinkit.dbo.Blinkit

SELECT CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)) AS TOTAL_SALES_MILLIONS FROM Blinkit.dbo.Blinkit

SELECT CAST(AVG(Total_Sales) AS decimal(10,0)) AS AVG_SALES FROM Blinkit.dbo.Blinkit

SELECT COUNT(*) AS NO_OF_ITEMS FROM Blinkit.dbo.Blinkit

SELECT CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)) AS LowFat_SALES_MILLIONS FROM Blinkit.dbo.Blinkit
WHERE Item_Fat_Content = 'Low Fat'

SELECT CAST(AVG(RATING) AS DECIMAL(10,2)) AVG_RATING FROM Blinkit.dbo.Blinkit



SELECT Item_Fat_Content, sum(Total_Sales) as Total_Sales from Blinkit.dbo.Blinkit
Group by Item_Fat_Content
order by Total_Sales desc

SELECT Item_Fat_Content, 
cast(sum(Total_Sales)/1000 as decimal (10,2)) as Total_Sales_Thousands,
cast(avg(Total_Sales) as decimal (10,1)) as Avg_Sales,
Count(*) no_of_items,
cast(avg(Rating) as decimal(10,2)) as Avg_Rating

from Blinkit.dbo.Blinkit
where Outlet_Establishment_Year = 2020
Group by Item_Fat_Content
order by Total_Sales_Thousands desc





SELECT TOP 5 Item_Type, 
cast(sum(Total_Sales)as decimal (10,2)) as Total_Sales,
cast(avg(Total_Sales) as decimal (10,1)) as Avg_Sales,
Count(*) no_of_items,
cast(avg(Rating) as decimal(10,2)) as Avg_Rating
from Blinkit.dbo.Blinkit
Group by Item_Type
order by Total_Sales


SELECT Outlet_Location_Type,Item_Fat_Content,
cast(sum(Total_Sales)as decimal (10,2)) as Total_Sales,
cast(avg(Total_Sales) as decimal (10,1)) as Avg_Sales,
Count(*) no_of_items,
cast(avg(Rating) as decimal(10,2)) as Avg_Rating
from Blinkit.dbo.Blinkit
Group by Outlet_Location_Type,Item_Fat_Content
order by Total_Sales


SELECT Outlet_Size,
CAST(sum(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
CAST((sum(Total_Sales) *100.0/sum(sum(Total_Sales)) over()) as decimal(10,2)) as Sales_Percentage
from Blinkit.dbo.Blinkit
Group by Outlet_Size
order by Total_Sales Desc



SELECT outlet_location_type,
cast(sum(Total_Sales)as decimal (10,2)) as Total_Sales,
cast(avg(Total_Sales) as decimal (10,1)) as Avg_Sales,
CAST((sum(Total_Sales) *100.0/sum(sum(Total_Sales)) over()) as decimal(10,2)) as Sales_Percentage,
Count(*) no_of_items,
cast(avg(Rating) as decimal(10,2)) as Avg_Rating
from Blinkit.dbo.Blinkit
where Outlet_Establishment_Year = 2022
Group by Outlet_location_type
order by Total_Sales desc




SELECT Outlet_Type,
cast(sum(Total_Sales)as decimal (10,2)) as Total_Sales,
cast(avg(Total_Sales) as decimal (10,1)) as Avg_Sales,
CAST((sum(Total_Sales) *100.0/sum(sum(Total_Sales)) over()) as decimal(10,2)) as Sales_Percentage,
Count(*) no_of_items,
cast(avg(Rating) as decimal(10,2)) as Avg_Rating
from Blinkit.dbo.Blinkit
Group by Outlet_type
order by Total_Sales desc















