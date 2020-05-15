-- Название категории, где содержится самый дорогой товар
SELECT cat.Name
FROM Production.ProductCategory AS cat
WHERE cat.ProductCategoryID IN (
    SELECT sub.ProductCategoryID
    FROM Production.ProductSubcategory AS sub
    WHERE sub.ProductSubcategoryID = (
        SELECT TOP 1 p.ProductSubcategoryID
        FROM Production.Product AS p
        ORDER BY p.ListPrice DESC
    )
)

-- Список товаров, у которых цвет совпадает с цветом самого дорогого товара,
-- и стиль совпадает со стилем самого дорого товара
SELECT *
FROM Production.Product AS p
WHERE p.Color = (
    SELECT TOP 1 p1.Color
    FROM Production.Product AS p1
    ORDER BY p1.ListPrice DESC
) and p.Style = (
    SELECT TOP 1 p1.Style
    FROM Production.Product AS p1
    ORDER BY p1.ListPrice DESC
)

-- Номер подкатегории товаров с наибольшим количеством товаров
SELECT p.ProductSubcategoryID
FROM Production.Product AS p
GROUP BY p.ProductSubcategoryID
HAVING COUNT(*) = (
    SELECT TOP 1 COUNT(*)
    FROM Production.Product AS p
    WHERE p.ProductSubcategoryID is not null
    GROUP BY p.ProductSubcategoryID
    ORDER BY COUNT(*) DESC
)

-- Список самых дорогих товаров в каждой из подкатегорий
SELECT p.Name
FROM Production.Product AS p
WHERE p.ListPrice = (
    SELECT MAX(p1.ListPrice)
    FROM Production.Product AS p1
    WHERE p.ProductSubcategoryID = p1.ProductSubcategoryID
)

-- Название продукта и название подкатегории к которой он относится
SELECT p.Name, (
    SELECT sub.Name
    FROM Production.ProductSubcategory AS sub
    WHERE p.ProductSubcategoryID = sub.ProductSubcategoryID
) AS 'Subcategory'
FROM Production.Product AS p

-- Найти название подкатегории с наибольшим количеством продуктов,
-- без учета продуктов для которых подкатегория не определена
SELECT sub.Name
FROM Production.ProductSubcategory AS sub
WHERE sub.ProductSubcategoryID = (
    SELECT p.ProductSubcategoryID
    FROM Production.Product AS p
    GROUP BY p.ProductSubcategoryID
    HAVING COUNT(*) = (
        SELECT TOP 1 COUNT(*)
        FROM Production.Product AS p
        WHERE p.ProductSubcategoryID is not null
        GROUP BY p.ProductSubcategoryID
        ORDER BY COUNT(*) DESC
    )
)

-- Вывести на экран такого покупателя,
-- который каждый раз покупал только одну номенклатуру товаров,
-- не обязательно в одинаковых количествах,
-- т.е. у него всегда был один и тот же «список покупок».
SELECT soh.CustomerID, COUNT(*)
FROM Sales.SalesOrderHeader AS soh
GROUP BY soh.CustomerID
HAVING COUNT(*) > 1 and COUNT(*) = ALL (
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS soh1
    JOIN Sales.SalesOrderDetail AS sod
    ON soh1.SalesOrderID = sod.SalesOrderID
    WHERE soh1.CustomerID = soh.CustomerID
    GROUP BY soh1.CustomerID, sod.ProductID
)

-- Вывести на экран:
-- название товара,
-- количество покупателей, покупавших этот товар,
-- количество покупателей, совершавших покупки, но не покупавших товар из первой колонки
SELECT p.Name,
(
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    WHERE sod.ProductID = p.ProductID
    GROUP BY sod.ProductID
) AS 'Count of customers',

(
    SELECT COUNT(DISTINCT soh.CustomerID)
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    WHERE soh.CustomerID not in (
        SELECT DISTINCT soh.CustomerID
        FROM Sales.SalesOrderHeader AS soh1
        JOIN Sales.SalesOrderDetail AS sod1
        ON soh1.SalesOrderID = sod1.SalesOrderID
        WHERE sod1.ProductID = p.ProductID
--         GROUP BY sod1.ProductID
    )
--     GROUP BY soh.CustomerID
) AS 'Count of non-customers'

FROM Production.Product AS p

-- 1. Найти название самого продаваемого продукта
SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductID = (
    SELECT TOP 1 sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    GROUP BY sod.ProductID
    ORDER BY COUNT(*)
)

-- 2. 2 Найти покупателя, совершившего покупку на самую большую сумму,
-- считая сумму покупки исходя из цены товара без скидки (UnitPrice)
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesOrderID = (
    SELECT TOP 1 sod.SalesOrderID
    FROM Sales.SalesOrderDetail AS sod
    GROUP BY sod.SalesOrderID
    ORDER BY SUM(sod.UnitPrice) DESC
)

-- 3. Найти такие продукты, которые покупал только один покупатель
SELECT sod.ProductID
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader AS soh
ON sod.SalesOrderID = soh.SalesOrderID
WHERE sod.ProductID NOT IN (
    SELECT sod1.ProductID
    FROM Sales.SalesOrderDetail AS sod1
    JOIN Sales.SalesOrderHeader AS soh1
    ON sod1.SalesOrderID = soh1.SalesOrderID
    WHERE soh1.CustomerID != soh.CustomerID
)

SELECT P.Name
FROM Production.Product AS P
WHERE (
    SELECT COUNT(*)
    FROM Sales.SalesOrderDetail AS s1
    JOIN Sales.SalesOrderHeader AS s2
    ON s1.SalesOrderID = s2.SalesOrderID AND s1.ProductID = P.ProductID
    GROUP BY s2.CustomerID
    HAVING COUNT(*) = (
        SELECT COUNT(*)
        FROM Sales.SalesOrderDetail AS S
        WHERE S.ProductID = P.ProductID
    )
) > 0

-- 4. Вывести список продуктов,
-- цена которых выше средней цены товаров в подкатегории, к которой относится товар
SELECT p.Name
FROM Production.Product AS p
WHERE p.ListPrice > (
    SELECT AVG(p1.ListPrice)
    FROM Production.Product AS p1
    WHERE p1.ProductSubcategoryID = p.ProductSubcategoryID
)

-- 7. Найти покупателей, у которых есть товар, присутствующий в каждой покупке/чеке
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
ON soh.SalesOrderID = sod.SalesOrderID
WHERE sod.ProductID IN (
    SELECT sod1.ProductID
    FROM Sales.SalesOrderDetail AS sod1
    GROUP BY sod1.ProductID HAVING sod1.
)

-- 5 ?
SELECT Pr.Name FROM Production.Product AS Pr
WHERE (
  SELECT COUNT(*)
  FROM Sales.Customer AS P
  WHERE (
    SELECT COUNT(*)
    FROM Sales.SalesOrderHeader AS P1
    WHERE P1.CustomerID = P.CustomerID
  ) = (
    SELECT TOP 1 COUNT(*)
    FROM Sales.SalesOrderDetail AS P21
    JOIN Sales.SalesOrderHeader AS P22
    ON P21.SalesOrderID = P22.SalesOrderID AND P.CustomerID = P22.CustomerID AND P21.ProductID = Pr.ProductID
    GROUP BY P21.ProductID
    ORDER BY COUNT(*) DESC
  )
) > 0


