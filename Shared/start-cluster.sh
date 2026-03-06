#!/bin/bash
echo "Starting ZooKeeper..."
ssh hadoop@node01 "/usr/local/zookeeper/bin/zkServer.sh start"
ssh hadoop@node02 "/usr/local/zookeeper/bin/zkServer.sh start"
ssh hadoop@node03 "/usr/local/zookeeper/bin/zkServer.sh start"
sleep 3

echo "Starting JournalNodes..."
ssh hadoop@node01 "/usr/local/hadoop/bin/hdfs --daemon start journalnode"
ssh hadoop@node02 "/usr/local/hadoop/bin/hdfs --daemon start journalnode"
ssh hadoop@node03 "/usr/local/hadoop/bin/hdfs --daemon start journalnode"
sleep 3

echo "Starting NameNodes..."
ssh hadoop@node01 "/usr/local/hadoop/bin/hdfs --daemon start namenode"
ssh hadoop@node02 "/usr/local/hadoop/bin/hdfs --daemon start namenode"
sleep 5

echo "Starting ZKFC..."
ssh hadoop@node01 "/usr/local/hadoop/bin/hdfs --daemon start zkfc"
ssh hadoop@node02 "/usr/local/hadoop/bin/hdfs --daemon start zkfc"
sleep 3

echo "Starting DataNodes..."
ssh hadoop@node03 "/usr/local/hadoop/bin/hdfs --daemon start datanode"
ssh hadoop@node04 "/usr/local/hadoop/bin/hdfs --daemon start datanode"
ssh hadoop@node05 "/usr/local/hadoop/bin/hdfs --daemon start datanode"
sleep 3

echo "Starting ResourceManagers..."
ssh hadoop@node01 "/usr/local/hadoop/bin/yarn --daemon start resourcemanager"
ssh hadoop@node02 "/usr/local/hadoop/bin/yarn --daemon start resourcemanager"
sleep 3

echo "Starting NodeManagers..."
ssh hadoop@node03 "/usr/local/hadoop/bin/yarn --daemon start nodemanager"
ssh hadoop@node04 "/usr/local/hadoop/bin/yarn --daemon start nodemanager"
ssh hadoop@node05 "/usr/local/hadoop/bin/yarn --daemon start nodemanager"

echo "Cluster is up!"
