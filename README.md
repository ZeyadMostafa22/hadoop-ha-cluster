# 🐘 Hadoop HA Cluster on Docker

<div align="center">

![Hadoop](https://img.shields.io/badge/Hadoop-3.4.2-yellow?style=for-the-badge&logo=apache-hadoop&logoColor=white)
![ZooKeeper](https://img.shields.io/badge/ZooKeeper-3.8.4-red?style=for-the-badge&logo=apache&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A fully automated, production-grade 5-node Highly Available Hadoop cluster running on Docker.**  
Automatic HDFS & YARN failover. Zero manual intervention required after startup.

[Features](#-features) • [Architecture](#-architecture) • [Quick Start](#-quick-start) • [Configuration](#-configuration) • [Testing HA](#-testing-high-availability)

</div>

---

## ✨ Features

- ✅ **Full HDFS High Availability** — Active/Standby NameNodes with automatic failover
- ✅ **Full YARN High Availability** — Active/Standby ResourceManagers with automatic failover
- ✅ **ZooKeeper Quorum** — 3-node quorum for coordination and leader election
- ✅ **JournalNode Quorum** — 3-node shared edit log keeping NameNodes in sync
- ✅ **Fully Automated Startup** — one command starts everything in the correct order
- ✅ **Health Checks & Dependency Ordering** — Docker waits for each service to be truly ready before starting the next
- ✅ **Zero Single Point of Failure** — losing any single node keeps the cluster running
- ✅ **MapReduce Ready** — tested with word count on real HDFS data

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    My Hadoop HA Cluster                         │
│                                                                 │
│  ┌──────────────────────┐    ┌──────────────────────┐           │
│  │        node01        │    │        node02        │           │
│  │   (Primary Master)   │◄──►│   (Standby Master)   │           │
│  │                      │    │                      │           │
│  │  NameNode  (Active)  │    │  NameNode (Standby)  │           │
│  │  ResourceMgr (Active)│    │  ResourceMgr(Standby)│           │
│  │  ZooKeeper           │    │  ZooKeeper           │           │
│  │  JournalNode         │    │  JournalNode         │           │
│  │  ZKFC                │    │  ZKFC                │           │
│  └──────────────────────┘    └──────────────────────┘           │
│                                                                 │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐     │
│  │     node03     │  │     node04     │  │     node05     │     │
│  │ (Hybrid Worker)│  │ (Pure Worker)  │  │ (Pure Worker)  │     │
│  │                │  │                │  │                │     │
│  │ DataNode       │  │ DataNode       │  │ DataNode       │     │
│  │ NodeManager    │  │ NodeManager    │  │ NodeManager    │     │
│  │ ZooKeeper      │  │                │  │                │     │
│  │ JournalNode    │  │                │  │                │     │
│  └────────────────┘  └────────────────┘  └────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

### Node Roles

| Node | Services | Role |
|------|----------|------|
| **node01** | NameNode (Active), ResourceManager (Active), ZKFC, ZooKeeper, JournalNode | Primary Master |
| **node02** | NameNode (Standby), ResourceManager (Standby), ZKFC, ZooKeeper, JournalNode | Standby Master |
| **node03** | DataNode, NodeManager, ZooKeeper, JournalNode | Hybrid Worker |
| **node04** | DataNode, NodeManager | Pure Worker |
| **node05** | DataNode, NodeManager | Pure Worker |

### Why This Layout?

Every critical decision in this cluster requires **majority agreement** — at least 2 out of 3 nodes must confirm before anything is committed.

- **ZooKeeper on node01, node02, node03** → 3-node quorum. Lose 1, still have majority (2/3)
- **JournalNodes on node01, node02, node03** → 3-node quorum for shared NameNode edit log
- **node04 & node05 are pure workers** → expendable by design. Losing them never breaks coordination

---

## 🚀 Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- Windows, Linux, or Mac
- At least **8GB RAM** available for Docker
- At least **20GB disk space**

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/hadoop-ha-cluster.git
cd hadoop-ha-cluster
```

### 2. Start the Cluster

```bash
docker-compose up -d
```

That's it. Docker will:
1. Start node01 first and wait until it's fully healthy
2. Start node02, node03, node04, node05 automatically once node01 is ready
3. Each node runs its own startup script based on its role

**Wait ~40 seconds** for all services to initialize.

### 3. Verify the Cluster

```bash
docker exec -it node01 bash
su - hadoop

# Check HDFS HA status
hdfs haadmin -getServiceState nn1   # should show: active
hdfs haadmin -getServiceState nn2   # should show: standby

# Check YARN HA status
yarn rmadmin -getServiceState rm1   # should show: active
yarn rmadmin -getServiceState rm2   # should show: standby

# Check all DataNodes
hdfs dfsadmin -report
```

---

## 🌐 Web UIs

| Service | Node | URL |
|---------|------|-----|
| HDFS NameNode (Active) | node01 | http://localhost:9871 |
| HDFS NameNode (Standby) | node02 | http://localhost:9872 |
| YARN ResourceManager (Active) | node01 | http://localhost:8081 |
| YARN ResourceManager (Standby) | node02 | http://localhost:8082 |
| JournalNode | node01 | http://localhost:8481 |
| JournalNode | node02 | http://localhost:8482 |
| JournalNode | node03 | http://localhost:8483 |

---

## ⚙️ Configuration

### Hadoop Configuration Files

| File | Purpose |
|------|---------|
| `shared/core-site.xml` | Cluster name (`mycluster`) and ZooKeeper addresses |
| `shared/hdfs-site.xml` | NameNode HA, JournalNodes, replication factor, data directories |
| `shared/yarn-site.xml` | ResourceManager HA, ZooKeeper recovery, shuffle service |
| `shared/mapred-site.xml` | MapReduce on YARN, application classpath |
| `shared/workers` | List of worker nodes (node03, node04, node05) |
| `shared/zoo.cfg` | ZooKeeper quorum configuration |

### Key Settings

```xml
<!-- Replication Factor -->
<property>
  <name>dfs.replication</name>
  <value>1</value>
</property>

<!-- Cluster Name -->
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://mycluster</value>
</property>

<!-- ZooKeeper Quorum -->
<property>
  <name>ha.zookeeper.quorum</name>
  <value>node01:2181,node02:2181,node03:2181</value>
</property>
```

### Startup Scripts

| Script | Used By | Starts |
|--------|---------|--------|
| `scripts/start-master1.sh` | node01 | ZooKeeper → JournalNode → NameNode → ZKFC → ResourceManager |
| `scripts/start-master2.sh` | node02 | ZooKeeper → JournalNode → NameNode (bootstrap) → ZKFC → ResourceManager |
| `scripts/start-node03.sh` | node03 | ZooKeeper → JournalNode → DataNode → NodeManager |
| `scripts/start-worker.sh` | node04, node05 | DataNode → NodeManager |

---

## 🔁 How Automatic Failover Works

```
1. Active NameNode (node01) crashes
        ↓
2. ZKFC on node01 detects NameNode is unhealthy
        ↓
3. ZKFC releases the ZooKeeper lock
        ↓
4. ZKFC on node02 grabs the lock
        ↓
5. node02 NameNode transitions from Standby → Active
        ↓
6. Cluster continues running — no data loss, no manual intervention
```

The entire process takes **10-30 seconds**.

---

## 🧪 Testing High Availability

### Test HDFS Failover

```bash
# Check current state
hdfs haadmin -getServiceState nn1   # active
hdfs haadmin -getServiceState nn2   # standby

# Kill the Active NameNode
jps | grep NameNode
kill -9 <PID>

# Watch node02 become Active (within 30 seconds)
hdfs haadmin -getServiceState nn2   # active ✅

# Bring node01 back as Standby
hdfs --daemon start namenode
hdfs haadmin -getServiceState nn1   # standby ✅
```

### Test YARN Failover

```bash
# Kill Active ResourceManager
jps | grep ResourceManager
kill -9 <PID>

# node02 becomes Active automatically
yarn rmadmin -getServiceState rm2   # active ✅

# Bring node01 back
yarn --daemon start resourcemanager
```

### Ingest Data & Run MapReduce

```bash
# Create a test file and upload to HDFS
echo "Hello Hadoop HA Cluster" > /tmp/test.txt
hdfs dfs -mkdir /input
hdfs dfs -put /tmp/test.txt /input/

# Run word count MapReduce job
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.2.jar \
  wordcount /input /output

# View results
hdfs dfs -cat /output/part-r-00000
```

---

## 📁 Project Structure

```
hadoop-ha-cluster/
├── docker-compose.yml          # 5-node cluster with health checks & dependencies
├── .gitignore
├── README.md
└── shared/                     # Mounted volume shared across all containers
    ├── scripts/
    │   ├── start-master1.sh    # node01 startup script
    │   ├── start-master2.sh    # node02 startup script
    │   ├── start-node03.sh     # node03 startup script
    │   └── start-worker.sh     # node04 & node05 startup script
    ├── start-cluster.sh        # Manual cluster startup (alternative)
    ├── core-site.xml
    ├── hdfs-site.xml
    ├── yarn-site.xml
    ├── mapred-site.xml
    ├── workers
    └── zoo.cfg
```

---

## 🧰 Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Apache Hadoop | 3.4.2 | Distributed storage (HDFS) and computation (YARN) |
| Apache ZooKeeper | 3.8.4 | Cluster coordination and leader election |
| Docker | Latest | Container runtime |
| Ubuntu | 24.04 | Base OS for all containers |
| OpenJDK | 11 | Java runtime for all Hadoop services |

---

## 📖 Key Concepts

**HDFS (Hadoop Distributed File System)** — splits large files into blocks and distributes them across DataNodes. The NameNode manages metadata (where everything is stored).

**YARN (Yet Another Resource Negotiator)** — manages cluster resources. The ResourceManager assigns CPU/RAM to jobs. NodeManagers execute the actual tasks.

**ZooKeeper** — coordination service that acts as a referee. Determines which NameNode and ResourceManager are Active through distributed locking.

**ZKFC (ZooKeeper Failover Controller)** — watchdog process that monitors NameNode health and triggers automatic failover through ZooKeeper.

**JournalNodes** — shared edit log that keeps both NameNodes in sync. The Active NameNode writes every change here; the Standby reads from it continuously.

---

## 👤 Author

**Zeyad Mostafa**  
ITI — Data Management Track  
March 2026

---

<div align="center">

⭐ If this project helped you, give it a star!

</div>
