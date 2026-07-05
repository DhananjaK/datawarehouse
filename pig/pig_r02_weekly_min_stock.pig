-- pig_r02_weekly_min_stock.pig - Business Requirement 2: Weekly report of all products with minimum stock levels

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

-- ── Step 3: Keep only rows flagged as below minimum ───────

below_min = FILTER no_header BY BelowMinStock == 'YES';

-- ── Step 4: Project and cast for output ───────────────────
typed = FOREACH below_min GENERATE
    (int) CalendarYear                   AS CalendarYear,
    (int) WeekOfYear                     AS WeekOfYear,
    FullDate                             AS FullDate,
    SKU                                  AS SKU,
    ProductName                          AS ProductName,
    Brand                                AS Brand,
    SupplierName                         AS SupplierName,
    (int) MinStockLevel                  AS MinStockLevel,
    (int) CurrentStockLevel              AS CurrentStockLevel;

-- ── Step 5: Weekly summary — count products below min ─────
by_week = GROUP typed BY (CalendarYear, WeekOfYear);
weekly_summary = FOREACH by_week GENERATE
    FLATTEN(group)                       AS (CalendarYear, WeekOfYear),
    COUNT(typed)                         AS ProductsBelowMin;
weekly_sorted = ORDER weekly_summary BY CalendarYear ASC, WeekOfYear ASC;

-- ── Step 6: Detail view — sort by week then SKU ───────────
detail_sorted = ORDER typed BY CalendarYear ASC, WeekOfYear ASC, SKU ASC;

-- ── Step 7: Store both outputs ────────────────────────────
STORE detail_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r02_weekly_min_stock_detail'
    USING PigStorage(',');

STORE weekly_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r02_weekly_min_stock_summary'
    USING PigStorage(',');