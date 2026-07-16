import json
import boto3

def handler(event, context):
    instance_ids = event.get("instanceIds", [])
    if not instance_ids:
        return {**event, "statusCode": 200, "states": {}, "message": "No instances to check."}

    ec2 = boto3.client("ec2")
    resp = ec2.describe_instances(InstanceIds=instance_ids)
    states = {}
    for r in resp.get("Reservations", []):
        for i in r.get("Instances", []):
            states[i["InstanceId"]] = i["State"]["Name"]

    return {**event, "statusCode": 200, "states": states, "instanceIds": instance_ids}
