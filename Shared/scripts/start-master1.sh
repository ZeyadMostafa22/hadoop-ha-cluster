#!/bin/bash
echo "=== Starting Master1 (Active NameNode) ==="

# Start SSH
service ssh start

# Start ZooKeeper
echo "Starting ZooKeeper..."
/usr/local/zookeeper/bin/zkServer.sh start
sleep 3

# Start JournalNode
echo "Starting JournalNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start journalnode"

# Wait for all 3 JournalNodes to be ready
echo "Waiting for all JournalNodes to be ready..."
while ! (nc -z node01 8485 && nc -z node02 8485 && nc -z node03 8485); do
    echo "Waiting for JournalNodes..."
    sleep 3
done
echo "All JournalNodes are ready!"

# Format NameNode only if not already formatted
if [ ! -f /usr/local/hadoop/data/namenode/current/VERSION ]; then
    echo "Formatting NameNode..."
    su - hadoop -c "/usr/local/hadoop/bin/hdfs namenode -format -force"
    echo "Initializing shared edits..."
    su - hadoop -c "/usr/local/hadoop/bin/hdfs namenode -initializeSharedEdits -force"
    echo "Formatting ZooKeeper for HDFS HA..."
    su - hadoop -c "/usr/local/hadoop/bin/hdfs zkfc -formatZK -force"
fi

# Start NameNode
echo "Starting NameNode..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start namenode"
sleep 5

# Start ZKFC
echo "Starting ZKFC..."
su - hadoop -c "/usr/local/hadoop/bin/hdfs --daemon start zkfc"
sleep 3

# Start ResourceManager
echo "Starting ResourceManager..."
su - hadoop -c "/usr/local/hadoop/bin/yarn --daemon start resourcemanager"

# Create health check file
touch /tmp/.master1_ready
echo "=== Master1 is ready ==="
sleep infinity
