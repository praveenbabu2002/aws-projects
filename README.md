# 🌩️ AWS Cloud Projects

This repository contains hands-on AWS cloud projects to learn and practice 
deploying applications on AWS services like **S3** and **EC2**.

---

## 📂 Project Structure

- **index.html** → Sample website file hosted on AWS S3  
- **s3_website.sh** → Shell script to create an S3 bucket, configure it 
for static website hosting, and upload files  
- **launch_ec2.sh** → Shell script to launch an EC2 instance  
- **README.md** → Documentation of the project  

---

## 🚀 Projects

### 1. Static Website Hosting on AWS S3
- Creates an S3 bucket with a unique name  
- Uploads `index.html`  
- Configures bucket for static website hosting  
- Generates a public website URL  

🔗 **Live Demo:**  
[http://praveen-website-21020.s3-website.ap-south-1.amazonaws.com](http://praveen-website-21020.s3-website.ap-south-1.amazonaws.com)

---

### 2. Launching an EC2 Instance
- Automates EC2 instance creation using a shell script  
- Configurable region and AMI ID  
- Useful for deploying backend servers or apps  

---

## 🛠️ Prerequisites

- AWS Account with IAM user & credentials configured (`aws configure`)  
- AWS CLI installed → [Install 
Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  
- Git installed → [Install 
Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  

---

## ⚡ How to Use

Clone the repo:
```bash
git clone https://github.com/praveenbabu2002/aws-projects.git
cd aws-projects
