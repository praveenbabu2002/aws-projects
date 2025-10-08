#!/bin/bash
set -e
# ==========================
REGION="us-east-1"
KEY_NAME="shiva-key" 
SECURITY_GROUP="sg-018db3c0ab76d5335" 
INSTANCE_TYPE="t2.micro" 
SUBNET1="subnet-02c94c6a4c7457772"
SUBNET2="subnet-068bfe729a9a6fbe1"
VPC_ID="vpc-0413f00473d65bf18" 

# ======= Names ========
LAUNCH_TEMPLATE="my-launch-template-v3"
ASG_NAME="my-auto-scaling-group-v3"
TG_NAME="my-target-group-v3"
LB_NAME="my-load-balancer"

# ============= SCRIPT START =============

# Step 1: Create Launch Template
echo "# Step 1: Create Launch Template"
echo "Checking if Launch Template already exists..."

# Checking if Launch Template already exists
if aws ec2 describe-launch-templates --launch-template-names $LAUNCH_TEMPLATE --region $REGION >/dev/null 2>&1; then
    echo "Launch Template $LAUNCH_TEMPLATE already exists. Skipping creation."
else
    echo "Creating Launch Template..."
    aws ec2 create-launch-template \
    --launch-template-name $LAUNCH_TEMPLATE \
    --launch-template-data '{
        "KeyName": "'$KEY_NAME'",
        "ImageId": "ami-0123456789abcdef0", 
        "InstanceType": "'$INSTANCE_TYPE'",
        "SecurityGroupIds": ["'$SECURITY_GROUP'"],
        "UserData": "'$(echo '#!/bin/bash
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "<h1>Hello from Auto Scaling + Load Balancer</h1>" > /var/www/html/index.html | base64)'"
    }' \
    --region $REGION
fi

# Step 2: Create Target Group
echo
echo "# Step 2: Create Target Group"
echo "Creating Target Group..."
TG_ARN=$(aws elbv2 create-target-group \
    --name $TG_NAME \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type instance \
    --region $REGION \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
echo "Target Group ARN: $TG_ARN"

# Step 3: Create Load Balancer
echo
echo "# Step 3: Create Load Balancer"
echo "Creating Load Balancer..."
LB_ARN=$(aws elbv2 create-load-balancer \
    --name $LB_NAME \
    --subnets $SUBNETS \
    --security-groups $SECURITY_GROUP \
    --region $REGION \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)
echo "Load Balancer ARN: $LB_ARN"

# Step 4: Create Listener
echo
echo "# Step 4: Create Listener"
echo "Checking and Creating Listener..."

# Use describe-listeners and filter the output to check for an existing listener on port 80
if aws elbv2 describe-listeners --load-balancer-arn $LB_ARN --query "Listeners[?Port=='80']" --output text --region $REGION | grep -q 'arn'; then
    echo "Listener on port 80 already exists. Skipping creation."
else
    echo "Creating Listener..."
    aws elbv2 create-listener \
        --load-balancer-arn $LB_ARN \
        --protocol HTTP \
        --port 80 \
        --default-actions Type=forward,TargetGroupArn=$TG_ARN \
        --region $REGION

    if [ $? -eq 0 ]; then
        echo "Listener created successfully."
    else
        echo "Error creating Listener. Check AWS CLI output above."
        exit 1
    fi
fi

# Step 5: Create Auto Scaling Group
echo
echo "# Step 5: Create Auto Scaling Group"
echo "Creating Auto Scaling Group..."
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name $ASG_NAME \
    --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE,Version='1'" \
    --min-size 1 \
    --max-size 3 \
    --desired-capacity 1 \
    --target-group-arns $TG_ARN \
    --vpcs $VPC_ID \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --vpc-zone-identifier "$SUBNETS" \
    --region $REGION

echo "Auto Scaling Group + Load Balancer setup completed!"
