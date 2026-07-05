#!/usr/bin/env bash

set -euo pipefail

DATA_ROOT="/opt/datawarehouse"

echo "=================================================="
echo " DW Stack Setup — RHEL 9 Server"
echo " Data root: ${DATA_ROOT}"
echo "=================================================="

# ── Must be root ────────────────────────────────────────────
if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: Run this script as root: sudo bash setup.sh"
  exit 1
fi

# ── 1. Create directory tree ────────────────────────────────
echo ""
echo "[1/4] Creating directory structure under ${DATA_ROOT}..."

directories=(
  "${DATA_ROOT}/postgres/data"
  "${DATA_ROOT}/hadoop/namenode"
  "${DATA_ROOT}/hadoop/datanode"
  "${DATA_ROOT}/airflow/dags"
  "${DATA_ROOT}/airflow/logs"
  "${DATA_ROOT}/airflow/plugins"
  "${DATA_ROOT}/airflow/scripts"
  "${DATA_ROOT}/spark/warehouse"
  "${DATA_ROOT}/hive/warehouse"
  "${DATA_ROOT}/pig/scripts"
  "${DATA_ROOT}/data/input"
  "${DATA_ROOT}/data/output"
)

for dir in "${directories[@]}"; do
  mkdir -p "$dir"
  echo "  Created: $dir"
done

echo "  Done."

# ── 2. Set ownership ────────────────────────────────────────
echo ""
echo "[2/4] Setting ownership..."

chown -R 50000:0 "${DATA_ROOT}/airflow"
chown -R 50000:0 "${DATA_ROOT}/spark"
chown -R root:root "${DATA_ROOT}/hadoop"
chown -R root:root "${DATA_ROOT}/hive"
chown -R root:root "${DATA_ROOT}/pig"
chown -R 999:999   "${DATA_ROOT}/postgres"
chmod -R 755       "${DATA_ROOT}/data"

echo "  Done."

# ── 3. SELinux labels ───────────────────────────────────────
echo ""
echo "[3/4] Applying SELinux container_file_t labels..."

if command -v chcon &>/dev/null; then
  chcon -R -t container_file_t "${DATA_ROOT}"
  echo "  SELinux labels applied."
else
  echo "  WARN: chcon not found — skipping SELinux labelling."
fi

# ── 4. Firewall rules ───────────────────────────────────────
echo ""
echo "[4/4] Opening firewall ports for remote access..."

if command -v firewall-cmd &>/dev/null; then
  ports=(
    "5432/tcp"   # PostgreSQL
    "1433/tcp"   # MSSQL
    "50070/tcp"  # Hadoop NameNode Web UI (Hadoop 2.x)
    "9000/tcp"   # HDFS RPC
    "9083/tcp"   # Hive Metastore (thrift)
    "10000/tcp"  # HiveServer2 JDBC
    "10002/tcp"  # Hive Web UI
    "8080/tcp"   # Airflow Web UI
    "8081/tcp"   # Spark Master Web UI
    "7077/tcp"   # Spark submit
  )

  for port in "${ports[@]}"; do
    firewall-cmd --permanent --add-port="${port}" && echo "  Opened: ${port}"
  done

  firewall-cmd --reload
  echo "  Firewall reloaded."
else
  echo "  WARN: firewall-cmd not found — skipping firewall rules."
  echo "  Manually open ports: 5432 1433 50070 9000 9083 10000 10002 8080 8081 7077"
fi

# ── Summary ─────────────────────────────────────────────────
echo ""
echo "=================================================="
echo " Setup complete. Next steps:"
echo ""
echo " 1. Copy your project files to the server:"
echo "    scp -r ./* root@10.10.20.134:/opt/dw-project/"
echo ""
echo " 2. On the server, from your project directory:"
echo "    docker compose up --build -d"
echo ""
echo " 3. Check container health:"
echo "    docker compose ps"
echo "    docker compose logs -f namenode"
echo ""
echo " 4. Access UIs remotely:"
echo "    Airflow:     http://10.10.20.134:8080  (airflow/airflow)"
echo "    Spark:       http://10.10.20.134:8081"
echo "    HDFS:        http://10.10.20.134:50070"
echo "    Hive Web:    http://10.10.20.134:10002"
echo "    PostgreSQL:  10.10.20.134:5432         (airflow/airflow_secure_2024)"
echo "    MSSQL:       10.10.20.134:1433         (sa/YourStrongE4TLPassword!)"
echo "=================================================="
