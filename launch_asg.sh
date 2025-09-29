#!/bin/bash
set -e

# ========================
# 🔧 Variables - CHANGE THESE
# ========================
REGION="us-east-1"                     
AMI_ID="ami-08982f1c5bf93d976"           
INSTANCE_TYPE="t2.micro"                 
KEY_NAME="my-key"                
SECURITY_GROUP="sg-018db3c0ab76d5335"    
SUBNET1="subnet-02c94c6a4c7457772"       
SUBNET2="subnet-068bfe729a9a6fbe1"       
VPC_ID="vpc-0413f00473d65bf18"           

# Names
LAUNCH_TEMPLATE="my-launch-template-v3"
ASG_NAME="my-auto-scaling-group-v3"
TG_NAME="my-target-group-v3"
LB_NAME="my-load-balancer-v3"

# ========================
# Step 1: Create Launch Template
# ========================
echo "🚀 Checking if Launch Template already exists..."

if aws ec2 describe-launch-templates --launch-template-names $LAUNCH_TEMPLATE --region $REGION >/dev/null 2>&1; then
  echo "⚡ Launch Template $LAUNCH_TEMPLATE already exists. Skipping creation."
else
  echo "🚀 Creating Launch Template..."
  aws ec2 create-launch-template \
    --launch-template-name $LAUNCH_TEMPLATE \
    --version-description "v1" \
    --launch-template-data "{
      \"ImageId\":\"$AMI_ID\",
      \"InstanceType\":\"$INSTANCE_TYPE\",
      \"KeyName\":\"$KEY_NAME\",
      \"SecurityGroupIds\":[\"$SECURITY_GROUP\"],
      \"UserData\":\"$(echo '#!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo \"<h1>Hello from Auto Scaling + Load Balancer!</h1>\" > /var/www/html/index.html' | base64)\"
    }" \
    --region $REGION
fi

# ========================
# Step 2: Create Target Group
# ========================
echo "🎯 Creating Target Group..."
TG_ARN=$(aws elbv2 create-target-group \
  --name $TG_NAME \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --region $REGION \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# ========================
# Step 3: Create Load Balancer
# ========================
echo "🌐 Creating Load Balancer..."
LB_ARN=$(aws elbv2 create-load-balancer \
  --name $LB_NAME \
  --subnets $SUBNET1 $SUBNET2 \
  --security-groups $SECURITY_GROUP \
  --region $REGION \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

# ========================
# Step 4: Create Listener
# ========================
echo "🎧 Creating Listener..."
aws elbv2 create-listener \
  --load-balancer-arn $LB_ARN \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TG_ARN \
  --region $REGION

# ========================
# Step 5: Create Auto Scaling Group
# ========================
echo "⚙️ Creating Auto Scaling Group..."
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name $ASG_NAME \
  --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE,Version=1" \
  --min-size 1 \
  --max-size 3 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$SUBNET1,$SUBNET2" \
  --target-group-arns $TG_ARN \
  --region $REGION

echo "✅ Auto Scaling Group + Load Balancer setup completed!"
