-- pig_01_stock_below_min.pig - Pig Script 1: Products Below Minimum Stock Level

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

-- ── Step 2: Remove the CSV header row ────────────────────
no_header = FILTER raw BY FullDate != 'FullDate';

-- ── Step 3: Restrict to latest snapshot + below-min flag ──

below_min = FILTER no_header BY
    FullDate      == '2016-11-07'
    AND BelowMinStock == 'YES';

-- ── Step 4: Project and cast columns needed for output ────
result = FOREACH below_min GENERATE
    SKU                              AS SKU,
    ProductName                      AS ProductName,
    ProductType                      AS ProductType,
    SupplierName                     AS SupplierName,
    (int)    MinStockLevel           AS MinStockLevel,
    (int)    CurrentStockLevel       AS CurrentStockLevel,
    (double) StockValueAtRetail      AS StockValueAtRetail;

-- ── Step 5: Sort by supplier then SKU ─────────────────────
sorted = ORDER result BY SupplierName ASC, SKU ASC;

-- ── Step 6: Write results to HDFS ────────────────────────
STORE sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/stock_below_min'
    USING PigStorage(',');
