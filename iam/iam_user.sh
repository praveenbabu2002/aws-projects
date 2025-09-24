#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER_NAME=$1
GROUP_NAME="DevOpsGroup"

# Check if group exists
aws iam get-group --group-name $GROUP_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "✅ Creating IAM group: $GROUP_NAME"
  aws iam create-group --group-name $GROUP_NAME
else
  echo "ℹ️ Group $GROUP_NAME already exists"
fi

# Check if user exists
aws iam get-user --user-name $USER_NAME >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "✅ Creating IAM user: $USER_NAME"
  aws iam create-user --user-name $USER_NAME
else
  echo "ℹ️ User $USER_NAME already exists"
fi

# Add user to group
echo "🔗 Adding $USER_NAME to group $GROUP_NAME"
aws iam add-user-to-group --user-name $USER_NAME --group-name $GROUP_NAME

# Attach policy to group
echo "🔐 Attaching S3FullAccess policy to group $GROUP_NAME"
aws iam attach-group-policy \
  --group-name $GROUP_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create access keys
echo "🔑 Creating access keys for $USER_NAME"
aws iam create-access-key --user-name $USER_NAME
