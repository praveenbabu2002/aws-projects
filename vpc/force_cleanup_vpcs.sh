#!/bin/bash
# Force cleanup of all non-default VPCs including ENIs

REGION="eu-north-1"

# Get all non-default VPCs
VPCS=$(aws ec2 describe-vpcs --region $REGION --query 'Vpcs[?IsDefault==`false`].VpcId' --output text)

for VPC in $VPCS; do
  echo "🧹 Cleaning VPC: $VPC in $REGION"

  # Delete ENIs
  for ENI in $(aws ec2 describe-network-interfaces --region $REGION --filters Name=vpc-id,Values=$VPC --query 'NetworkInterfaces[].NetworkInterfaceId' --output text); do
    echo " Detaching & Deleting ENI: $ENI"
    # Try detach (ignore errors if already detached)
    aws ec2 detach-network-interface --attachment-id $(aws ec2 describe-network-interfaces --network-interface-ids $ENI --region $REGION --query 'NetworkInterfaces[].Attachment.AttachmentId' 
--output text) --region $REGION 2>/dev/null
    # Delete ENI
    aws ec2 delete-network-interface --network-interface-id $ENI --region $REGION
  done

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

  # Delete Custom NACLs
  for NACL in $(aws ec2 describe-network-acls --region $REGION --filters Name=vpc-id,Values=$VPC --query 'NetworkAcls[?IsDefault==`false`].NetworkAclId' --output text); do
    echo " Deleting NACL: $NACL"
    aws ec2 delete-network-acl --network-acl-id $NACL --region $REGION
  done

  # Finally delete VPC
  echo " Deleting VPC: $VPC"
  aws ec2 delete-vpc --vpc-id $VPC --region $REGION
done

echo "✅ Cleanup complete. Only default VPC should remain."
