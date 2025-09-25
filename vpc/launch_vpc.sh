#!/bin/bash
set -e

REGION="eu-north-1"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
AMI_ID="ami-08bdc08970fcbd34a"   # Example Amazon Linux 2 AMI for eu-north-1
INSTANCE_TYPE="t3.micro"
KEY_NAME="vpc-key"  # Change to your existing key pair

echo "🚀 Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --region $REGION \
    --query 'Vpc.VpcId' \
    --output text)

echo "✅ VPC created: $VPC_ID"

echo "🚀 Creating Subnet..."
SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $SUBNET_CIDR \
    --availability-zone ${REGION}a \
    --query 'Subnet.SubnetId' \
    --output text)

echo "✅ Subnet created: $SUBNET_ID"

echo "🚀 Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --region $REGION \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID \
    --region $REGION

echo "✅ Internet Gateway created & attached: $IGW_ID"

echo "🚀 Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query 'RouteTable.RouteTableId' \
    --output text)

aws ec2 create-route \
    --route-table-id $ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

aws ec2 associate-route-table \
    --subnet-id $SUBNET_ID \
    --route-table-id $ROUTE_TABLE_ID

echo "✅ Route Table created & associated: $ROUTE_TABLE_ID"

echo "🚀 Creating Security Group..."
SG_ID=$(aws ec2 create-security-group \
    --group-name custom-sg \
    --description "Custom SG for VPC Automation" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "✅ Security Group created: $SG_ID"

echo "🚀 Launching EC2 Instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name vpc-key \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SG_ID \
    --associate-public-ip-address \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "✅ EC2 Instance launched: $INSTANCE_ID"

echo "🎉 VPC + EC2 setup complete!"
