-- pig_02_stock_value_by_type.pig - Pig Script 2: Total Stock Value by Product Type

-- ── Step 1: Load ──────────────────────────────────────────
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

-- ── Step 2: Drop header ───────────────────────────────────
no_header = FILTER raw BY FullDate != 'FullDate';

-- ── Step 3: Latest snapshot only (Day 3 = 2016-11-07) ────
latest = FILTER no_header BY FullDate == '2016-11-07';

-- ── Step 4: Project and cast to numeric types ─────────────
typed = FOREACH latest GENERATE
    ProductType                      AS ProductType,
    SupplierName                     AS SupplierName,
    (int)    CurrentStockLevel       AS CurrentStockLevel,
    (double) StockValueAtCost        AS StockValueAtCost,
    (double) StockValueAtRetail      AS StockValueAtRetail;

-- ── Step 5: Group by ProductType and SupplierName ─────────
grouped = GROUP typed BY (ProductType, SupplierName);

-- ── Step 6: Aggregate per group ───────────────────────────
summary = FOREACH grouped GENERATE
    FLATTEN(group)                        AS (ProductType, SupplierName),
    SUM(typed.StockValueAtCost)           AS TotalCostValue,
    SUM(typed.StockValueAtRetail)         AS TotalRetailValue,
    SUM(typed.CurrentStockLevel)          AS TotalUnits,
    COUNT(typed)                          AS ProductLines;

-- ── Step 7: Sort by ProductType asc, TotalRetailValue desc ─
sorted = ORDER summary BY ProductType ASC, TotalRetailValue DESC;

-- ── Step 8: Store ─────────────────────────────────────────
STORE sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/stock_by_type'
    USING PigStorage(',');
