IF OBJECT_ID('Orders', 'U') IS NOT NULL
DROP TABLE Orders;
GO

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATETIME,
    CustomerID INT
);
GO

IF OBJECT_ID('OrderDetails', 'U') IS NOT NULL
DROP TABLE OrderDetails;
GO

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO


INSERT INTO Orders (OrderID, OrderDate, CustomerID) VALUES
(1, '2022-01-01', 101),
(2, '2022-01-02', 102),
(3, '2022-01-03', 103);
GO


INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity) VALUES
(1, 1, 100, 2),
(2, 1, 101, 1),
(3, 2, 100, 3),
(4, 2, 102, 1),
(5, 3, 103, 5);
GO

 
CREATE TRIGGER trgInsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    
    DELETE FROM OrderDetails
    WHERE OrderID IN (SELECT OrderID FROM DELETED);

   
    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM DELETED);

    PRINT 'Order and its details deleted successfully.';
END;
GO



DELETE FROM Orders WHERE OrderID = 2;