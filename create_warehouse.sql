-- STEP 1 — Create the database

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ABC_DW')
BEGIN
    CREATE DATABASE ABC_DW;
END
GO

USE ABC_DW;
GO

-- STEP 2 — dim_date

IF OBJECT_ID('dbo.dim_date', 'U') IS NOT NULL DROP TABLE dbo.dim_date;
GO

CREATE TABLE dbo.dim_date
(
    DateKey         INT          NOT NULL,
    FullDate        DATE         NOT NULL,
    DateName        VARCHAR(10)  NOT NULL,
    DayOfWeek       TINYINT      NOT NULL,
    DayNameOfWeek   VARCHAR(10)  NOT NULL,
    DayOfYear       SMALLINT     NOT NULL,
    WeekOfYear      TINYINT      NOT NULL,
    MonthName       VARCHAR(10)  NOT NULL,
    MonthOfYear     TINYINT      NOT NULL,
    CalendarQuarter TINYINT      NOT NULL,
    CalendarYear    SMALLINT     NOT NULL,

    CONSTRAINT PK_dim_date PRIMARY KEY (DateKey),
    CONSTRAINT CHK_dim_date_DayOfWeek     CHECK (DayOfWeek BETWEEN 1 AND 7),
    CONSTRAINT CHK_dim_date_MonthOfYear   CHECK (MonthOfYear BETWEEN 1 AND 12),
    CONSTRAINT CHK_dim_date_CalendarQtr   CHECK (CalendarQuarter BETWEEN 1 AND 4)
);
GO

-- STEP 3 — dim_supplier

IF OBJECT_ID('dbo.dim_supplier', 'U') IS NOT NULL DROP TABLE dbo.dim_supplier;
GO

CREATE TABLE dbo.dim_supplier
(
    SupplierKey     INT           NOT NULL IDENTITY(1,1),
    SupplierName    VARCHAR(100)  NOT NULL,
    Description     VARCHAR(255)  NULL,
    Phone           VARCHAR(20)   NULL,
    Email           VARCHAR(100)  NULL,
    Fax             VARCHAR(20)   NULL,
    Address         VARCHAR(255)  NULL,
    PostCode        VARCHAR(10)   NULL,
    City            VARCHAR(50)   NULL,
    Country         VARCHAR(50)   NULL,

    CONSTRAINT PK_dim_supplier          PRIMARY KEY (SupplierKey),
    CONSTRAINT UQ_dim_supplier_Name     UNIQUE      (SupplierName)
);
GO

-- STEP 4 — dim_location

IF OBJECT_ID('dbo.dim_location', 'U') IS NOT NULL DROP TABLE dbo.dim_location;
GO

CREATE TABLE dbo.dim_location
(
    LocationKey     INT           NOT NULL IDENTITY(1,1),
    LocationName    VARCHAR(100)  NOT NULL,
    LocationType    VARCHAR(50)   NOT NULL,
    City            VARCHAR(50)   NULL,
    Country         VARCHAR(50)   NULL,

    CONSTRAINT PK_dim_location       PRIMARY KEY (LocationKey),
    CONSTRAINT UQ_dim_location_Name  UNIQUE      (LocationName)
);
GO

-- STEP 5 — dim_product

IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL DROP TABLE dbo.dim_product;
GO

CREATE TABLE dbo.dim_product
(
    ProductKey          INT             NOT NULL IDENTITY(1,1),
    SupplierKey         INT             NOT NULL,
    SKU                 VARCHAR(20)     NOT NULL,
    ProductName         VARCHAR(255)    NOT NULL,
    Description         VARCHAR(255)    NULL,
    Condition           VARCHAR(20)     NOT NULL,
    ProductType         VARCHAR(50)     NOT NULL,
    Brand               VARCHAR(50)     NOT NULL,
    Tags                VARCHAR(255)    NULL,
    CostPrice           DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    RetailPrice         DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    MinStockLevel       INT             NOT NULL DEFAULT 2,
    IsActive            TINYINT         NOT NULL DEFAULT 1,
    DateCreatedAt       DATE            NULL,
    DateDiscontinuedAt  DATE            NULL,

    CONSTRAINT PK_dim_product            PRIMARY KEY (ProductKey),
    CONSTRAINT UQ_dim_product_SKU        UNIQUE      (SKU),
    CONSTRAINT FK_dim_product_Supplier   FOREIGN KEY (SupplierKey)
                                             REFERENCES dbo.dim_supplier (SupplierKey),
    CONSTRAINT CHK_dim_product_Cost      CHECK (CostPrice >= 0),
    CONSTRAINT CHK_dim_product_Retail    CHECK (RetailPrice >= 0),
    CONSTRAINT CHK_dim_product_MinStock  CHECK (MinStockLevel >= 0),
    CONSTRAINT CHK_dim_product_IsActive  CHECK (IsActive IN (0, 1))
);
GO

-- STEP 6 — fact_daily_stock

IF OBJECT_ID('dbo.fact_daily_stock', 'U') IS NOT NULL DROP TABLE dbo.fact_daily_stock;
GO

