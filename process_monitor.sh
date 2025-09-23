#!/bin/bash
# Process Monitoring Script
# This script checks if a process is running and alerts if it is not.

PROCESS="nginx"   # change this to any process you want to monitor

if pgrep -x "$PROCESS" >/dev/null
then
    echo "✅ $PROCESS is running."
else
    echo "⚠️ ALERT: $PROCESS is not running!"
fi
