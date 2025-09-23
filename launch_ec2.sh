#!/bin/bash

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id ami-043339ea831b48099 \
  --count 1 \
  --instance-type t3.micro \
  --key-name "EC2 Tutorial" \
  --subnet-id subnet-009d68c52eccf266e \
  --query "Instances[0].InstanceId" \
  --output text)

echo "Launched instance: $INSTANCE_ID"

aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Instance is running. Public IP: $PUBLIC_IP"
