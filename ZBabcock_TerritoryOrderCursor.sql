USE AdventureWorks2014

SET NOCOUNT ON;  
GO
CREATE PROC [Sales].[sp_RetrieveTerritoryOrdersCursor] (@year int)
AS
BEGIN
DECLARE @territory_id int, @territory_name nvarchar(50),  
    @message varchar(80), @order nvarchar(50), @orderdate date;  

PRINT '-------- ' + CAST(@year AS VARCHAR(4)) + ' Territory Orders Report --------';  

DECLARE territory_cursor CURSOR FOR   
SELECT DISTINCT P.TerritoryID, T.Name
FROM Sales.SalesPerson P
INNER JOIN Sales.SalesTerritory T
ON T.TerritoryID = P.TerritoryID
ORDER BY P.TerritoryID;

OPEN territory_cursor

FETCH NEXT FROM territory_cursor   
INTO @territory_id, @territory_name  

WHILE @@FETCH_STATUS = 0
BEGIN  
    PRINT ' '  
    SELECT @message = '----- ' + CAST(@year AS VARCHAR(4)) + ' Orders in Territory: ' +   
        @territory_name  

    PRINT @message   

    DECLARE order_cursor CURSOR FOR   
    SELECT SH.SalesOrderNumber, SH.OrderDate
    FROM Sales.SalesOrderHeader SH
	INNER JOIN Sales.SalesPerson P
	ON P.BusinessEntityID = SH.SalesPersonID 
    WHERE YEAR(SH.OrderDate) = @year AND  
    P.TerritoryID = @territory_id  
	ORDER BY SH.OrderDate

    OPEN order_cursor  
    FETCH NEXT FROM order_cursor INTO @order, @orderdate 

    IF @@FETCH_STATUS <> 0   
        PRINT '         <<None>>'       

    WHILE @@FETCH_STATUS = 0  
    BEGIN  

        SELECT @message = '         ' + @order + '   Date: ' + CAST(@orderdate AS VARCHAR(15)) 
        PRINT @message  
        FETCH NEXT FROM order_cursor INTO @order, @orderdate 
        END  

    CLOSE order_cursor  
    DEALLOCATE order_cursor  

    FETCH NEXT FROM territory_cursor   
    INTO @territory_id, @territory_name  
END   
CLOSE territory_cursor;  
DEALLOCATE territory_cursor;
END  


--EXEC Sales.sp_RetrieveTerritoryOrdersCursor '2012'

--DROP PROC Sales.sp_RetrieveTerritoryOrdersCursor

--The time the cursor takes is less than 1 second, but it's still a noticeable amount of time.

GO
CREATE PROC [Sales].[sp_RetrieveTerritoryOrders] (@year int)
AS
BEGIN

--CREATE TABLE #TerritoryOrders
--(
--SalesOrderNumber VARCHAR(50) NOT NULL,
--OrderDate DATE NOT NULL,
--Territory VARCHAR(50) NOT NULL
--)


--SELECT SalesNumber, OrderDate, Territory
--INTO #TerritoryOrders
--FROM (SELECT SH.SalesOrderNumber [SalesNumber], CAST(SH.OrderDate as DATE) [OrderDate], T.[Name] [Territory]
--    FROM Sales.SalesOrderHeader SH
--	INNER JOIN Sales.SalesPerson P
--	ON P.BusinessEntityID = SH.SalesPersonID 
--	INNER JOIN Sales.SalesTerritory T
--	ON T.TerritoryID = P.TerritoryID
--    WHERE YEAR(SH.OrderDate) = @year
--	ORDER BY P.TerritoryID, OrderDate
--	FOR XML AUTO) AS o
	
	SELECT SH.SalesOrderNumber [SalesNumber], CAST(SH.OrderDate as DATE) [OrderDate], T.[Name] [Territory]
    FROM Sales.SalesOrderHeader SH
	INNER JOIN Sales.SalesPerson P
	ON P.BusinessEntityID = SH.SalesPersonID 
	INNER JOIN Sales.SalesTerritory T
	ON T.TerritoryID = P.TerritoryID
    WHERE YEAR(SH.OrderDate) = @year
	ORDER BY P.TerritoryID, OrderDate

END
GO
--EXEC Sales.sp_REtrieveTerritoryOrders '2012'

/*
This second stored procedure is a lot more straightforward than the first procedure, with just a different format.
Getting said result set outputted in a more report-friendly format is as simple as right-clicking the query results, 
and saving the file to your desired format (a tab-separated txt file or a csv file were the two that I saw). I don't know
of, nor could I find, a way to just 
*/