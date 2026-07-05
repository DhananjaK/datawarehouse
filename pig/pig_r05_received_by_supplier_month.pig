-- pig_r05_received_by_supplier_month.pig - Business Requirement 5: Analysing received stock orders by supplier and by month

-- ── Step 1: Load received_po CSV from HDFS ────────────────
raw = LOAD 'hdfs://namenode:9000/data/warehouse/received_po/received_po.csv'
      USING PigStorage(',')
      AS (
          SentDate:chararray,
          ReceivedDate:chararray,
          SKU:chararray,
          ProductName:chararray,
          ProductType:chararray,
          Brand:chararray,
          SupplierName:chararray,
          LocationName:chararray,
          PurchaseOrderCode:chararray,
          OrderedQty:chararray,
          ReceivedQty:chararray,
          UnfulfilledQty:chararray,
          LeadTimeDays:chararray
      );

-- ── Step 2: Drop the CSV header row ──────────────────────
no_header = FILTER raw BY SentDate != 'SentDate';

-- ── Step 3: Project, cast numerics, and extract YearMonth ─

typed = FOREACH no_header GENERATE
    SupplierName                         AS SupplierName,
    SUBSTRING(ReceivedDate, 0, 7)        AS YearMonth,
    (int) OrderedQty                     AS OrderedQty,
    (int) ReceivedQty                    AS ReceivedQty,
    (int) UnfulfilledQty                 AS UnfulfilledQty,
    (int) LeadTimeDays                   AS LeadTimeDays;

-- ── Step 4a: Aggregate by Supplier ───────────────────────
by_supplier_grp = GROUP typed BY SupplierName;
by_supplier = FOREACH by_supplier_grp GENERATE
    group                                AS SupplierName,
    COUNT(typed)                         AS OrderLines,
    SUM(typed.OrderedQty)                AS TotalOrdered,
    SUM(typed.ReceivedQty)               AS TotalReceived,
    SUM(typed.UnfulfilledQty)            AS TotalUnfulfilled,
    MIN(typed.LeadTimeDays)              AS MinLeadDays,
    MAX(typed.LeadTimeDays)              AS MaxLeadDays,
    AVG(typed.LeadTimeDays)              AS AvgLeadDays;
by_supplier_sorted = ORDER by_supplier BY SupplierName ASC;

-- ── Step 4b: Aggregate by Month (YYYY-MM) ────────────────
by_month_grp = GROUP typed BY YearMonth;
by_month = FOREACH by_month_grp GENERATE
    group                                AS YearMonth,
    COUNT(typed)                         AS OrderLines,
    SUM(typed.OrderedQty)                AS TotalOrdered,
    SUM(typed.ReceivedQty)               AS TotalReceived,
    SUM(typed.UnfulfilledQty)            AS TotalUnfulfilled;
by_month_sorted = ORDER by_month BY YearMonth ASC;

-- ── Step 4c: Aggregate by Supplier AND Month ─────────────
by_sup_mon_grp = GROUP typed BY (SupplierName, YearMonth);
by_sup_mon = FOREACH by_sup_mon_grp GENERATE
    FLATTEN(group)                       AS (SupplierName, YearMonth),
    COUNT(typed)                         AS OrderLines,
    SUM(typed.OrderedQty)                AS TotalOrdered,
    SUM(typed.ReceivedQty)               AS TotalReceived,
    SUM(typed.UnfulfilledQty)            AS TotalUnfulfilled,
    AVG(typed.LeadTimeDays)              AS AvgLeadDays;
by_sup_mon_sorted = ORDER by_sup_mon BY SupplierName ASC, YearMonth ASC;

-- ── Step 5: Store all three outputs ──────────────────────
STORE by_supplier_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r05_received_by_supplier'
    USING PigStorage(',');

STORE by_month_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r05_received_by_month'
    USING PigStorage(',');

STORE by_sup_mon_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r05_received_by_supplier_month'
    USING PigStorage(',');
