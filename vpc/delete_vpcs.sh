#!/bin/bash
# Cleanup specific VPCs

REGION="eu-north-1"
VPCS=("vpc-023aeb7b4407eaf5c" "vpc-0bc209a3e70b032c3" "vpc-0daee4b9a956dd1eeb" "vpc-08f498754c8b885db") 

for VPC in "${VPCS[@]}"; do
  echo "🧹 Cleaning VPC: $VPC in $REGION"

  # Detach and delete Internet Gateways
  for IGW in $(aws ec2 describe-internet-gateways --region $REGION --filters Name=attachment.vpc-id,Values=$VPC --query 'InternetGateways[].InternetGatewayId' --output text); do
    echo " Detaching and deleting IGW: $IGW"
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC --region $REGION
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW --region $REGION
  done

  # Delete Subnets
  for SUBNET in $(aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=$VPC --query 'Subnets[].SubnetId' --output text); do
    echo " Deleting Subnet: $SUBNET"
    aws ec2 delete-subnet --subnet-id $SUBNET --region $REGION
  done

  # Delete Route Tables (excluding main)
  for RTB in $(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC --query 'RouteTables[].RouteTableId' --output text); do
    if ! aws ec2 describe-route-tables --route-table-ids $RTB --region $REGION --query 'RouteTables[].Associations[].Main' --output text | grep -q True; then
      echo " Deleting Route Table: $RTB"
      aws ec2 delete-route-table --route-table-id $RTB --region $REGION
    fi
  done

  # Delete Security Groups (excluding default)
  for SG in $(aws ec2 describe-security-groups --region $REGION --filters Name=vpc-id,Values=$VPC --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text); do
    echo " Deleting Security Group: $SG"
    aws ec2 delete-security-group --group-id $SG --region $REGION
  done

  # Finally delete VPC
  echo " Deleting VPC: $VPC"
  aws ec2 delete-vpc --vpc-id $VPC --region $REGION
done

echo "✅ Cleanup complete. Only default VPC should remain."
