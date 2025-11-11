# AWS Lambda + S3 Trigger (Simulation)

This mini-project demonstrates how an **AWS Lambda function** can be triggered automatically when a file is uploaded to an **S3 bucket**.

### 🧩 Concepts Covered
- AWS Lambda
- Amazon S3
- Event-driven architecture

### ⚙️ How It Works
1. A file upload event in S3 triggers a Lambda function.
2. The Lambda function receives event metadata (bucket name, file name).
3. The function processes or logs the event (simulation shown here).

### 🗂 Files
- `lambda_function.py` — Lambda function logic.
- `event.json` — Sample S3 event payload.

### 🚀 Output Example