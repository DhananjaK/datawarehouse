USE ABC_DW;
GO

IF OBJECT_ID('dbo.vw_export_daily_stock',   'V') IS NOT NULL DROP VIEW dbo.vw_export_daily_stock;
IF OBJECT_ID('dbo.vw_export_received_po',   'V') IS NOT NULL DROP VIEW dbo.vw_export_received_po;
IF OBJECT_ID('dbo.vw_export_sent_po',       'V') IS NOT NULL DROP VIEW dbo.vw_export_sent_po;
GO

-- VIEW 1: vw_export_daily_stock

CREATE VIEW dbo.vw_export_daily_stock AS
SELECT
    CONVERT(VARCHAR(10), d.FullDate, 23)   AS FullDate,
    d.WeekOfYear,
    d.MonthName,
    d.CalendarYear,

    p.SKU,
    RTRIM(p.ProductName)                   AS ProductName,
    p.ProductType,
    p.Brand,
    p.MinStockLevel,

    s.SupplierName,

    l.LocationName,

    f.CurrentStockLevel,
    f.CostPrice,
    f.RetailPrice,
    f.StockValueAtCost,
    f.StockValueAtRetail,

    CASE WHEN f.CurrentStockLevel <= p.MinStockLevel
         THEN 'YES' ELSE 'NO'
    END                                    AS BelowMinStock
FROM      dbo.fact_daily_stock     f
JOIN      dbo.dim_date             d  ON f.DateKey     = d.DateKey
JOIN      dbo.dim_product          p  ON f.ProductKey  = p.ProductKey
JOIN      dbo.dim_supplier         s  ON f.SupplierKey = s.SupplierKey
JOIN      dbo.dim_location         l  ON f.LocationKey = l.LocationKey;
GO

-- VIEW 2: vw_export_received_po

CREATE VIEW dbo.vw_export_received_po AS
SELECT
    CONVERT(VARCHAR(10), d_sent.FullDate, 23)  AS SentDate,
    CONVERT(VARCHAR(10), d_rcvd.FullDate, 23)  AS ReceivedDate,

    p.SKU,
    RTRIM(p.ProductName)                        AS ProductName,
    p.ProductType,
    p.Brand,

    s.SupplierName,

    l.LocationName,

    f.PurchaseOrderCode,
    f.OrderedQty,
    f.ReceivedQty,
    f.UnfulfilledQty,
    f.LeadTimeDays
FROM      dbo.fact_received_purchase_orders  f
JOIN      dbo.dim_date     d_sent  ON f.SentDateKey     = d_sent.DateKey
JOIN      dbo.dim_date     d_rcvd  ON f.ReceivedDateKey = d_rcvd.DateKey
JOIN      dbo.dim_product  p       ON f.ProductKey      = p.ProductKey
JOIN      dbo.dim_supplier s       ON f.SupplierKey     = s.SupplierKey
JOIN      dbo.dim_location l       ON f.LocationKey     = l.LocationKey;
GO

-- VIEW 3: vw_export_sent_po

CREATE VIEW dbo.vw_export_sent_po AS
SELECT
    CONVERT(VARCHAR(10), d.FullDate, 23)  AS SentDate,
    d.WeekOfYear,
    d.MonthName,
    d.CalendarYear,

    p.SKU,
    RTRIM(p.ProductName)                  AS ProductName,
    p.ProductType,
    p.Brand,

    s.SupplierName,

    l.LocationName,

    f.PurchaseOrderCode,
    f.OrderedQty
FROM      dbo.fact_sent_purchase_orders  f
JOIN      dbo.dim_date     d   ON f.SentDateKey  = d.DateKey
JOIN      dbo.dim_product  p   ON f.ProductKey   = p.ProductKey
JOIN      dbo.dim_supplier s   ON f.SupplierKey  = s.SupplierKey
JOIN      dbo.dim_location l   ON f.LocationKey  = l.LocationKey;
GO

