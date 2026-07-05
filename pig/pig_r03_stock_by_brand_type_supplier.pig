-- pig_r03_stock_by_brand_type_supplier.pig - Business Requirement 3: Analysing stock levels by brand, product type, or supplier

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

-- ── Step 3: Use latest snapshot only (Day 3 = 2016-11-07) ─

latest = FILTER no_header BY FullDate == '2016-11-07';

-- ── Step 4: Project and cast numeric fields ───────────────
typed = FOREACH latest GENERATE
    Brand                                AS Brand,
    ProductType                          AS ProductType,
    SupplierName                         AS SupplierName,
    (int)    CurrentStockLevel           AS CurrentStockLevel,
    (double) StockValueAtCost            AS StockValueAtCost,
    (double) StockValueAtRetail          AS StockValueAtRetail;

-- ── Step 5a: Group by Brand ───────────────────────────────
by_brand_grp = GROUP typed BY Brand;
by_brand = FOREACH by_brand_grp GENERATE
    group                                AS Brand,
    SUM(typed.CurrentStockLevel)         AS TotalUnits,
    SUM(typed.StockValueAtCost)          AS TotalCostValue,
    SUM(typed.StockValueAtRetail)        AS TotalRetailValue,
    COUNT(typed)                         AS ProductLines;
by_brand_sorted = ORDER by_brand BY TotalRetailValue DESC;

-- ── Step 5b: Group by ProductType ────────────────────────
by_type_grp = GROUP typed BY ProductType;
by_type = FOREACH by_type_grp GENERATE
    group                                AS ProductType,
    SUM(typed.CurrentStockLevel)         AS TotalUnits,
    SUM(typed.StockValueAtCost)          AS TotalCostValue,
    SUM(typed.StockValueAtRetail)        AS TotalRetailValue,
    COUNT(typed)                         AS ProductLines;
by_type_sorted = ORDER by_type BY TotalRetailValue DESC;

-- ── Step 5c: Group by SupplierName ───────────────────────
by_supplier_grp = GROUP typed BY SupplierName;
by_supplier = FOREACH by_supplier_grp GENERATE
    group                                AS SupplierName,
    SUM(typed.CurrentStockLevel)         AS TotalUnits,
    SUM(typed.StockValueAtCost)          AS TotalCostValue,
    SUM(typed.StockValueAtRetail)        AS TotalRetailValue,
    COUNT(typed)                         AS ProductLines;
by_supplier_sorted = ORDER by_supplier BY TotalRetailValue DESC;

-- ── Step 6: Store all three results ──────────────────────
STORE by_brand_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r03_stock_by_brand'
    USING PigStorage(',');

STORE by_type_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r03_stock_by_type'
    USING PigStorage(',');

STORE by_supplier_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r03_stock_by_supplier'
    USING PigStorage(',');
