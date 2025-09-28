#!/bin/bash
# Log Cleanup Script
# Deletes log files older than 7 days (you can adjust the number of days)

LOG_DIR="/var/log"
DAYS=7

echo "🧹 Cleaning logs in $LOG_DIR older than $DAYS days..."

# Find and delete old logs
find $LOG_DIR -name "*.log" -type f -mtime +$DAYS -exec rm -f {} \;

echo "✅ Log cleanup completed!"
