# distributed-storage-monitor

Distributed storage monitoring and reporting toolkit for multi-host DevOps and build environments.

This repository contains a unified Bash-based script that tracks filesystem usage, identifies top disk consumers, generates weekly CSV reports, and optionally emails the latest report to an operations team.

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

---

## Primary Usage

```bash
./distributed-storage-monitor.sh all
```

This runs the full workflow sequentially:

- collect daily disk usage data  
- identify top disk consumers  
- generate the weekly consolidated report  
- optionally send the latest report by email  

---

## Full Command Options

While the script is designed to be run as a single workflow (`all`), individual stages are also available for flexibility:

```bash
./distributed-storage-monitor.sh daily
./distributed-storage-monitor.sh top-users
./distributed-storage-monitor.sh weekly
./distributed-storage-monitor.sh email
./distributed-storage-monitor.sh all
```

---

## Example Workflow

```
cron / scheduled run
        |
        `-- distributed-storage-monitor.sh all
                |
                |-- collect daily disk usage
                |-- identify top workspace consumers
                |-- generate weekly consolidated report
                `-- optionally email latest report
```

---

## Example Use Cases

- Track capacity growth across shared development workspaces  
- Identify the top disk consumers before storage becomes critical  
- Generate weekly reports for operations or platform teams  
- Automate storage visibility across multiple Linux hosts  

---

## Configuration

The script supports environment overrides for public-safe portability:

- `OUTPUT_DIR`  
- `TEMP_DIR`  
- `BASE_PATH`  
- `EMAIL_FROM`  
- `EMAIL_TO`  
- `SENDMAIL_BIN`  

### Example

```bash
OUTPUT_DIR=./reports BASE_PATH=/srv/workspaces ./distributed-storage-monitor.sh all
```

---

## Scheduling

You can run the unified script manually or from cron.

### Example cron entry

```cron
0 6 * * 1 /path/to/distributed-storage-monitor.sh all
```

This keeps the design aligned with the core philosophy:

- one script  
- one entry point  
- fully automated workflow  

---

## Design Philosophy

This project is intentionally structured around:

- a **single orchestration script**  
- a **sequential execution model**  
- minimal operational complexity  
- portability across environments  

The goal is to eliminate fragmentation from multiple scripts and provide a clean, reproducible workflow for storage monitoring.

---

## Notes

This public version is sanitized and uses generic host and workspace naming.

Replace the host-to-workspace mapping in the script with values appropriate for your environment.

---

## Recommendation

This repository is optimized for:

- simplicity over fragmentation  
- clarity over abstraction  
- real-world DevOps operational workflows  

The preferred usage pattern is:

```bash
./distributed-storage-monitor.sh all
```

Cron scheduling is optional, not required.

---

## Summary

- One script  
- One entry point  
- One sequential workflow  

Designed for real-world DevOps environments where visibility, simplicity, and automation matter.
