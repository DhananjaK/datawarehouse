-- pig_03_supplier_lead_times.pig — Pig Script 3: Supplier Lead Time Analysis

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

-- ── Step 2: Drop header row ───────────────────────────────
no_header = FILTER raw BY SentDate != 'SentDate';

-- ── Step 3: Cast numeric fields ───────────────────────────
typed = FOREACH no_header GENERATE
    SupplierName                     AS SupplierName,
    SKU                              AS SKU,
    PurchaseOrderCode                AS PurchaseOrderCode,
    (int) OrderedQty                 AS OrderedQty,
    (int) ReceivedQty                AS ReceivedQty,
    (int) UnfulfilledQty             AS UnfulfilledQty,
    (int) LeadTimeDays               AS LeadTimeDays;

-- ── Step 4: Group by supplier ─────────────────────────────
by_supplier = GROUP typed BY SupplierName;

-- ── Step 5: Compute lead time statistics ──────────────────
lead_times = FOREACH by_supplier GENERATE
    group                             AS SupplierName,
    COUNT(typed)                      AS OrderLines,
    MIN(typed.LeadTimeDays)           AS MinLeadDays,
    MAX(typed.LeadTimeDays)           AS MaxLeadDays,
    AVG(typed.LeadTimeDays)           AS AvgLeadDays,
    SUM(typed.OrderedQty)             AS TotalOrdered,
    SUM(typed.ReceivedQty)            AS TotalReceived,
    SUM(typed.UnfulfilledQty)         AS TotalUnfulfilled;

-- ── Step 6: Sort by average lead time ascending ───────────
sorted = ORDER lead_times BY AvgLeadDays ASC;

-- ── Step 7: Store results to HDFS ─────────────────────────
STORE sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/supplier_lead_times'
    USING PigStorage(',');
