#!/bin/bash
# CloudWatch Alarm Automation Script
# Author: Praveen Babu
# Date: $(date)

INSTANCE_ID="i-093e5b6a3fead3ff2"   # Replace with your EC2 instance ID
ALARM_NAME="HighCPUAlarm"
SNS_TOPIC_NAME="DevOpsAlerts"

echo "🚀 Creating SNS topic: $SNS_TOPIC_NAME"
TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_NAME --query 'TopicArn' --output text)

echo "📩 Subscribing your email to SNS topic"
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint praveenpopz37@gmail.com

echo "📊 Creating CloudWatch alarm: $ALARM_NAME for EC2 instance $INSTANCE_ID"
aws cloudwatch put-metric-alarm \
  --alarm-name $ALARM_NAME \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=$INSTANCE_ID \
  --evaluation-periods 1 \
  --alarm-actions $TOPIC_ARN \
  --unit Percent

echo "✅ Alarm $ALARM_NAME created. You will get an email when CPU > 70%."
