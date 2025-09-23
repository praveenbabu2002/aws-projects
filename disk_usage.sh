#!/bin/bash
# Disk Usage Monitoring Script

THRESHOLD=80

usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $usage -gt $THRESHOLD ]; then
  echo "Warning: Disk usage is above ${THRESHOLD}% (Current: ${usage}%)"
else
  echo "Disk usage is under control (${usage}%)"
fi
