#!/bin/bash
# AWS S3 Website Hosting Script

BUCKET_NAME="praveen-website-$RANDOM"   # unique bucket name
REGION="ap-south-1"                     # Mumbai region

echo "🚀 Creating S3 bucket: $BUCKET_NAME ..."

# Create bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Turn off Block Public Access
aws s3api delete-public-access-block \
    --bucket $BUCKET_NAME

# Upload ALL files in current directory
echo "📂 Uploading project files to S3..."
aws s3 cp . s3://$BUCKET_NAME/ --recursive

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME/ --index-document index.html 
--error-document index.html

echo "✅ Website hosted successfully!"
echo "👉 URL: http://$BUCKET_NAME.s3-website.$REGION.amazonaws.com"
