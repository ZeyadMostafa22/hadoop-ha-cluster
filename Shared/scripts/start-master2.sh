#!/bin/bash
echo "=== Starting Master2 (Standby NameNode) ==="

# Start SSH
service ssh start

# Start ZooKeeper
echo "Starting ZooKeeper..."
/usr/local/zookeeper/bin/zkServer.sh start
sleep 3

# Start JournalNode
echo "Starting JournalNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start journalnode"
sleep 5

# Bootstrap Standby only if not already done
if [ ! -f /usr/local/hadoop/data/namenode/current/VERSION ]; then
    echo "Bootstrapping Standby NameNode..."
    su - hadoop -c "/usr/local/hadoop/bin/hdfs namenode -bootstrapStandby -force"
fi

# Start NameNode
echo "Starting Standby NameNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start namenode"
sleep 5

# Start ZKFC
echo "Starting ZKFC..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start zkfc"
sleep 3

# Start ResourceManager
echo "Starting ResourceManager..."
su - hadoop -c "/usr/local/hadoop/bin/yarn --daemon start resourcemanager"

echo "=== Master2 is ready ==="
sleep infinity