CREATE TABLE dbo.fact_daily_stock
(
    StockFactKey        INT             NOT NULL IDENTITY(1,1),
    DateKey             INT             NOT NULL,
    ProductKey          INT             NOT NULL,
    SupplierKey         INT             NOT NULL,
    LocationKey         INT             NOT NULL,

    CurrentStockLevel   INT             NOT NULL DEFAULT 0,
    CostPrice           DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    RetailPrice         DECIMAL(10,2)   NOT NULL DEFAULT 0.00,

    StockValueAtCost    AS (CurrentStockLevel * CostPrice)   PERSISTED,
    StockValueAtRetail  AS (CurrentStockLevel * RetailPrice) PERSISTED,

    CONSTRAINT PK_fact_daily_stock           PRIMARY KEY (StockFactKey),
    CONSTRAINT FK_fact_stock_Date            FOREIGN KEY (DateKey)
                                                 REFERENCES dbo.dim_date     (DateKey),
    CONSTRAINT FK_fact_stock_Product         FOREIGN KEY (ProductKey)
                                                 REFERENCES dbo.dim_product  (ProductKey),
    CONSTRAINT FK_fact_stock_Supplier        FOREIGN KEY (SupplierKey)
                                                 REFERENCES dbo.dim_supplier (SupplierKey),
    CONSTRAINT FK_fact_stock_Location        FOREIGN KEY (LocationKey)
                                                 REFERENCES dbo.dim_location (LocationKey),
    CONSTRAINT UQ_fact_stock_DateProduct     UNIQUE (DateKey, ProductKey),
    CONSTRAINT CHK_fact_stock_StockLevel     CHECK (CurrentStockLevel >= 0),
    CONSTRAINT CHK_fact_stock_CostPrice      CHECK (CostPrice >= 0),
    CONSTRAINT CHK_fact_stock_RetailPrice    CHECK (RetailPrice >= 0)
);
GO

-- STEP 7 — fact_sent_purchase_orders

IF OBJECT_ID('dbo.fact_sent_purchase_orders', 'U') IS NOT NULL DROP TABLE dbo.fact_sent_purchase_orders;
GO

CREATE TABLE dbo.fact_sent_purchase_orders
(
    SentPOFactKey       INT             NOT NULL IDENTITY(1,1),
    SentDateKey         INT             NOT NULL,
    ProductKey          INT             NOT NULL,
    SupplierKey         INT             NOT NULL,
    LocationKey         INT             NOT NULL,

    PurchaseOrderCode   VARCHAR(100)    NOT NULL,

    OrderedQty          INT             NOT NULL DEFAULT 0,

    CONSTRAINT PK_fact_sent_po           PRIMARY KEY (SentPOFactKey),
    CONSTRAINT FK_fact_sent_Date         FOREIGN KEY (SentDateKey)
                                             REFERENCES dbo.dim_date     (DateKey),
    CONSTRAINT FK_fact_sent_Product      FOREIGN KEY (ProductKey)
                                             REFERENCES dbo.dim_product  (ProductKey),
    CONSTRAINT FK_fact_sent_Supplier     FOREIGN KEY (SupplierKey)
                                             REFERENCES dbo.dim_supplier (SupplierKey),
    CONSTRAINT FK_fact_sent_Location     FOREIGN KEY (LocationKey)
                                             REFERENCES dbo.dim_location (LocationKey),
    CONSTRAINT CHK_fact_sent_OrderedQty  CHECK (OrderedQty > 0)
);
GO

-- STEP 8 — fact_received_purchase_orders

IF OBJECT_ID('dbo.fact_received_purchase_orders', 'U') IS NOT NULL DROP TABLE dbo.fact_received_purchase_orders;
GO

CREATE TABLE dbo.fact_received_purchase_orders
(
    ReceivedPOFactKey   INT             NOT NULL IDENTITY(1,1),
    SentDateKey         INT             NOT NULL,
    ReceivedDateKey     INT             NOT NULL,
    ProductKey          INT             NOT NULL,
    SupplierKey         INT             NOT NULL,
    LocationKey         INT             NOT NULL,

    PurchaseOrderCode   VARCHAR(100)    NOT NULL,

    OrderedQty          INT             NOT NULL DEFAULT 0,
    ReceivedQty         INT             NOT NULL DEFAULT 0,

    UnfulfilledQty      AS (OrderedQty - ReceivedQty) PERSISTED,

    LeadTimeDays        INT             NOT NULL DEFAULT 0,

    CONSTRAINT PK_fact_received_po           PRIMARY KEY (ReceivedPOFactKey),
    CONSTRAINT FK_fact_rcvd_SentDate         FOREIGN KEY (SentDateKey)
                                                 REFERENCES dbo.dim_date     (DateKey),
    CONSTRAINT FK_fact_rcvd_ReceivedDate     FOREIGN KEY (ReceivedDateKey)
                                                 REFERENCES dbo.dim_date     (DateKey),
    CONSTRAINT FK_fact_rcvd_Product          FOREIGN KEY (ProductKey)
                                                 REFERENCES dbo.dim_product  (ProductKey),
    CONSTRAINT FK_fact_rcvd_Supplier         FOREIGN KEY (SupplierKey)
                                                 REFERENCES dbo.dim_supplier (SupplierKey),
    CONSTRAINT FK_fact_rcvd_Location         FOREIGN KEY (LocationKey)
                                                 REFERENCES dbo.dim_location (LocationKey),
    CONSTRAINT CHK_fact_rcvd_OrderedQty      CHECK (OrderedQty >= 0),
    CONSTRAINT CHK_fact_rcvd_ReceivedQty     CHECK (ReceivedQty >= 0),
    CONSTRAINT CHK_fact_rcvd_LeadTime        CHECK (LeadTimeDays >= 0)
);
GO
