# distributed-storage-monitor

Distributed storage monitoring and reporting toolkit for large DevOps build environments.

This repository contains a set of Bash automation scripts originally built for a multi-host enterprise development environment backed by HP / 3PAR storage across multiple campuses connected by private MPLS-style links.

The system was designed to:

- collect daily disk usage metrics across multiple build hosts
- identify top disk consumers by workspace and by user
- aggregate weekly storage utilization data into CSV reports
- email operational reports to DevOps management automatically
- support storage governance in environments with hundreds of developers

## Repository Contents

### find-top-5-disk-space-users.sh
Runs on multiple hosts and finds the top 5 disk space consumers per workspace by walking the filesystem and aggregating usage by user.

### generate-daily-disk-space-data.sh
Collects daily `df` metrics across workspaces and writes structured CSV data for later aggregation.

### generate-weekly-disk-space-usage-report.sh
Builds the final weekly CSV report by combining daily usage data, top-user data, and additional reporting inputs.

### weekly-disk-space-usage-email.sh
Packages the latest weekly report and emails it automatically to the operations team.

## Architecture
