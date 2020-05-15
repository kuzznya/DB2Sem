-- 1
SELECT p.Name, sub.Name
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS sub
ON p.ProductSubcategoryID = sub.ProductSubcategoryID
JOIN Production.ProductCategory AS cat
ON sub.ProductCategoryID = cat.ProductCategoryID
WHERE p.Color = 'Red' and p.ListPrice >= 100

-- 2
SELECT sub1.Name
FROM Production.ProductSubcategory AS sub1,
     Production.ProductSubcategory AS sub2
WHERE sub1.Name = sub2.Name AND sub1.ProductSubcategoryID != sub2.ProductSubcategoryID

-- 3
SELECT cat.Name, COUNT(*) AS 'Count'
FROM Production.ProductCategory AS cat
JOIN Production.ProductSubcategory AS sub
ON cat.ProductCategoryID = sub.ProductCategoryID
JOIN Production.Product AS p
ON sub.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY cat.ProductCategoryID, cat.Name

-- 4
SELECT sub.Name, COUNT(*) AS 'Count'
FROM Production.ProductSubcategory AS sub
JOIN Production.Product AS p
ON sub.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY sub.ProductSubcategoryID, sub.Name

-- 5
SELECT TOP 3 sub.Name, COUNT(*) as 'Count'
FROM Production.ProductSubcategory AS sub
JOIN Production.Product AS p
ON sub.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY sub.ProductSubcategoryID, sub.Name
ORDER BY COUNT(*) DESC

-- 6
SELECT sub.Name, MAX(p.ListPrice)
FROM Production.ProductSubcategory AS sub
JOIN Production.Product AS p
ON sub.ProductSubcategoryID = p.ProductSubcategoryID
WHERE p.Color = 'Red'
GROUP BY sub.ProductSubcategoryID, sub.Name

-- 7
SELECT vnd.Name, COUNT(*) as 'Count'
FROM Purchasing.Vendor AS vnd
JOIN Purchasing.ProductVendor as pvnd
ON vnd.BusinessEntityID = pvnd.BusinessEntityID
JOIN Production.Product AS p
ON pvnd.ProductID = p.ProductID
GROUP BY vnd.Name

-- 8
SELECT p.Name
FROM Production.Product AS p
JOIN Purchasing.ProductVendor AS vnd
ON p.ProductID = vnd.ProductID
GROUP BY p.ProductID, p.Name
HAVING COUNT(*) > 1

-- 9
SELECT TOP 1 p.Name, SUM(ord.OrderQty) AS 'Count'
FROM Purchasing.PurchaseOrderDetail AS ord
JOIN Production.Product AS p
ON ord.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY SUM(ord.OrderQty) DESC

-- 10
SELECT TOP 1 cat.Name
FROM Production.ProductCategory AS cat
JOIN Production.ProductSubcategory AS sub
ON cat.ProductCategoryID = sub.ProductCategoryID
JOIN Production.Product AS p
ON sub.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Purchasing.PurchaseOrderDetail AS ord
ON p.ProductID = ord.ProductID
GROUP BY cat.ProductCategoryID, cat.Name
ORDER BY SUM(ord.OrderQty) DESC

-- 11
SELECT cat.Name,
       COUNT(DISTINCT sub.ProductSubcategoryID) AS 'Count of subcats',
       COUNT(DISTINCT pr.ProductID) AS 'Count of products'
FROM Production.ProductCategory AS cat
LEFT JOIN Production.ProductSubcategory AS sub
ON cat.ProductCategoryID = sub.ProductCategoryID
LEFT JOIN Production.Product AS pr
ON sub.ProductSubcategoryID = pr.ProductSubcategoryID
GROUP BY cat.ProductCategoryID, cat.Name

-- 12
SELECT vnd.CreditRating,
       COUNT(DISTINCT p.ProductID) AS 'Count of products'
FROM Purchasing.Vendor AS vnd
JOIN Purchasing.ProductVendor AS pvnd
ON vnd.BusinessEntityID = pvnd.BusinessEntityID
JOIN Production.Product AS p
ON pvnd.ProductID = p.ProductID
GROUP BY vnd.CreditRating
