#!/bin/bash
# System Health Monitoring Script

echo "📊 System Health Report - $(date)"
echo "-----------------------------------"

# CPU Load
echo "🖥️  CPU Load:"
uptime | awk -F'load average:' '{ print $2 }'

# Memory Usage
echo "💾 Memory Usage:"
free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)\n", 
$3,$2,($3*100/$2)}'

# Disk Usage
echo "📂 Disk Usage:"
df -h | grep '^/dev/' | awk '{ print $1 " -> " $5 " used (" $3 "/" $2 ")" 
}'

echo "-----------------------------------"
echo "✅ Health check completed!"
