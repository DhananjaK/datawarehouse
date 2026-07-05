#!/usr/bin/env bash

set -euo pipefail

# ── Configuration ─────────────────────────────────────────
PIG_CONTAINER="dw-pig"
NAMENODE_CONTAINER="dw-namenode"
HOST_INPUT="/opt/datawarehouse/data/input"
PIG_INPUT="/pig/data/input"       
HDFS_RESULTS="/data/warehouse/pig_results"
SCRIPT_DIR="$(dirname "$0")"

echo "======================================================"
echo "  ABC DW — Apache Pig Business Requirements"
echo "======================================================"

# ── STEP 1: Copy all Pig scripts to shared mount ──────────
echo ""
echo "[Step 1] Copying .pig scripts to ${HOST_INPUT}/..."

declare -a SCRIPTS=(
    "pig_r01_daily_stock_levels.pig"
    "pig_r02_weekly_min_stock.pig"
    "pig_r03_stock_by_brand_type_supplier.pig"
    "pig_r04_orders_daily_weekly.pig"
    "pig_r05_received_by_supplier_month.pig"
)

for script in "${SCRIPTS[@]}"; do
    cp "${SCRIPT_DIR}/${script}" "${HOST_INPUT}/${script}"
    echo "  Copied: ${script}"
done
echo "  Done. Scripts now visible in container at ${PIG_INPUT}/"

# ── STEP 2: Clean all previous output directories ─────────
echo ""
echo "[Step 2] Removing existing Pig output directories in HDFS..."

docker exec "${NAMENODE_CONTAINER}" bash -c "
    hdfs dfs -mkdir -p ${HDFS_RESULTS}
    for dir in \
        r01_daily_stock_levels \
        r02_weekly_min_stock_detail \
        r02_weekly_min_stock_summary \
        r03_stock_by_brand \
        r03_stock_by_type \
        r03_stock_by_supplier \
        r04_sent_daily \
        r04_sent_weekly \
        r04_received_daily \
        r04_received_monthly \
        r05_received_by_supplier \
        r05_received_by_month \
        r05_received_by_supplier_month; do
        hdfs dfs -rm -r -f ${HDFS_RESULTS}/\${dir} 2>/dev/null || true
        echo \"  Cleared: ${HDFS_RESULTS}/\${dir}\"
    done
"
echo "  Done."

# ── STEP 3: Run each Pig script ───────────────────────────
run_pig() {
    local req="$1"
    local script="$2"
    local description="$3"
    echo ""
    echo "────────────────────────────────────────────────────"
    echo "  Req ${req}: ${description}"
    echo "  Script: ${script}"
    echo "────────────────────────────────────────────────────"
    docker exec "${PIG_CONTAINER}" \
        pig -x mapreduce "${PIG_INPUT}/${script}"
    echo "  [OK] ${script} completed."
}

run_pig "1" "pig_r01_daily_stock_levels.pig" \
    "Daily stock levels of all products"

run_pig "2" "pig_r02_weekly_min_stock.pig" \
    "Weekly report — products below minimum stock level"

run_pig "3" "pig_r03_stock_by_brand_type_supplier.pig" \
    "Stock analysis by brand, product type, and supplier"

run_pig "4" "pig_r04_orders_daily_weekly.pig" \
    "Daily and weekly sent and received purchase orders"

run_pig "5" "pig_r05_received_by_supplier_month.pig" \
    "Received orders by supplier and by month"

# ── STEP 4: Verify output — row counts + sample rows ──────
echo ""
echo "======================================================"
echo "  Results Summary"
echo "======================================================" 

show_result() {
    local label="$1"
    local hdfs_path="$2"
    local columns="$3"

    echo ""
    echo "  ${label}"
    echo "  Path:    ${hdfs_path}"
    echo "  Columns: ${columns}"

    local count
    count=$(docker exec "${NAMENODE_CONTAINER}" bash -c \
        "hdfs dfs -cat ${hdfs_path}/part-* 2>/dev/null | wc -l" || echo "0")
    echo "  Rows:    ${count}"
    echo "  Sample:"
    docker exec "${NAMENODE_CONTAINER}" bash -c \
        "hdfs dfs -cat ${hdfs_path}/part-* 2>/dev/null | head -5" \
        | sed 's/^/    /'
    echo "  ──────────────────────────────────────────────────"
}

show_result \
    "Req 1 — Daily stock levels" \
    "${HDFS_RESULTS}/r01_daily_stock_levels" \
    "FullDate, SKU, ProductName, ProductType, Brand, SupplierName, MinStockLevel, CurrentStockLevel, StockValueAtRetail, BelowMinStock"

show_result \
    "Req 2 — Min stock detail (per product per week)" \
    "${HDFS_RESULTS}/r02_weekly_min_stock_detail" \
    "CalendarYear, WeekOfYear, FullDate, SKU, ProductName, Brand, SupplierName, MinStockLevel, CurrentStockLevel"

show_result \
    "Req 2 — Min stock weekly summary (count by week)" \
    "${HDFS_RESULTS}/r02_weekly_min_stock_summary" \
    "CalendarYear, WeekOfYear, ProductsBelowMin"

show_result \
    "Req 3 — Stock by Brand" \
    "${HDFS_RESULTS}/r03_stock_by_brand" \
    "Brand, TotalUnits, TotalCostValue, TotalRetailValue, ProductLines"

show_result \
    "Req 3 — Stock by ProductType" \
    "${HDFS_RESULTS}/r03_stock_by_type" \
    "ProductType, TotalUnits, TotalCostValue, TotalRetailValue, ProductLines"

show_result \
    "Req 3 — Stock by Supplier" \
    "${HDFS_RESULTS}/r03_stock_by_supplier" \
    "SupplierName, TotalUnits, TotalCostValue, TotalRetailValue, ProductLines"

show_result \
    "Req 4 — Sent orders daily" \
    "${HDFS_RESULTS}/r04_sent_daily" \
    "SentDate, OrderLines, TotalQtyOrdered"

show_result \
    "Req 4 — Sent orders weekly" \
    "${HDFS_RESULTS}/r04_sent_weekly" \
    "CalendarYear, WeekOfYear, OrderLines, TotalQtyOrdered"

show_result \
    "Req 4 — Received orders daily" \
    "${HDFS_RESULTS}/r04_received_daily" \
    "ReceivedDate, OrderLines, TotalQtyOrdered, TotalQtyReceived, TotalUnfulfilled"

show_result \
    "Req 4 — Received orders monthly" \
    "${HDFS_RESULTS}/r04_received_monthly" \
    "YearMonth, OrderLines, TotalQtyOrdered, TotalQtyReceived, TotalUnfulfilled"

show_result \
    "Req 5 — Received by Supplier" \
    "${HDFS_RESULTS}/r05_received_by_supplier" \
    "SupplierName, OrderLines, TotalOrdered, TotalReceived, TotalUnfulfilled, MinLeadDays, MaxLeadDays, AvgLeadDays"

show_result \
    "Req 5 — Received by Month" \
    "${HDFS_RESULTS}/r05_received_by_month" \
    "YearMonth, OrderLines, TotalOrdered, TotalReceived, TotalUnfulfilled"

show_result \
    "Req 5 — Received by Supplier + Month" \
    "${HDFS_RESULTS}/r05_received_by_supplier_month" \
    "SupplierName, YearMonth, OrderLines, TotalOrdered, TotalReceived, TotalUnfulfilled, AvgLeadDays"

