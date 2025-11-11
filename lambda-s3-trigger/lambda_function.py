import json

def lambda_handler(event, context):
    # Extract S3 bucket and file name from event
    bucket = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']

    print(f"New file uploaded to S3 bucket: {bucket}")
    print(f"File name: {file_name}")

    # Simulate processing logic
    message = f"Processed file '{file_name}' from bucket '{bucket}'."

    return {
        'statusCode': 200,
        'body': json.dumps(message)
    }