-- 8
SELECT ProductID, COUNT(*) as 'Count'
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 3

-- 9
SELECT ProductID, COUNT(*) as 'COUNT'
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) = 3 or COUNT(*) = 5

-- 10
SELECT ProductSubcategoryID, COUNT(*) as 'Count'
FROM Production.Product
WHERE ProductSubcategoryID is not null
GROUP BY ProductSubcategoryID
HAVING COUNT(*) > 10

-- 11
SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID, ProductID
HAVING COUNT(*) = 1

-- 12
SELECT TOP 1 SalesOrderID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY COUNT(*) DESC

-- 13
SELECT TOP 1 WITH TIES SalesOrderID, SUM(UnitPrice * OrderQty)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY SUM(UnitPrice * OrderQty) DESC

-- 14
SELECT ProductSubcategoryID, COUNT(*) as 'Count'
FROM Production.Product
WHERE ProductSubcategoryID is not null and Color is not null
GROUP BY ProductSubcategoryID

-- 15
SELECT Color, COUNT(*) as 'Count'
FROM Production.Product
GROUP BY Color
ORDER BY COUNT(*) DESC

-- 16
SELECT ProductID, COUNT(SalesOrderID) AS 'CountOfOrders'
FROM Sales.SalesOrderDetail
WHERE OrderQty > 1
GROUP BY ProductID
HAVING COUNT(SalesOrderID) > 2
