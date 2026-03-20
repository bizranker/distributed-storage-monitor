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

## Real-World Experience: Storage Governance System (Enterprise)

In a global development environment supporting distributed engineering teams, I designed and implemented an automated storage governance system to address uncontrolled disk growth across shared workspaces.

### Key Capabilities

- Identified top disk consumers across multi-terabyte environments  
- Generated automated usage reports for leadership visibility  
- Notified top offenders with actionable remediation guidance  
- Implemented a 30-day enforcement lifecycle:
  - warning phase  
  - automated cleanup (file relocation to scratch space)  
- Built a reversible workflow:
  - managers could restore user data via a single-click script embedded in notifications  

### Impact

- Provided leadership with clear visibility into storage utilization trends  
- Reduced unnecessary storage consumption from non-work-related files  
- Introduced accountability without permanent data loss  
- Enabled scalable governance across global engineering teams  

---

## Example Use Cases

- Track capacity growth across shared development workspaces  
- Identify the top disk consumers before storage becomes critical  
- Generate weekly reports for operations or platform teams  
- Automate storage visibility across multiple Linux hosts  

---

## Configuration

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

```cron
0 6 * * 1 /path/to/distributed-storage-monitor.sh all
```

---

## Design Philosophy

- single orchestration script  
- sequential execution model  
- minimal operational complexity  
- portable across environments  

---

## Lessons Learned

This system highlighted important real-world considerations:

- balancing enforcement with developer autonomy  
- maintaining transparency in automated actions  
- designing reversible workflows to reduce friction  
- ensuring operational visibility without excessive intrusion  

---

## Performance Considerations

The original system relied on filesystem traversal, which can be expensive at large scale.

This informed modern design approaches such as:

- metadata-driven analysis  
- sampling strategies  
- quota-based enforcement (ZFS / QFS)  
- event-driven monitoring  

This implementation is best suited for:

- small to mid-sized environments  
- fast storage systems (RAID-backed volumes)  
- scenarios where visibility is prioritized  

---

## Notes

This public version is sanitized and uses generic host and workspace naming.

Replace the host-to-workspace mapping with your environment-specific values.

---

## Summary

- One script  
- One entry point  
- One sequential workflow  

Designed for real-world DevOps environments where visibility, simplicity, and automation matter.
