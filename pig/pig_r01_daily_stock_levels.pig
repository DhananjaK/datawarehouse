-- pig_r01_daily_stock_levels.pig - Business Requirement 1: Daily stock levels of all products for the last month

-- ── Step 1: Load daily_stock CSV from HDFS ────────────────

raw = LOAD 'hdfs://namenode:9000/data/warehouse/daily_stock/daily_stock.csv'
      USING PigStorage(',')
      AS (
          FullDate:chararray,
          WeekOfYear:chararray,
          MonthName:chararray,
          CalendarYear:chararray,
          SKU:chararray,
          ProductName:chararray,
          ProductType:chararray,
          Brand:chararray,
          MinStockLevel:chararray,
          SupplierName:chararray,
          LocationName:chararray,
          CurrentStockLevel:chararray,
          CostPrice:chararray,
          RetailPrice:chararray,
          StockValueAtCost:chararray,
          StockValueAtRetail:chararray,
          BelowMinStock:chararray
      );

-- ── Step 2: Drop the CSV header row ──────────────────────
no_header = FILTER raw BY FullDate != 'FullDate';

-- ── Step 3: Project required columns and cast numerics ───
result = FOREACH no_header GENERATE
    FullDate                             AS FullDate,
    SKU                                  AS SKU,
    ProductName                          AS ProductName,
    ProductType                          AS ProductType,
    Brand                                AS Brand,
    SupplierName                         AS SupplierName,
    (int)    MinStockLevel               AS MinStockLevel,
    (int)    CurrentStockLevel           AS CurrentStockLevel,
    (double) StockValueAtRetail          AS StockValueAtRetail,
    BelowMinStock                        AS BelowMinStock;

-- ── Step 4: Sort by date then SKU ────────────────────────
sorted = ORDER result BY FullDate ASC, SKU ASC;

-- ── Step 5: Write results to HDFS ────────────────────────
STORE sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r01_daily_stock_levels'
    USING PigStorage(',');

