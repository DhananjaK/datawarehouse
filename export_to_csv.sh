#!/usr/bin/env bash
set -euo pipefail

# ── Configuration ─────────────────────────────────────────
MSSQL_CONTAINER="dw-sqlserver"
NAMENODE_CONTAINER="dw-namenode"
BCP="/opt/mssql-tools18/bin/bcp"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SA_PASS='YourStrongE4TLPassword!'
CONTAINER_EXPORT_DIR="/tmp/dw_exports"
HOST_EXPORT_DIR="/opt/datawarehouse/data/input/dw_exports"
HDFS_DIR="/data/warehouse"

echo "======================================================"
echo "  ABC_DW  →  CSV  →  HDFS"
echo "======================================================"

# ── STEP 1: Copy SQL script into MSSQL container ──────────
echo ""
echo "[Step 1] Copying 03_create_export_views.sql to container..."
docker cp "$(dirname "$0")/03_create_export_views.sql" \
    "${MSSQL_CONTAINER}:/tmp/03_create_export_views.sql"
echo "  Done."

# ── STEP 2: Create export views in ABC_DW ─────────────────
echo ""
echo "[Step 2] Creating export views in ABC_DW..."
docker exec "${MSSQL_CONTAINER}" \
    ${SQLCMD} -S localhost -U sa -P "${SA_PASS}" -No \
    -i /tmp/03_create_export_views.sql
echo "  Views created."

# ── STEP 3: Export views to CSV (inside container) ────────
echo ""
echo "[Step 3] Exporting CSV files via bcp..."

docker exec "${MSSQL_CONTAINER}" bash -c "mkdir -p ${CONTAINER_EXPORT_DIR}"

# Helper function: export one view to CSV with header row
export_view() {
    local view_name="$1"
    local out_file="$2"
    local header_line="$3"

    echo "  Exporting ${view_name}..."

    # Write header row
    docker exec "${MSSQL_CONTAINER}" bash -c \
        "printf '%s\n' '${header_line}' > ${CONTAINER_EXPORT_DIR}/${out_file}"

    # Export data rows (bcp queryout — no header by default)
    docker exec "${MSSQL_CONTAINER}" \
        ${BCP} "SELECT * FROM ABC_DW.dbo.${view_name}" \
        queryout "${CONTAINER_EXPORT_DIR}/${out_file}.tmp" \
        -c -t "," -S localhost -U sa -P "${SA_PASS}" -Yo

    # Strip Windows carriage returns and append data to header
    docker exec "${MSSQL_CONTAINER}" bash -c \
        "tr -d '\r' < ${CONTAINER_EXPORT_DIR}/${out_file}.tmp \
         >> ${CONTAINER_EXPORT_DIR}/${out_file} \
         && rm ${CONTAINER_EXPORT_DIR}/${out_file}.tmp"

    local rows
    rows=$(docker exec "${MSSQL_CONTAINER}" bash -c \
        "wc -l < ${CONTAINER_EXPORT_DIR}/${out_file}")
    echo "    Written: ${out_file}  (${rows} lines incl. header)"
}

export_view \
    "vw_export_daily_stock" \
    "daily_stock.csv" \
    "FullDate,WeekOfYear,MonthName,CalendarYear,SKU,ProductName,ProductType,Brand,MinStockLevel,SupplierName,LocationName,CurrentStockLevel,CostPrice,RetailPrice,StockValueAtCost,StockValueAtRetail,BelowMinStock"

export_view \
    "vw_export_received_po" \
    "received_po.csv" \
    "SentDate,ReceivedDate,SKU,ProductName,ProductType,Brand,SupplierName,LocationName,PurchaseOrderCode,OrderedQty,ReceivedQty,UnfulfilledQty,LeadTimeDays"

export_view \
    "vw_export_sent_po" \
    "sent_po.csv" \
    "SentDate,WeekOfYear,MonthName,CalendarYear,SKU,ProductName,ProductType,Brand,SupplierName,LocationName,PurchaseOrderCode,OrderedQty"

echo ""
echo "  Files in container (${CONTAINER_EXPORT_DIR}):"
docker exec "${MSSQL_CONTAINER}" ls -lh "${CONTAINER_EXPORT_DIR}/"

# ── STEP 4: Copy CSV files to RHEL host ───────────────────
echo ""
echo "[Step 4] Copying CSV files to host (${HOST_EXPORT_DIR})..."
mkdir -p "${HOST_EXPORT_DIR}"

for f in daily_stock.csv received_po.csv sent_po.csv; do
    docker cp "${MSSQL_CONTAINER}:${CONTAINER_EXPORT_DIR}/${f}" \
        "${HOST_EXPORT_DIR}/${f}"
    echo "  Copied: ${HOST_EXPORT_DIR}/${f}"
done

# ── STEP 5: Copy CSV files into namenode container ────────
echo ""
echo "[Step 5] Copying CSV files into namenode container..."
docker exec "${NAMENODE_CONTAINER}" bash -c "mkdir -p /tmp/dw_exports"

for f in daily_stock.csv received_po.csv sent_po.csv; do
    docker cp "${HOST_EXPORT_DIR}/${f}" \
        "${NAMENODE_CONTAINER}:/tmp/dw_exports/${f}"
    echo "  Copied: ${f} → namenode:/tmp/dw_exports/"
done

# ── STEP 6: Put files into HDFS ───────────────────────────
echo ""
echo "[Step 6] Uploading to HDFS (${HDFS_DIR})..."

docker exec "${NAMENODE_CONTAINER}" bash -c "
    # Create HDFS directory if it doesn't exist
    hdfs dfs -mkdir -p ${HDFS_DIR}

    # Remove any existing files so re-runs don't error
    hdfs dfs -rm -f ${HDFS_DIR}/daily_stock.csv   2>/dev/null || true
    hdfs dfs -rm -f ${HDFS_DIR}/received_po.csv   2>/dev/null || true
    hdfs dfs -rm -f ${HDFS_DIR}/sent_po.csv       2>/dev/null || true

    # Upload
    hdfs dfs -put /tmp/dw_exports/daily_stock.csv  ${HDFS_DIR}/daily_stock.csv
    hdfs dfs -put /tmp/dw_exports/received_po.csv  ${HDFS_DIR}/received_po.csv
    hdfs dfs -put /tmp/dw_exports/sent_po.csv      ${HDFS_DIR}/sent_po.csv
"
echo "  Upload complete."

# ── STEP 7: Verify HDFS ───────────────────────────────────
echo ""
echo "[Step 7] Verifying HDFS contents..."
docker exec "${NAMENODE_CONTAINER}" hdfs dfs -ls -h "${HDFS_DIR}/"
echo ""
echo "  Preview — first 3 lines of daily_stock.csv in HDFS:"
docker exec "${NAMENODE_CONTAINER}" hdfs dfs -cat "${HDFS_DIR}/daily_stock.csv" | head -3
