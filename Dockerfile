FROM apache/airflow:2.10.4-python3.10

USER root

# Install OpenJDK-17 and build tools
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk-headless wget curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Java Home
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Apache Spark (using Spark 3.5.1 compiled with Hadoop 3)
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

ENV PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# Download SQL Server JDBC Driver
RUN wget -q https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.4.2.jre11/mssql-jdbc-12.4.2.jre11.jar \
    -P ${SPARK_HOME}/jars/

# NEW: Pre-create Spark work directories and give ownership to airflow user
RUN mkdir -p ${SPARK_HOME}/work ${SPARK_HOME}/spark-warehouse && \
    chown -R airflow:root ${SPARK_HOME}

# Switch back to airflow user
USER airflow

# Only install PySpark here
RUN pip install --no-cache-dir pyspark==${SPARK_VERSION}