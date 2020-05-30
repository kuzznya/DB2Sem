-- 1. Найти долю продаж каждого продукта
-- (цена продукта * количество продукта),
-- на каждый чек, в денежном выражении.
SELECT sod.ProductID,
       sod.UnitPrice * sod.OrderQty /
       SUM(sod.UnitPrice * sod.OrderQty) OVER ( PARTITION BY sod.ProductID)
FROM Sales.SalesOrderDetail AS sod

-- 2 Вывести на экран список продуктов, их стоимость,
-- а также разницу между стоимостью этого продукта
-- и стоимостью самого дешевого продукта в той же подкатегории, к которой относится продукт.
SELECT p.Name, p.ListPrice,
       p.ListPrice - MIN(p.ListPrice) OVER ( PARTITION BY p.ProductSubcategoryID)
FROM Production.Product AS p


-- Задание при сдаче лабы:
-- Название товара,
-- название категории, к которой относится
-- и общее кол-во товаров в категории
SELECT p.Name,
       cat.Name,
       COUNT(p.ProductID) OVER (PARTITION BY cat.ProductCategoryID) AS 'Count in cat'
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS sub
ON p.ProductSubcategoryID = sub.ProductSubcategoryID
JOIN Production.ProductCategory AS cat
ON sub.ProductCategoryID = cat.ProductCategoryID
