# distributed-storage-monitor

Distributed storage monitoring and reporting toolkit for multi-host DevOps and build environments.

This repository contains a unified Bash-based workflow that tracks filesystem usage, identifies top disk consumers, generates weekly CSV reports, and optionally emails the latest report to an operations team.

It was designed to help platform and DevOps teams improve storage visibility, detect abuse, and monitor capacity trends across multiple hosts and workspaces.

---

## What It Does

- Collects daily disk usage metrics across multiple workspaces
- Identifies top disk consumers per workspace
- Aggregates weekly storage utilization data into CSV reports
- Optionally emails the latest report automatically
- Supports storage governance in large shared build environments

---

## Primary Script

### `distributed-storage-monitor.sh`

Unified orchestration script that combines the original multi-script workflow into a single entry point.

Supported commands:

```bash
./distributed-storage-monitor.sh daily
./distributed-storage-monitor.sh top-users
./distributed-storage-monitor.sh weekly
./distributed-storage-monitor.sh email
./distributed-storage-monitor.sh all
