#!/bin/bash
echo "=== Starting Worker ==="

# Start SSH
service ssh start
sleep 3

# Start DataNode
echo "Starting DataNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start datanode"
sleep 3

# Start NodeManager
echo "Starting NodeManager..."
su - hadoop -c "/usr/local/hadoop/bin/yarn --daemon start nodemanager"

echo "=== Worker is ready ==="
sleep infinity
