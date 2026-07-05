-- ── Setup database ────────────────────────────────────────
DROP DATABASE IF EXISTS abc_dw CASCADE;

CREATE DATABASE abc_dw
COMMENT 'ABC Consumer Electronics Data Warehouse — Big Data Layer';

USE abc_dw;

-- TABLE 1: daily_stock

CREATE EXTERNAL TABLE IF NOT EXISTS daily_stock (
    FullDate            STRING      COMMENT 'Snapshot date (YYYY-MM-DD)',
    WeekOfYear          INT         COMMENT 'ISO week number',
    MonthName           STRING,
    CalendarYear        INT,
    SKU                 STRING      COMMENT 'Product business key',
    ProductName         STRING,
    ProductType         STRING      COMMENT 'ACCESSORY | CAMCORDER | IMAGING',
    Brand               STRING,
    MinStockLevel       INT         COMMENT 'Reorder threshold',
    SupplierName        STRING,
    LocationName        STRING,
    CurrentStockLevel   INT,
    CostPrice           DECIMAL(10,2),
    RetailPrice         DECIMAL(10,2),
    StockValueAtCost    DECIMAL(14,2) COMMENT 'CurrentStockLevel x CostPrice',
    StockValueAtRetail  DECIMAL(14,2) COMMENT 'CurrentStockLevel x RetailPrice',
    BelowMinStock       STRING      COMMENT 'YES if CurrentStockLevel <= MinStockLevel'
)
COMMENT 'Daily inventory snapshot — denormalised from MSSQL ABC_DW'
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  LINES  TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/data/warehouse/daily_stock'
TBLPROPERTIES ('skip.header.line.count'='1');

-- TABLE 2: received_po

CREATE EXTERNAL TABLE IF NOT EXISTS received_po (
    SentDate            STRING      COMMENT 'Date PO was sent (YYYY-MM-DD)',
    ReceivedDate        STRING      COMMENT 'Date PO was received (YYYY-MM-DD)',
    SKU                 STRING,
    ProductName         STRING,
    ProductType         STRING,
    Brand               STRING,
    SupplierName        STRING,
    LocationName        STRING,
    PurchaseOrderCode   STRING      COMMENT 'Degenerate dimension — PO reference',
    OrderedQty          INT,
    ReceivedQty         INT,
    UnfulfilledQty      INT         COMMENT 'OrderedQty - ReceivedQty',
    LeadTimeDays        INT         COMMENT 'Days between SentDate and ReceivedDate'
)
COMMENT 'Received purchase orders — denormalised from MSSQL ABC_DW'
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  LINES  TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/data/warehouse/received_po'
TBLPROPERTIES ('skip.header.line.count'='1');

-- TABLE 3: sent_po

CREATE EXTERNAL TABLE IF NOT EXISTS sent_po (
    SentDate            STRING      COMMENT 'Date PO was sent (YYYY-MM-DD)',
    WeekOfYear          INT,
    MonthName           STRING,
    CalendarYear        INT,
    SKU                 STRING,
    ProductName         STRING,
    ProductType         STRING,
    Brand               STRING,
    SupplierName        STRING,
    LocationName        STRING,
    PurchaseOrderCode   STRING      COMMENT 'Degenerate dimension — PO reference',
    OrderedQty          INT
)
COMMENT 'Sent purchase orders — denormalised from MSSQL ABC_DW'
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  LINES  TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/data/warehouse/sent_po'
TBLPROPERTIES ('skip.header.line.count'='1');

-- ── Sanity check ─────────────────────────────────────────
SHOW TABLES;
