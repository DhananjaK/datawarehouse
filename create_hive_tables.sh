#!/usr/bin/env bash
set -euo pipefail

NAMENODE_CONTAINER="dw-namenode"
HIVE_CONTAINER="dw-hive-server"
HDFS_BASE="/data/warehouse"
BEELINE="beeline -u 'jdbc:hive2://localhost:10000' --silent=true"

# ── STEP 1: Reorganise HDFS into subdirectories ───────────

echo ""
echo "[Step 1] Reorganising HDFS: moving CSVs into subdirectories..."

docker exec "${NAMENODE_CONTAINER}" bash -c "
    # Create subdirectories
    hdfs dfs -mkdir -p ${HDFS_BASE}/daily_stock
    hdfs dfs -mkdir -p ${HDFS_BASE}/received_po
    hdfs dfs -mkdir -p ${HDFS_BASE}/sent_po

    # Move files (idempotent: remove target first if re-running)
    hdfs dfs -rm -f ${HDFS_BASE}/daily_stock/daily_stock.csv 2>/dev/null || true
    hdfs dfs -rm -f ${HDFS_BASE}/received_po/received_po.csv 2>/dev/null || true
    hdfs dfs -rm -f ${HDFS_BASE}/sent_po/sent_po.csv         2>/dev/null || true

    hdfs dfs -mv ${HDFS_BASE}/daily_stock.csv  ${HDFS_BASE}/daily_stock/daily_stock.csv
    hdfs dfs -mv ${HDFS_BASE}/received_po.csv  ${HDFS_BASE}/received_po/received_po.csv
    hdfs dfs -mv ${HDFS_BASE}/sent_po.csv      ${HDFS_BASE}/sent_po/sent_po.csv
"

echo "  HDFS layout after reorganisation:"
docker exec "${NAMENODE_CONTAINER}" hdfs dfs -ls -R "${HDFS_BASE}/"

# ── STEP 2: Copy HQL script into Hive container ───────────
echo ""
echo "[Step 2] Copying HQL script to Hive container..."
docker cp "$(dirname "$0")/04_create_hive_tables.hql" \
    "${HIVE_CONTAINER}:/tmp/04_create_hive_tables.hql"
echo "  Done."

# ── STEP 3: Create Hive database + external tables ────────
echo ""
echo "[Step 3] Creating Hive database and external tables..."
docker exec "${HIVE_CONTAINER}" bash -c \
    "beeline -u 'jdbc:hive2://localhost:10000' --silent=true \
     -f /tmp/04_create_hive_tables.hql"
echo "  Tables created."

# ── STEP 4: Verify — row counts and sample data ───────────
echo ""
echo "[Step 4] Verifying Hive tables..."

verify_table() {
    local table="$1"
    echo ""
    echo "  ── ${table} ──"
    docker exec "${HIVE_CONTAINER}" bash -c \
        "beeline -u 'jdbc:hive2://localhost:10000' --silent=true \
         -e 'USE abc_dw; SELECT COUNT(*) AS row_count FROM ${table};'"
    docker exec "${HIVE_CONTAINER}" bash -c \
        "beeline -u 'jdbc:hive2://localhost:10000' --silent=true \
         -e 'USE abc_dw; SELECT * FROM ${table} LIMIT 2;'"
}

verify_table "daily_stock"
verify_table "received_po"
verify_table "sent_po"


