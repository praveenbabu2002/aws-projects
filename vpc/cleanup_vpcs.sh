#!/bin/bash

REGION="eu-north-1"

echo "🔎 Finding all non-default VPCs in $REGION..."
VPC_IDS=$(aws ec2 describe-vpcs \
  --region $REGION \
  --query "Vpcs[?IsDefault==\`false\`].VpcId" \
  --output text)

for VPC_ID in $VPC_IDS; do
  echo "⚡ Cleaning up VPC: $VPC_ID"

  # 1. Delete Subnets
  SUBNETS=$(aws ec2 describe-subnets \
    --region $REGION \
    --filters Name=vpc-id,Values=$VPC_ID \
    --query "Subnets[].SubnetId" \
    --output text)
  for SUBNET in $SUBNETS; do
    echo "   🗑 Deleting Subnet: $SUBNET"
    aws ec2 delete-subnet --subnet-id $SUBNET --region $REGION
  done

  # 2. Detach & Delete Internet Gateways
  IGWS=$(aws ec2 describe-internet-gateways \
    --region $REGION \
    --filters Name=attachment.vpc-id,Values=$VPC_ID \
    --query "InternetGateways[].InternetGatewayId" \
    --output text)
  for IGW in $IGWS; do
    echo "   🔌 Detaching & Deleting IGW: $IGW"
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID --region $REGION
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW --region $REGION
  done

  # 3. Delete Route Tables (skip the main one)
  RTBS=$(aws ec2 describe-route-tables \
    --region $REGION \
    --filters Name=vpc-id,Values=$VPC_ID \
    --query "RouteTables[?Associations[?Main!=\`true\`]].RouteTableId" \
    --output text)
  for RTB in $RTBS; do
    echo "   🗑 Deleting Route Table: $RTB"
    aws ec2 delete-route-table --route-table-id $RTB --region $REGION
  done

  # 4. Delete Security Groups (except default)
  SGS=$(aws ec2 describe-security-groups \
    --region $REGION \
    --filters Name=vpc-id,Values=$VPC_ID \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text)
  for SG in $SGS; do
    echo "   🗑 Deleting Security Group: $SG"
    aws ec2 delete-security-group --group-id $SG --region $REGION
  done

  # 5. Delete the VPC
  echo "   🗑 Deleting VPC: $VPC_ID"
  aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION

done

echo "✅ Cleanup complete. Only default VPC should remain."
