--1.List of all customers
SELECT* FROM Sales.Customer;

--2. List of all custtomers where store name ending in N
SELECT * FROM Sales.Customer C
JOIN Sales.Store s ON c.StoreID=s.BusinessEntityID
WHERE s.Name LIKE '%N';

-- 3. List of all customers who live in Berlin or London
SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

-- 4. List of all customers who live in UK or USA
SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

-- 5. List of all products sorted by product name
SELECT * FROM Production.Product ORDER BY Name;

-- 6. List of all products where product name starts with an A
SELECT * FROM Production.Product WHERE Name LIKE 'A%';

-- 7. List of customers who ever placed an order
SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;

-- 8. List of Customers who live in London and have bought chai
SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON pp.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City = 'London' AND p.Name = 'Chai';

-- 9. List of customers who never place an order
SELECT * FROM Sales.Customer
WHERE CustomerID NOT IN (SELECT CustomerID FROM Sales.SalesOrderHeader);

-- 10. List of customers who ordered Tofu
SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

-- 11. Details of first order of the system
SELECT TOP 1 * FROM Sales.SalesOrderHeader ORDER BY OrderDate;

-- 12. Find the details of most expensive order date
SELECT TOP 1 soh.*, SUM(sod.UnitPrice * sod.OrderQty) AS TotalAmount
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID, soh.OrderDate
ORDER BY TotalAmount DESC;

-- 13. For each order get the OrderID and Average quantity of items in that order
SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- 14. For each order get the orderID, minimum quantity and maximum quantity for that order
SELECT SalesOrderID, MIN(OrderQty) AS MinQuantity, MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- 15. Get a list of all managers and total number of employees who report to them.
SELECT m.BusinessEntityID AS ManagerID, COUNT(e.BusinessEntityID) AS NumberOfEmployees
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
GROUP BY m.BusinessEntityID;

-- 16. Get the OrderID and the total quantity for each order that has a total quantity of greater than 300
SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

-- 17. List of all orders placed on or after 1996/12/31
SELECT * FROM Sales.SalesOrderHeader WHERE OrderDate >= '1996-12-31';

-- 18. List of all orders shipped to Canada
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';

-- 19. List of all orders with order total > 200
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN (
    SELECT SalesOrderID, SUM(UnitPrice * OrderQty) AS OrderTotal
    FROM Sales.SalesOrderDetail
    GROUP BY SalesOrderID
) AS OrderTotals ON soh.SalesOrderID = OrderTotals.SalesOrderID
WHERE OrderTotals.OrderTotal > 200;

-- 20. List of countries and sales made in each country
SELECT cr.Name AS Country, SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;

-- 21. List of Customer ContactName and number of orders they placed
SELECT pp.FirstName + ' ' + pp.LastName AS ContactName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName;

-- 22. List of customer contact names who have placed more than 3 orders
SELECT pp.FirstName + ' ' + pp.LastName AS ContactName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName
HAVING COUNT(soh.SalesOrderID) > 3;

-- 23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998
SELECT DISTINCT p.*
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. List of employee firstname, lastname, supervisor FirstName, LastName
SELECT
    e.BusinessEntityID AS EmployeeID,
    p.FirstName AS EmployeeFirstName,
    p.LastName AS EmployeeLastName,
    m.BusinessEntityID AS ManagerID,
    pm.FirstName AS ManagerFirstName,
    pm.LastName AS ManagerLastName
FROM HumanResources.Employee AS e
INNER JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN HumanResources.Employee AS m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
LEFT JOIN Person.Person AS pm ON m.BusinessEntityID = pm.BusinessEntityID;

-- 25. List of Employees id and total sale conducted by employee
SELECT e.BusinessEntityID, SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales
FROM HumanResources.Employee e
JOIN Sales.SalesOrderHeader soh ON e.BusinessEntityID = soh.SalesPersonID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY e.BusinessEntityID;

-- 26. List of employees whose FirstName contains character a
SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';

-- 27. List of managers who have more than four people reporting to them.
SELECT 
    ManagerID = m.BusinessEntityID,
    ManagerFirstName = pm.FirstName,
    ManagerLastName = pm.LastName,
    NumberOfReports = COUNT(e.BusinessEntityID)
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person pm ON m.BusinessEntityID = pm.BusinessEntityID
GROUP BY m.BusinessEntityID, pm.FirstName, pm.LastName
HAVING COUNT(e.BusinessEntityID) > 4;

-- 28. List of Orders and ProductNames
SELECT soh.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;

-- 29. List of orders placed by the best customer
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN (
    SELECT TOP 1 CustomerID, COUNT(SalesOrderID) AS NumberOfOrders
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
    ORDER BY NumberOfOrders DESC
) AS BestCustomer ON soh.CustomerID = BestCustomer.CustomerID;

-- 30. List of orders placed by customers who do not have a Fax number
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.PersonPhone pp ON c.PersonID = pp.BusinessEntityID
LEFT JOIN Person.PhoneNumberType pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
WHERE pp.PhoneNumber IS NULL OR pnt.Name != 'FAX';

-- 31. List of Postal codes where the product Tofu was shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

-- 32. List of product Names that were shipped to France
SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

-- 33. List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.'
SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product p
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

-- 34. List of products that were never ordered
SELECT * FROM Production.Product
WHERE ProductID NOT IN (SELECT ProductID FROM Sales.SalesOrderDetail);

-- 35. List of products where units in stock is less than 10 and units on order are 0.
SELECT p.ProductID, p.Name, pi.Quantity
FROM Production.Product p
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
LEFT JOIN Purchasing.PurchaseOrderDetail pod ON p.ProductID = pod.ProductID
WHERE pi.Quantity < 10
AND (pod.OrderQty IS NULL OR pod.OrderQty = 0); 

-- 36. List of top 10 countries by sales
SELECT TOP 10
    sp.CountryRegionCode AS ShipCountry,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalSales
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
GROUP BY 
    sp.CountryRegionCode
ORDER BY 
    TotalSales DESC;

-- 37. Number of orders each employee has taken for customers with CustomerIDs between A and AO
SELECT soh.SalesPersonID, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE c.CustomerID BETWEEN 'A' AND 'AO'
GROUP BY soh.SalesPersonID;

-- 38. Orderdate of most expensive order
SELECT TOP 1 soh.OrderDate
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID, soh.OrderDate
ORDER BY SUM(sod.UnitPrice * sod.OrderQty) DESC;

-- 39. Product name and total revenue from that product
SELECT p.Name AS ProductName, SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name;

-- 40. Supplierid and number of products offered
SELECT pv.BusinessEntityID AS SupplierID, COUNT(pv.ProductID) AS NumberOfProducts
FROM Purchasing.ProductVendor pv
GROUP BY pv.BusinessEntityID;

-- 41. Top ten customers based on their business
SELECT TOP 10
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    c.CustomerID,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalSpent
FROM 
    Sales.Customer c
LEFT JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN 
    Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY 
    c.CustomerID, p.FirstName, p.LastName, s.Name
ORDER BY 
    TotalSpent DESC;

-- 42. What is the total revenue of the company
SELECT SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM Sales.SalesOrderDetail sod;