import json
import boto3
import time

def handler(event, context):
    instance_ids = event.get("instanceIds", [])
    if not instance_ids:
        return {**event, "statusCode": 200, "result": "NOOP", "message": "No instances to disrupt."}

    ec2 = boto3.client("ec2")
    action = event.get("action", "stop")

    try:
        if action == "stop":
            ec2.stop_instances(InstanceIds=instance_ids)
            return {**event, "statusCode": 200, "result": "STOPPED", "instanceIds": instance_ids, "action": action}
        elif action == "reboot":
            ec2.reboot_instances(InstanceIds=instance_ids)
            return {**event, "statusCode": 200, "result": "REBOOTED", "instanceIds": instance_ids, "action": action}
        else:
            return {**event, "statusCode": 200, "result": "UNKNOWN_ACTION", "action": action}
    except Exception as e:
        return {**event, "statusCode": 500, "error": str(e), "instanceIds": instance_ids}
