#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# distributed-storage-monitor.sh
#
# Unified storage monitoring and reporting script for multi-host build and
# development environments.
#
# What it does:
#   1. Collects daily filesystem usage data
#   2. Identifies top disk consumers per workspace
#   3. Builds a weekly consolidated CSV report
#   4. Optionally emails the report
#
# Public/sanitized version:
#   - no internal domains
#   - no internal email addresses
#   - no customer-specific environment names
#
# Usage:
#   ./distributed-storage-monitor.sh daily
#   ./distributed-storage-monitor.sh top-users
#   ./distributed-storage-monitor.sh weekly
#   ./distributed-storage-monitor.sh email
#   ./distributed-storage-monitor.sh all
###############################################################################

TODAY="$(date +'%m-%d-%y')"
HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------
OUTPUT_DIR="${OUTPUT_DIR:-./reports}"
TEMP_DIR="${TEMP_DIR:-$OUTPUT_DIR/temp}"
BASE_PATH="${BASE_PATH:-/export/ws}"
EMAIL_FROM="${EMAIL_FROM:-ops@example.com}"
EMAIL_TO="${EMAIL_TO:-devops-team@example.com}"
SENDMAIL_BIN="${SENDMAIL_BIN:-/usr/sbin/sendmail}"

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# -----------------------------------------------------------------------------
# Workspace mapping by host
# Replace these with your own public-safe example names as needed.
# -----------------------------------------------------------------------------
get_workspaces_for_host() {
  case "$HOSTNAME_SHORT" in
    host-a)
      echo "dev-a dev-b dev-c"
      ;;
    host-b)
      echo "qa-a qa-b qa-c qa-d"
      ;;
    host-c)
      echo "stage-a stage-b prod-dr"
      ;;
    host-d)
      echo "prod-a prod-b prod-c archive"
      ;;
    *)
      # Safe generic default for public/demo use
      echo "dev qa stage prod"
      ;;
  esac
}

WORKSPACES=($(get_workspaces_for_host))

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

workspace_paths() {
  local paths=()
  for ws in "${WORKSPACES[@]}"; do
    paths+=("$BASE_PATH/$ws")
  done
  printf '%s\n' "${paths[@]}"
}

latest_file() {
  ls -1t "$1" 2>/dev/null | head -1 || true
}

# -----------------------------------------------------------------------------
# 1. Daily disk usage collection
# -----------------------------------------------------------------------------
generate_daily_disk_space_data() {
  local out_file="$OUTPUT_DIR/${HOSTNAME_SHORT}.csv"

  log "Generating daily disk usage data for ${HOSTNAME_SHORT}"

  if [[ ! -f "$out_file" ]]; then
    {
      printf '%s' "$HOSTNAME_SHORT"
      for ws in "${WORKSPACES[@]}"; do
        printf ',%s_size,%s_used' "$ws" "$ws"
      done
      printf '\n'
    } > "$out_file"
  fi

  {
    printf '%s' "$TODAY"
    df -Pm "${WORKSPACES[@]/#/$BASE_PATH/}" | awk '
      NR > 1 && NF {
        printf ",%s,%s", $2, $3
      }
      END { printf "\n" }'
  } >> "$out_file"

  log "Wrote: $out_file"
}

# -----------------------------------------------------------------------------
# 2. Top disk consumers per workspace
# -----------------------------------------------------------------------------
find_top_5_disk_space_users() {
  local out_file="$OUTPUT_DIR/${HOSTNAME_SHORT}_top_5_per_workspace_${TODAY}.csv"

  log "Finding top disk consumers for ${HOSTNAME_SHORT}"

  if [[ -f "$out_file" ]]; then
    log "Top-user report already exists: $out_file"
    return 0
  fi

  {
    echo "Top 5 consumers of space per workspace on server ${HOSTNAME_SHORT} ${TODAY}"
    echo ",,,"
    echo ",,,"

    for ws in "${WORKSPACES[@]}"; do
      echo "Top 5 consumers on workspace $ws"
      echo ",,,"

      if [[ -d "$BASE_PATH/$ws" ]]; then
        find "$BASE_PATH/$ws" -printf "%u %s\n" \
          | awk '
              { user[$1] += $2 }
              END {
                for (i in user) {
                  if (i != "root" && i !~ /^[0-9]+$/) {
                    printf "%s,%.2f,GB\n", i, user[i]/2^30
                  }
                }
              }' \
          | sort -t, -k2,2nr \
          | head -5
      else
        echo "workspace_not_found,0,GB"
      fi

      echo ",,,"
    done
  } > "$out_file"

  log "Wrote: $out_file"
}

