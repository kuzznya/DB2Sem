-- Найти пары таких покупателей, что список названий товаров, которые они
-- когда-либо покупали, не пересекается ни в одной позиции.
SELECT TOP 3 t1.id, t2.id
FROM (
    SELECT soh.CustomerID AS id, ProductID AS product
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
) AS t1,
(
    SELECT soh.CustomerID as id, ProductID AS product
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
) AS t2
WHERE t1.product != all (
    SELECT sod.ProductID AS product
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.CustomerID = t1.id
);

-- 1. Вывести номера продуктов, таких, что их цена выше средней цены продукта
-- в подкатегории, к которой относится продукт. Запрос реализовать двумя
-- способами. В одном из решений допускается использование обобщенного
-- табличного выражения.
SELECT p.ProductID
FROM Production.Product As p
WHERE p.ListPrice > (
    SELECT avg(p1.ListPrice)
    FROM Production.Product AS p1
    WHERE p1.ProductSubcategoryID = p.ProductSubcategoryID
);

WITH res (subID, avgPrice) AS (
    SELECT p.ProductSubcategoryID, AVG(p.ListPrice)
    FROM Production.Product AS p
    GROUP BY p.ProductSubcategoryID
)
SELECT p1.ProductID
FROM Production.Product AS p1
JOIN res
ON p1.ProductSubcategoryID = res.subID
WHERE p1.ListPrice > res.avgPrice;


-- 2. Найти среднее количество покупок на чек для каждого покупателя (2 способа)
WITH res (id, count) AS (
    SELECT soh.CustomerID, COUNT(*)
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
)
SELECT id, AVG(count) AS 'Average amount'
FROM res
GROUP BY id

SELECT t.CustomerID, AVG(t.cnt)
FROM (
    SELECT soh.CustomerID, COUNT(*) AS cnt
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
) AS t
GROUP BY t.CustomerID;

-- 3. Вывести на экран следящую информацию: Название продукта, Общее
-- количество фактов покупки этого продукта, Общее количество покупателей
-- этого продукта
WITH orders (id, orders_count) AS (
    SELECT sod.ProductID, COUNT(DISTINCT sod.SalesOrderID)
    FROM Sales.SalesOrderDetail AS sod
    GROUP BY sod.ProductID
),
customers (id, customers_count) AS (
    SELECT sod.ProductID, COUNT(DISTINCT soh.CustomerID)
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY sod.ProductID
)
SELECT p.Name, orders.orders_count, customers.customers_count
FROM Production.Product AS p
JOIN orders
ON p.ProductID = orders.id
JOIN customers
ON ProductID = customers.id;

-- 4. Вывести для каждого покупателя информацию о максимальной и
-- минимальной стоимости одной покупки, чеке, в виде таблицы: номер
-- покупателя, максимальная сумма, минимальная сумма.
WITH sums (id, sum) AS (
    SELECT sod.SalesOrderID, SUM(sod.UnitPrice * sod.OrderQty)
    FROM Sales.SalesOrderDetail AS sod
    GROUP BY sod.SalesOrderID
)
SELECT soh.CustomerID, MAX(sums.sum) AS 'Max sum', MIN(sums.sum) AS 'Min sum'
FROM Sales.SalesOrderHeader AS soh
JOIN sums
ON soh.SalesOrderID = sums.id
GROUP BY soh.CustomerID;

-- 5. Найти таких номера покупателей, у которых нет ни одной пары
-- чеков с одинаковым количеством наименований товаров.
SELECT res.customerID
FROM (
    SELECT soh.CustomerID, soh.SalesOrderID, COUNT(sod.ProductID) AS productsCount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY soh.CustomerID, soh.SalesOrderID
) AS res
GROUP BY res.customerID, res.productsCount
HAVING COUNT(*) = 1;

-- 6. Найти номера покупателей, у которых все купленные ими товары были
-- куплены как минимум дважды, т.е. на два разных чека.
WITH res1 (CustomerID, ProductID) AS (
    SELECT soh1.CustomerID, sod1.ProductID
    FROM Sales.SalesOrderDetail AS sod1
    JOIN Sales.SalesOrderHeader AS soh1
    ON sod1.SalesOrderID = soh1.SalesOrderID
    GROUP BY soh1.CustomerID, sod1.ProductID
    HAVING COUNT(*) > 1
), res2 (CustomerID) AS (
    SELECT soh1.CustomerID
    FROM Sales.SalesOrderDetail AS sod1
    JOIN Sales.SalesOrderHeader AS soh1
    ON sod1.SalesOrderID = soh1.SalesOrderID
    GROUP BY soh1.CustomerID, sod1.ProductID
    HAVING COUNT(*) = 1
)
SELECT DISTINCT CustomerID
FROM res1
WHERE CustomerID not in (
    SELECT * FROM res2
);

WITH res (CustomerID) AS (
    SELECT soh1.CustomerID
    FROM Sales.SalesOrderHeader AS soh1
    JOIN Sales.SalesOrderDetail AS sod1
    ON soh1.SalesOrderID = sod1.SalesOrderID
    GROUP BY soh1.CustomerID, sod1.ProductID
    HAVING COUNT(*) = 1
)
SELECT soh.CustomerID
FROM Sales.SalesOrderHeader AS soh
WHERE soh.CustomerID not in (
    SELECT * FROM res
)


-- Вопрос при сдаче лабы:
-- Номера покупателей, которые покупали из более чем половины подкатегорий товаров
-- и для них вывести информацию: номер покупателя, кол-во чеков, средняя сумма на один чек
WITH bills (CustomerID, OrderID, sum) AS (
    SELECT soh.CustomerID, sod.SalesOrderID, SUM(sod.UnitPrice * sod.OrderQty)
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
    GROUP BY soh.CustomerID, sod.SalesOrderID
),
customers (CustomerID) AS (
    SELECT soh.CustomerID
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product AS p
    ON p.ProductID = sod.ProductID
    GROUP BY soh.CustomerID
        HAVING COUNT(DISTINCT p.ProductSubcategoryID) > (
        SELECT COUNT(DISTINCT p1.ProductSubcategoryID)
        FROM Production.Product AS p1
    )/2
)
SELECT customers.CustomerID,
       COUNT(bills.OrderID) AS 'Count of orders',
       AVG(bills.sum) AS 'Average sum'
FROM customers
JOIN bills
ON customers.CustomerID = bills.CustomerID
GROUP BY customers.CustomerID;