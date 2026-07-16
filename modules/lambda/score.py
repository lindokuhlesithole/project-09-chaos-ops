import json
import boto3
import datetime
import os

def handler(event, context):
    table_name = event.get("dynamodbTable") or os.environ.get("DYNAMODB_TABLE")
    experiment_id = event.get("experimentId", "unknown")
    states = event.get("states", {})
    action = event.get("action", "stop")

    total = len(states)
    if total == 0:
        score = 100
    else:
        stopped = sum(1 for s in states.values() if s in ["stopped", "stopping"])
        score = int((stopped / total) * 100) if action == "stop" else 100

    record = {
        "experimentId": experiment_id,
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "score": score,
        "action": action,
        "states": states,
        "totalInstances": total
    }

    if table_name:
        ddb = boto3.resource("dynamodb").Table(table_name)
        ddb.put_item(Item=record)

    return {**event, "statusCode": 200, "score": score, "record": record}
