import boto3
import json
import os

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    
    detail = event.get('detail', {})
    instance_id = None
    
    # Extract instance ID from GuardDuty finding
    if 'resource' in detail and 'instanceDetails' in detail['resource']:
        instance_id = detail['resource']['instanceDetails']['instanceId']
    
    if not instance_id:
        print("No instance ID found in event")
        return
    
    # Stop the instance
    try:
        ec2.stop_instances(InstanceIds=[instance_id])
        message = f"GuardDuty detected a threat. Instance {instance_id} has been stopped."
        print(message)
    except Exception as e:
        message = f"Failed to stop instance {instance_id}: {e}"
        print(message)
    
    # Send SNS alert
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="GuardDuty Alert: Instance Isolated",
        Message=message
    )

    return {"status": "completed", "instance": instance_id}