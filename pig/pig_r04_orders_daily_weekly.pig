-- pig_r04_orders_daily_weekly.pig - Business Requirement 4: Daily and weekly sent and received stock orders for the last four weeks

-- ── Step 1: Load sent_po CSV from HDFS ───────────────────
sent_raw = LOAD 'hdfs://namenode:9000/data/warehouse/sent_po/sent_po.csv'
      USING PigStorage(',')
      AS (
          SentDate:chararray,
          WeekOfYear:chararray,
          MonthName:chararray,
          CalendarYear:chararray,
          SKU:chararray,
          ProductName:chararray,
          ProductType:chararray,
          Brand:chararray,
          SupplierName:chararray,
          LocationName:chararray,
          PurchaseOrderCode:chararray,
          OrderedQty:chararray
      );

-- ── Step 2: Drop header ───────────────────────────────────
sent_no_hdr = FILTER sent_raw BY SentDate != 'SentDate';

-- ── Step 3: Project and cast ──────────────────────────────
sent_typed = FOREACH sent_no_hdr GENERATE
    SentDate                             AS SentDate,
    (int) CalendarYear                   AS CalendarYear,
    (int) WeekOfYear                     AS WeekOfYear,
    (int) OrderedQty                     AS OrderedQty;

-- ── Step 4a: Daily sent orders ────────────────────────────
sent_daily_grp = GROUP sent_typed BY SentDate;
sent_daily = FOREACH sent_daily_grp GENERATE
    group                                AS SentDate,
    COUNT(sent_typed)                    AS OrderLines,
    SUM(sent_typed.OrderedQty)           AS TotalQtyOrdered;
sent_daily_sorted = ORDER sent_daily BY SentDate ASC;

-- ── Step 4b: Weekly sent orders ──────────────────────────
sent_weekly_grp = GROUP sent_typed BY (CalendarYear, WeekOfYear);
sent_weekly = FOREACH sent_weekly_grp GENERATE
    FLATTEN(group)                       AS (CalendarYear, WeekOfYear),
    COUNT(sent_typed)                    AS OrderLines,
    SUM(sent_typed.OrderedQty)           AS TotalQtyOrdered;
sent_weekly_sorted = ORDER sent_weekly BY CalendarYear ASC, WeekOfYear ASC;

-- ── Step 5: Load received_po CSV from HDFS ───────────────
rcvd_raw = LOAD 'hdfs://namenode:9000/data/warehouse/received_po/received_po.csv'
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

-- ── Step 6: Drop header ───────────────────────────────────
rcvd_no_hdr = FILTER rcvd_raw BY SentDate != 'SentDate';

-- ── Step 7: Project and cast ──────────────────────────────

rcvd_typed = FOREACH rcvd_no_hdr GENERATE
    ReceivedDate                         AS ReceivedDate,
    SUBSTRING(ReceivedDate, 0, 7)        AS YearMonth,
    (int) OrderedQty                     AS OrderedQty,
    (int) ReceivedQty                    AS ReceivedQty,
    (int) UnfulfilledQty                 AS UnfulfilledQty;

-- ── Step 8a: Daily received orders ───────────────────────
rcvd_daily_grp = GROUP rcvd_typed BY ReceivedDate;
rcvd_daily = FOREACH rcvd_daily_grp GENERATE
    group                                AS ReceivedDate,
    COUNT(rcvd_typed)                    AS OrderLines,
    SUM(rcvd_typed.OrderedQty)           AS TotalQtyOrdered,
    SUM(rcvd_typed.ReceivedQty)          AS TotalQtyReceived,
    SUM(rcvd_typed.UnfulfilledQty)       AS TotalUnfulfilled;
rcvd_daily_sorted = ORDER rcvd_daily BY ReceivedDate ASC;

-- ── Step 8b: Weekly received — grouped by YearMonth proxy ─

rcvd_monthly_grp = GROUP rcvd_typed BY YearMonth;
rcvd_monthly = FOREACH rcvd_monthly_grp GENERATE
    group                                AS YearMonth,
    COUNT(rcvd_typed)                    AS OrderLines,
    SUM(rcvd_typed.OrderedQty)           AS TotalQtyOrdered,
    SUM(rcvd_typed.ReceivedQty)          AS TotalQtyReceived,
    SUM(rcvd_typed.UnfulfilledQty)       AS TotalUnfulfilled;
rcvd_monthly_sorted = ORDER rcvd_monthly BY YearMonth ASC;

-- ── Step 9: Store all four outputs ───────────────────────
STORE sent_daily_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r04_sent_daily'
    USING PigStorage(',');

STORE sent_weekly_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r04_sent_weekly'
    USING PigStorage(',');

STORE rcvd_daily_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r04_received_daily'
    USING PigStorage(',');

STORE rcvd_monthly_sorted
    INTO 'hdfs://namenode:9000/data/warehouse/pig_results/r04_received_monthly'
    USING PigStorage(',');
