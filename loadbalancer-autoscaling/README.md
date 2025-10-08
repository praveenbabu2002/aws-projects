# AWS Auto Scaling and Load Balancer Project Deployment Script

This repository contains the necessary script to deploy a basic, highly available web service on Amazon Web Services (AWS) using an **Application Load Balancer (ALB)** and an **Auto Scaling Group 
(ASG)**.

## Project Overview

The deployment script `launch_asg.sh` automates the creation of the following resources:

1.  **EC2 Launch Template (`my-launch-template-v3`):** Defines the configuration for the EC2 instances, including the AMI, instance type, and a basic bootstrap script to install and run the Apache 
web server (`httpd`) with an "It works!" page.
2.  **Target Group (`$TG_NAME`):** Routes traffic to the registered EC2 instances on port 80.
3.  **Load Balancer (`$LB_NAME`):** Distributes incoming web traffic across the instances in the Target Group.
4.  **Load Balancer Listener:** Listens for HTTP traffic on port 80 and forwards it to the Target Group.
5.  **Auto Scaling Group (`my-auto-scaling-group`):** Manages the fleet of EC2 instances, ensuring that a desired number of instances are running at all times (Min=1, Max=3).

## Prerequisites

* An active **AWS Account**.
* **AWS CLI** installed and configured with appropriate credentials.
* **VPC** and **Subnets** configured in the target region (US-EAST-1).
* The `launch_asg.sh` script must be executable (`chmod +x launch_asg.sh`).

## Usage

### 1. Review and Modify Variables

Before running, open `launch_asg.sh` and ensure the following variables match your AWS environment:

```bash
# Variables defined in the script
REGION="us-east-1"
# ...
VPC_ID="vpc-0413f00473d65bf18" 
SUBNET1_ID="subnet-02c94c6a4c7457772" 
SUBNET2_ID="subnet-068bfe729a9a6fbe1"
KEY_NAME="my-key"
# ...
