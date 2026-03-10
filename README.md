# 📦 distributed-storage-monitor

> Distributed storage monitoring and reporting toolkit for large DevOps build environments.

This repository contains a coordinated set of Bash automation scripts originally built for a multi-host enterprise development environment backed by **HP / 3PAR storage** across multiple campuses connected by **private MPLS-style links**.

The system was designed to help operations teams monitor storage usage, detect abuse, track capacity trends, and automatically deliver weekly reports to management.

---

## ✨ What It Does

- Collects daily disk usage metrics across multiple build hosts
- Identifies top disk consumers by workspace and by user
- Aggregates weekly storage utilization data into CSV reports
- Emails operational reports to DevOps management automatically
- Supports storage governance in environments with hundreds of developers

---

## 🧰 Repository Contents

### `find-top-5-disk-space-users.sh`
Runs on multiple hosts and finds the **top 5 disk space consumers per workspace** by walking the filesystem and aggregating usage by user.

### `generate-daily-disk-space-data.sh`
Collects daily `df` metrics across workspaces and writes structured CSV data for later aggregation.

### `generate-weekly-disk-space-usage-report.sh`
Builds the final weekly CSV report by combining daily usage data, top-user data, and additional reporting inputs.

### `weekly-disk-space-usage-email.sh`
Packages the latest weekly report and emails it automatically to the operations team.

---

## 🏗️ Architecture

```text
cron
 ├── generate-daily-disk-space-data.sh
 ├── find-top-5-disk-space-users.sh
 │
 ▼
generate-weekly-disk-space-usage-report.sh
 │
 ▼
weekly-disk-space-usage-email.sh
 │
 ▼
DevOps management reporting
