import boto3
import os

def lambda_handler(event, context):
    # Retrieve the S3 bucket and key from the event
    s3_bucket = event['Records'][0]['s3']['bucket']['name']
    s3_key = event['Records'][0]['s3']['object']['key']

    # Create an S3 client
    s3_client = boto3.client('s3')

    try:
        # Download the file from S3 to /mnt/efs
        destination_path = '/mnt/efs/' + os.path.basename(s3_key)
        s3_client.download_file(s3_bucket, s3_key, destination_path)
        print(f"File downloaded and moved to: {destination_path}")
        
        # If needed, you can add additional logic here.

    except Exception as e:
        print(f"Error downloading file: {str(e)}")

    print("After : ", os.listdir("/mnt/efs"))

    return {
        'statusCode': 200,
        'body': 'File downloaded and moved successfully'
    }
