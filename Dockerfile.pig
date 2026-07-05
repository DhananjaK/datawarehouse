# Apache Pig — Standalone Container

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install JDK and utilities
RUN apt-get update && \
    apt-get install -y \
      openjdk-17-jdk-headless \
      wget \
      curl \
      python3 \
      python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# --- Install Apache Pig 0.17.0 ------------------------------
ENV PIG_VERSION=0.17.0
ENV PIG_HOME=/opt/pig

RUN wget -q https://archive.apache.org/dist/pig/pig-${PIG_VERSION}/pig-${PIG_VERSION}.tar.gz && \
    tar -xzf pig-${PIG_VERSION}.tar.gz && \
    mv pig-${PIG_VERSION} ${PIG_HOME} && \
    rm pig-${PIG_VERSION}.tar.gz

ENV PATH=$PATH:${PIG_HOME}/bin

# --- Hadoop conf so Pig can connect to HDFS -----------------
# HADOOP_CONF_DIR is picked up by Pig automatically
ENV HADOOP_CONF_DIR=/pig/conf

# Working directories
RUN mkdir -p /pig/scripts /pig/data /pig/conf

WORKDIR /pig/scripts

# Default: keep container alive so you can exec into it and run
# pig scripts manually or via Airflow BashOperator
CMD ["tail", "-f", "/dev/null"]
