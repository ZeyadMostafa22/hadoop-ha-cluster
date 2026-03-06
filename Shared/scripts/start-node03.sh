#!/bin/bash
echo "=== Starting Node03 ==="

# Start SSH
service ssh start

# Start ZooKeeper
echo "Starting ZooKeeper..."
/usr/local/zookeeper/bin/zkServer.sh start
sleep 3

# Start JournalNode
echo "Starting JournalNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start journalnode"
sleep 3

# Start DataNode
echo "Starting DataNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start datanode"
sleep 3

# Start NodeManager
echo "Starting NodeManager..."
su - hadoop -c "/usr/local/hadoop/bin/yarn --daemon start nodemanager"

echo "=== Node03 is ready ==="
sleep infinity
