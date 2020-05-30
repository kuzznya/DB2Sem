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
