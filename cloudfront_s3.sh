#!/bin/bash
# CloudFront + S3 Automation Script
# Author: Praveen
# Date: $(date)

REGION="us-east-1"
BUCKET_NAME="praveen-s3-website-329"

# Step 1: Upload index.html to S3
echo "🚀 Uploading index.html to S3..."
aws s3 cp index.html s3://$BUCKET_NAME/ --region $REGION

# Step 2: Create bucket policy file (public read)
cat > policy.json <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
    }
  ]
}
EOL

echo "📌 Applying bucket policy..."
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://policy.json --region $REGION

# Step 3: Create CloudFront config file
cat > cloudfront-config.json <<EOL
{
  "CallerReference": "my-distribution-$(date +%s)",
  "Comment": "CloudFront distribution for $BUCKET_NAME",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-$BUCKET_NAME",
        "DomainName": "$BUCKET_NAME.s3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-$BUCKET_NAME",
    "ViewerProtocolPolicy": "redirect-to-https",
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "MinTTL": 0
  },
  "DefaultRootObject": "index.html",   
  "PriceClass": "PriceClass_100",
  "Enabled": true,
  "ViewerCertificate": {
    "CloudFrontDefaultCertificate": true
  }
}
EOL

# Step 4: Create CloudFront Distribution
echo "🌍 Creating CloudFront distribution..."
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json

# Step 4: Create CloudFront Distribution (no region here!)
echo "🌍 Creating CloudFront distribution..."
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json
