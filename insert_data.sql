USE ABC_DW;
GO

-- STEP 1 — dim_date

INSERT INTO dbo.dim_date
    (DateKey,  FullDate,     DateName,     DayOfWeek, DayNameOfWeek, DayOfYear, WeekOfYear, MonthName,  MonthOfYear, CalendarQuarter, CalendarYear)
VALUES
    (20151030, '2015-10-30', '2015/10/30', 6,         'Friday',       303,       44,         'October',  10,          4,               2015),
    (20161031, '2016-10-31', '2016/10/31', 2,         'Monday',       305,       44,         'October',  10,          4,               2016),
    (20161106, '2016-11-06', '2016/11/06', 1,         'Sunday',       311,       45,         'November', 11,          4,               2016),
    (20161107, '2016-11-07', '2016/11/07', 2,         'Monday',       312,       45,         'November', 11,          4,               2016),
    (20161108, '2016-11-08', '2016/11/08', 3,         'Tuesday',      313,       45,         'November', 11,          4,               2016),
    (20161116, '2016-11-16', '2016/11/16', 4,         'Wednesday',    321,       46,         'November', 11,          4,               2016),
    (20161117, '2016-11-17', '2016/11/17', 5,         'Thursday',     322,       46,         'November', 11,          4,               2016),
    (20161118, '2016-11-18', '2016/11/18', 6,         'Friday',       323,       46,         'November', 11,          4,               2016);
GO

-- STEP 2 — dim_supplier

INSERT INTO dbo.dim_supplier (SupplierName, Description, Phone, Email, Fax, Address, PostCode, City, Country)
VALUES
    ('SENNHEISER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('SONY',       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('JVC',        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('HAMA',       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('VIV',        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('TOSHIBA',    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('MSCS',       NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('ENE',        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('CANON',      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('Samsung',    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    ('HILLS',      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
GO

-- STEP 3 — dim_location

INSERT INTO dbo.dim_location (LocationName, LocationType, City, Country)
VALUES
    ('ABC Warehouse', 'Warehouse', 'London', 'United Kingdom');
GO

-- STEP 4 — dim_product

INSERT INTO dbo.dim_product
    (SupplierKey, SKU, ProductName, Description, Condition, ProductType, Brand, Tags, CostPrice, RetailPrice, MinStockLevel, IsActive, DateCreatedAt, DateDiscontinuedAt)
VALUES
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SENNHEISER'),
        'SEN23322', 'Manfrotto MN1004BAC Master Light Stand',
        'Master Light Stand', 'Display', 'ACCESSORY', 'SENNHEISER', 'TRIPODS',
        57.98, 114.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SENNHEISER'),
        'SEN222', 'Hoya 37S-HOY 37MM SKYLIGHT FILTER Hoya',
        '37MM SKYLIGHT FILTER Hoya', 'New', 'IMAGING', 'SENNHEISER', 'Discontinued, FILTERS',
        0.01, 19.89, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        'SO6677', 'Manfrotto MT057C3 Carbon Fibre 3 Section Geared',
        'Carbon Fibre 3 Section Geared', 'Display', 'ACCESSORY', 'SONY', 'TRIPODS',
        298.97, 584.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'JVC'),
        'JV2222', 'Rycote 37705 Portable Recorder Suspension',
        'Portable Recorder Suspension', 'New', 'CAMCORDER', 'JVC', 'CAMACC',
        0.00, 59.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'JVC'),
        'JVRRRR2', 'Rycote 55314 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'JVC'),
        'JV66622', 'Rycote 55412 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        'TOW222', 'HOYA 40.5mm CP Filter - Slim',
        'HOYA 40.5mm CP Filter - Slim', 'New', 'IMAGING', 'TOSHIBA', 'FILTERS',
        17.08, 34.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        'CO8211', 'Rycote 41126 Invision Video Hotshoe',
        'Invision Video Hotshoe', 'New', 'CAMCORDER', 'TOSHIBA', 'CAMACC',
        0.00, 49.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        'TOMCC', 'Hoya 46mm Slim PL-CIR (Circular Polarising) Filter',
        'HOYA 46mm CP Filter - Slim', 'New', 'IMAGING', 'Hoya', 'FILTERS',
        18.75, 34.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        'TOHDCC', 'Rycote 55409 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        'TO2333', 'Rycote 55417 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        'MS7771', 'Rycote 41118 Portable Recorder Suspension',
        'Portable Recorder Suspension', 'New', 'CAMCORDER', 'MSCS', 'CAMACC',
        0.00, 59.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        'CO2J111', 'Rycote 41127 Invision Video Hotshoe',
        'Invision Video Hotshoe', 'New', 'CAMCORDER', 'MSCS', 'CAMACC',
        0.00, 49.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        'SOL2222', 'Rycote 41128 Invision Video Hotshoe',
        'Invision Video Hotshoe', 'New', 'CAMCORDER', 'MSCS', 'CAMACC',
        0.00, 49.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        'SOl2211', 'Verbatim 43441 Light Scribe CD spindle',
        'Light Scribe CD spindle', 'New', 'ACCESSORY', 'MSCS', 'Discontinued, RECMEDIA',
        0.01, 7.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'CANON'),
        'CANI999', 'Rycote 55410 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'Samsung'),
        'SUM33444', 'Rycote 55384 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'Samsung'),
        'SAMrr22', 'Rycote 55430 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        'SO9999', 'Hoya Revo 52mm SMC UV Filter',
        'Hoya Revo 52mm SMC UV Filter', 'New', 'IMAGING', 'Hoya', 'FILTERS',
        20.40, 49.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        'SO777W', 'Rycote 55438 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    ),
    (
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        'SOY992', 'Rycote 55439 Full Windshield Kit',
        'Full Windshield Kit', 'New', 'ACCESSORY', 'Rycote', 'MICROPHONE',
        0.00, 429.99, 2, 1, '2015-05-10', NULL
    );