# -----------------------------------------------------------------------------
# 3. Weekly report assembly
# -----------------------------------------------------------------------------
generate_weekly_report() {
  local weekly_file="$OUTPUT_DIR/weekly_workspace_report_${TODAY}.csv"

  log "Generating weekly consolidated report"

  {
    echo ",,,,,Weekly Workspace Report ${TODAY}"
    echo ",,,,,"
    echo ",,,,,"

    echo ",,,,,Top 5 Consumers of Space on All Hosts/Workspaces"
    echo ",,,,,"
    echo ",,,,,"

    cat "$OUTPUT_DIR"/*_top_5_per_workspace_*.csv 2>/dev/null || true

    echo ",,,,,"
    echo ",,,,,Size and Used Values on All Hosts and Workspaces"
    echo ",,,,,"

    cat "$OUTPUT_DIR"/*.csv 2>/dev/null \
      | awk 'NR == 1 || FNR > 1' || true
  } > "$weekly_file"

  log "Wrote: $weekly_file"
}

# -----------------------------------------------------------------------------
# 4. Email latest weekly report
# -----------------------------------------------------------------------------
send_weekly_report_email() {
  local report_file
  report_file="$(latest_file "$OUTPUT_DIR"/weekly_workspace_report_*.csv)"

  if [[ -z "$report_file" ]]; then
    log "No weekly report found to email"
    return 1
  fi

  if [[ ! -x "$SENDMAIL_BIN" ]]; then
    log "sendmail not found or not executable at: $SENDMAIL_BIN"
    log "Skipping email step"
    return 0
  fi

  local subject="Weekly Workspace Report $(date +'%a %b %e %Y')"
  local boundary="ZZ_/afg6432dfgkl.94531q"

  log "Emailing report: $report_file"

  {
    printf '%s\n' "From: $EMAIL_FROM"
    printf '%s\n' "To: $EMAIL_TO"
    printf '%s\n' "Subject: $subject"
    printf '%s\n' "Mime-Version: 1.0"
    printf '%s\n' "Content-Type: multipart/mixed; boundary=\"$boundary\""
    printf '\n'
    printf '%s\n' "--${boundary}"
    printf '%s\n' 'Content-Type: text/plain; charset="US-ASCII"'
    printf '%s\n' 'Content-Transfer-Encoding: 7bit'
    printf '%s\n' 'Content-Disposition: inline'
    printf '\n'
    printf '%s\n' "Hello,"
    printf '\n'
    printf '%s\n' "Attached is the latest weekly storage utilization report."
    printf '\n'
    printf '%s\n' "Regards,"
    printf '%s\n' "Storage Monitor"
    printf '\n'
    printf '%s\n' "--${boundary}"
    printf '%s\n' 'Content-Type: text/csv'
    printf '%s\n' 'Content-Transfer-Encoding: base64'
    printf '%s\n' "Content-Disposition: attachment; filename=\"$(basename "$report_file")\""
    printf '\n'
    base64 "$report_file"
    printf '\n'
    printf '%s\n' "--${boundary}--"
  } | "$SENDMAIL_BIN" -t -oi

  log "Email sent"
}

# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------
usage() {
  cat <<USAGE
Usage:
  $0 daily
  $0 top-users
  $0 weekly
  $0 email
  $0 all

Commands:
  daily       Collect daily disk usage data
  top-users   Find top 5 disk consumers per workspace
  weekly      Build weekly consolidated CSV report
  email       Email the latest weekly report
  all         Run daily + top-users + weekly + email
USAGE
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    daily)
      generate_daily_disk_space_data
      ;;
    top-users)
      find_top_5_disk_space_users
      ;;
    weekly)
      generate_weekly_report
      ;;
    email)
      send_weekly_report_email
      ;;
    all)
      generate_daily_disk_space_data
      find_top_5_disk_space_users
      generate_weekly_report
      send_weekly_report_email
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
