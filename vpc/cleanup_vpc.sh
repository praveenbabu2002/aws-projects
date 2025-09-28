#!/bin/bash

# Pass the VPC ID as the first argument
VPC_ID=$1
REGION="eu-north-1"

if [ -z "$VPC_ID" ]; then
  echo "❌ Usage: $0 <vpc-id>"
  exit 1
fi

echo "🚀 Cleaning up VPC: $VPC_ID in region $REGION"

# 1. Detach and delete Internet Gateways
IGW_IDS=$(aws ec2 describe-internet-gateways --region $REGION \
  --filters Name=attachment.vpc-id,Values=$VPC_ID \
  --query "InternetGateways[*].InternetGatewayId" --output text)

for igw in $IGW_IDS; do
  echo " Detaching & Deleting Internet Gateway: $igw"
  aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $VPC_ID --region $REGION
  aws ec2 delete-internet-gateway --internet-gateway-id $igw --region $REGION
done

# 2. Delete Subnets
SUBNET_IDS=$(aws ec2 describe-subnets --region $REGION \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "Subnets[*].SubnetId" --output text)

for subnet in $SUBNET_IDS; do
  echo " Deleting Subnet: $subnet"
  aws ec2 delete-subnet --subnet-id $subnet --region $REGION
done

# 3. Delete Route Tables (non-main only)
RTB_IDS=$(aws ec2 describe-route-tables --region $REGION \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "RouteTables[?Associations[?Main!=true]].RouteTableId" --output text)

for rtb in $RTB_IDS; do
  echo " Deleting Route Table: $rtb"
  aws ec2 delete-route-table --route-table-id $rtb --region $REGION
done

# 4. Delete Security Groups (non-default)
SG_IDS=$(aws ec2 describe-security-groups --region $REGION \
  --filters Name=vpc-id,Values=$VPC_ID \
  --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)

for sg in $SG_IDS; do
  echo " Deleting Security Group: $sg"
  aws ec2 delete-security-group --group-id $sg --region $REGION
done

# 5. Finally, delete the VPC
echo "Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION

echo "✅ Cleanup complete for VPC: $VPC_ID"
