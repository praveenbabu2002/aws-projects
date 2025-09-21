#!/bin/bash
# Simple Backup Script
# Compresses a folder into a backup with timestamp

SOURCE=$1
DESTINATION=backups

mkdir -p $DESTINATION
FILENAME=$(basename $SOURCE)_$(date +%Y%m%d_%H%M%S).tar.gz

tar -czf $DESTINATION/$FILENAME $SOURCE
echo "Backup of $SOURCE completed → $DESTINATION/$FILENAME"
