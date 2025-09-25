#!/bin/bash
# RDS MySQL Automation Script
# Author: Praveen Babu
# Date: $(date)

REGION="us-east-1"
DB_INSTANCE_IDENTIFIER="database-1"
DB_NAME="mydatabase"
DB_USERNAME=${DB_USERNAME:-admin}     # Taken from env var or defaults to 'admin'
DB_PASSWORD=${DB_PASSWORD}            # Must come from env var
INSTANCE_CLASS=db.t3.micro
ALLOCATED_STORAGE=20
ENGINE="mysql"

if [ -z "$DB_PASSWORD" ]; then
  echo "❌ Error: DB_PASSWORD is not set. Use: export DB_PASSWORD='yourpass'"
  exit 1
fi

# 🔍 Check if RDS instance already exists
echo "🔍 Checking if RDS instance '$DB_INSTANCE_IDENTIFIER' exists..."
if aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER --region $REGION >/dev/null 2>&1; then
  echo "✅ RDS instance '$DB_INSTANCE_IDENTIFIER' already exists. Skipping creation."
else
  echo "📦 Creating RDS instance..."
  aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
    --db-name $DB_NAME \
    --engine $ENGINE \
    --master-username $DB_USERNAME \
    --master-user-password $DB_PASSWORD \
    --allocated-storage $ALLOCATED_STORAGE \
    --db-instance-class $INSTANCE_CLASS \
    --publicly-accessible \
    --region $REGION
fi

echo "⏳ Waiting until RDS is available..."
aws rds wait db-instance-available \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
  --region $REGION

echo "🎉 RDS instance is ready!"
aws rds describe-db-instances \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text \
  --region $REGION
