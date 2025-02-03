CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(50),
    UnitPrice DECIMAL(18, 2),
    UnitsInStock INT,
    ReorderLevel INT
);


CREATE TABLE [Order Details] (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(18, 2),
    Quantity INT,
    Discount DECIMAL(4, 2)
);

INSERT INTO Products (ProductID, Name, UnitPrice, UnitsInStock, ReorderLevel)
VALUES
(1, 'Product A', 10.00, 100, 20),
(2, 'Product B', 20.00, 50, 10),
(3, 'Product C', 30.00, 30, 5);

INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES
(1, 1, 10.00, 5, 0),
(1, 2, 20.00, 2, 0),
(2, 3, 30.00, 1, 0);


GO

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(4, 2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentUnitPrice DECIMAL(18, 2);
    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;

    IF @UnitPrice IS NULL
    BEGIN
        SELECT @CurrentUnitPrice = UnitPrice
        FROM Products
        WHERE ProductID = @ProductID;

        IF @CurrentUnitPrice IS NULL
        BEGIN
            PRINT 'Invalid ProductID. No such product exists.';
            RETURN;
        END
    END
    ELSE
    BEGIN
        SET @CurrentUnitPrice = @UnitPrice;
    END

    
    SELECT @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    IF @UnitsInStock IS NULL
    BEGIN
        PRINT 'Invalid ProductID. No such product exists.';
        RETURN;
    END

    
    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available to fulfill the order.';
        RETURN;
    END

    
    INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @CurrentUnitPrice, @Quantity, @Discount);

    
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

   
    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    
    IF @UnitsInStock - @Quantity < @ReorderLevel
    BEGIN
        PRINT 'The quantity in stock of this product has dropped below its reorder level.';
    END
END;

GO






EXEC InsertOrderDetails @OrderID = 3, @ProductID = 1, @Quantity = 10;


EXEC InsertOrderDetails @OrderID = 3, @ProductID = 2, @Quantity = 60;


EXEC InsertOrderDetails @OrderID = 3, @ProductID = 3, @Quantity = 5;
