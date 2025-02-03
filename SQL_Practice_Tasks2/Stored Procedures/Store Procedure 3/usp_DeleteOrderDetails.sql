
CREATE TABLE SalesOrderDetail (
    SalesOrderID INT,
    ProductID INT,
    OrderQty INT,
    UnitPrice DECIMAL(10, 2),
    PRIMARY KEY (SalesOrderID, ProductID)
);
GO

INSERT INTO SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice) VALUES
(1, 100, 2, 19.99),
(1, 101, 1, 29.99),
(2, 100, 3, 19.99),
(2, 102, 1, 39.99);
GO


IF OBJECT_ID('DeleteOrderDetails', 'P') IS NOT NULL
DROP PROCEDURE DeleteOrderDetails;
GO

CREATE PROCEDURE DeleteOrderDetails
    @SalesOrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    
    IF NOT EXISTS (SELECT 1 FROM SalesOrderDetail WHERE SalesOrderID = @SalesOrderID)
    BEGIN
        PRINT 'Error: SalesOrderID does not exist.';
        RETURN -1;
    END

    IF NOT EXISTS (SELECT 1 FROM SalesOrderDetail WHERE SalesOrderID = @SalesOrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Error: ProductID does not exist for the given SalesOrderID.';
        RETURN -1;
    END

    
    DELETE FROM SalesOrderDetail
    WHERE SalesOrderID = @SalesOrderID AND ProductID = @ProductID;

    PRINT 'Order details deleted successfully.';
    RETURN 0;
END;
GO

EXEC DeleteOrderDetails @SalesOrderID = 1, @ProductID = 101;

