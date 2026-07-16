import json
import boto3

def handler(event, context):
    ec2 = boto3.client("ec2")
    resp = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}],
        MaxResults=10
    )
    instance_ids = []
    for r in resp.get("Reservations", []):
        for i in r.get("Instances", []):
            instance_ids.append(i["InstanceId"])

    return {**event, "statusCode": 200, "instanceIds": instance_ids[:2], "message": f"Targeting {len(instance_ids[:2])} instances."}