GO

-- STEP 5 — fact_daily_stock

INSERT INTO dbo.fact_daily_stock
    (DateKey, ProductKey, SupplierKey, LocationKey, CurrentStockLevel, CostPrice, RetailPrice)
SELECT
    20161031,
    p.ProductKey,
    p.SupplierKey,
    (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
    v.StockLevel,
    p.CostPrice,
    p.RetailPrice
FROM dbo.dim_product p
JOIN (VALUES
    ('SEN23322', 2),  ('SO6677',  5),  ('JV2222',  6),  ('SEN222',  18),
    ('TOW222',  8),   ('MS7771',  1),  ('CO8211',  8),  ('CO2J111',  3),
    ('SOL2222', 4),   ('SOl2211', 3),  ('TOMCC',   7),  ('SO9999',   8),
    ('JVRRRR2', 2),   ('SUM33444',6),  ('TOHDCC',  2),  ('CANI999',  3),
    ('JV66622', 10),  ('TO2333',  10), ('SAMrr22',  0), ('SO777W',   4),
    ('SOY992',  4)
) AS v(SKU, StockLevel)
ON p.SKU = v.SKU;
GO

INSERT INTO dbo.fact_daily_stock
    (DateKey, ProductKey, SupplierKey, LocationKey, CurrentStockLevel, CostPrice, RetailPrice)
SELECT
    20161106,
    p.ProductKey,
    p.SupplierKey,
    (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
    v.StockLevel,
    p.CostPrice,
    p.RetailPrice
FROM dbo.dim_product p
JOIN (VALUES
    ('SEN23322', 1),  ('SO6677',  3),  ('JV2222',  4),  ('SEN222',  13),
    ('TOW222',  4),   ('MS7771',  1),  ('CO8211',  8),  ('CO2J111',  3),
    ('SOL2222', 4),   ('SOl2211', 3),  ('TOMCC',   8),  ('SO9999',   8),
    ('JVRRRR2', 2),   ('SUM33444',6),  ('TOHDCC',  2),  ('CANI999',  2),
    ('JV66622', 10),  ('TO2333',  10), ('SAMrr22',  0), ('SO777W',   2),
    ('SOY992',  4)
) AS v(SKU, StockLevel)
ON p.SKU = v.SKU;
GO

INSERT INTO dbo.fact_daily_stock
    (DateKey, ProductKey, SupplierKey, LocationKey, CurrentStockLevel, CostPrice, RetailPrice)
SELECT
    20161107,
    p.ProductKey,
    p.SupplierKey,
    (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
    v.StockLevel,
    p.CostPrice,
    p.RetailPrice
FROM dbo.dim_product p
JOIN (VALUES
    ('SEN23322', 0),  ('SO6677',  3),  ('JV2222',  4),  ('SEN222',  10),
    ('TOW222',  4),   ('MS7771',  1),  ('CO8211',  8),  ('CO2J111',  3),
    ('SOL2222', 4),   ('SOl2211', 3),  ('TOMCC',   5),  ('SO9999',   8),
    ('JVRRRR2', 2),   ('SUM33444',6),  ('TOHDCC',  2),  ('CANI999',  4),
    ('JV66622', 5),   ('TO2333',  7),  ('SAMrr22',  2), ('SO777W',   2),
    ('SOY992',  4)
) AS v(SKU, StockLevel)
ON p.SKU = v.SKU;
GO

-- STEP 6 — fact_sent_purchase_orders

INSERT INTO dbo.fact_sent_purchase_orders
    (SentDateKey, ProductKey, SupplierKey, LocationKey, PurchaseOrderCode, OrderedQty)
VALUES
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'TOMCC'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 TOSHIBA CS PO 1', 3
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SO9999'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 SONY PO 1', 2
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'JVRRRR2'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'JVC'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 JVC CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SUM33444'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'Samsung'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 SUMSUNG CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'TOHDCC'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 TOSHIBA CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'CANI999'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'CANON'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 CANON CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'JV66622'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'JVC'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 JVC CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'TO2333'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 TOSHIBA CS PO 1', 5
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SAMrr22'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'Samsung'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 SAMSUNG CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SO777W'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 SONY CS PO 1', 1
    ),
    (
        20151030,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SOY992'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA301015 SONY CS PO 1', 2
    );
GO

-- STEP 7 — fact_received_purchase_orders

INSERT INTO dbo.fact_received_purchase_orders
    (SentDateKey, ReceivedDateKey, ProductKey, SupplierKey, LocationKey,
     PurchaseOrderCode, OrderedQty, ReceivedQty, LeadTimeDays)
VALUES
    (
        20161031, 20161106,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SEN23322'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SENNHEISER'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA311016 SENNHEISER PRO', 4, 4, 6
    ),
    (
        20161031, 20161106,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SO6677'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SONY'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA311016 SONY PRO', 2, 0, 6
    ),
    (
        20161031, 20161106,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'JV2222'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'JVC'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA311016 JVC PRO', 6, 6, 6
    ),
    (
        20161031, 20161106,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SEN222'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'SENNHEISER'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA311016 SENNHEISER PRO', 5, 5, 6
    ),
    (
        20161031, 20161106,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'TOW222'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA311016 TOSHIBA PRO', 2, 0, 6
    ),
    (
        20161116, 20161116,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'MS7771'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA1406', 1, 1, 0
    ),
    (
        20161116, 20161117,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'CO8211'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'TOSHIBA'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'PM1611COMPUBA02', 1, 1, 1
    ),
    (
        20161108, 20161117,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'CO2J111'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'PM0811COMPUB', 1, 1, 9
    ),
    (
        20161107, 20161118,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SOL2222'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA071116 SOLOCO', 4, 0, 11
    ),
    (
        20161107, 20161118,
        (SELECT ProductKey  FROM dbo.dim_product  WHERE SKU          = 'SOl2211'),
        (SELECT SupplierKey FROM dbo.dim_supplier WHERE SupplierName = 'MSCS'),
        (SELECT LocationKey FROM dbo.dim_location WHERE LocationName = 'ABC Warehouse'),
        'SA071116 SOLOCO', 1, 1, 11
    );
GO
