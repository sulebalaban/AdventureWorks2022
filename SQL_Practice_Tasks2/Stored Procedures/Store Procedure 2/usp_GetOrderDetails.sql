
IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail)
BEGIN
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
    VALUES
    (1, 1, 10.00, 5, 0),
    (1, 2, 20.00, 2, 0),
    (2, 3, 30.00, 1, 0);
END



IF OBJECT_ID('GetOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE GetOrderDetails;
GO

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN 1;
    END

    
    SELECT SalesOrderID AS OrderID,
           ProductID,
           UnitPrice,
           OrderQty AS Quantity,
           UnitPriceDiscount AS Discount
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END;
GO



EXEC GetOrderDetails @OrderID = 1;


EXEC GetOrderDetails @OrderID = 99;