import json
import os
import boto3
import logging
from botocore.exceptions import ClientError

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

TABLE_NAME = os.getenv("TABLE_NAME", "list_service_dynmo")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }


def fetch_list():
    try:
        list_id = os.environ.get("list_id_value")
        resp = table.get_item(Key={"listId": list_id})
        LOG.info(f"DynamoDB response: {resp}")
        return resp.get("Item", {}).get("values", [])
    except ClientError as e:
        LOG.error(f"DynamoDB error: {e}")
        return []


def lambda_handler(event, context):
    LOG.info("Event: %s", json.dumps(event))

    path = event.get("path", "")
    LOG.info(f"Request path: {path}")

    list_data = fetch_list()
    LOG.info(f"Fetched list data: {list_data}")

    if not isinstance(list_data, list):
        LOG.error("Invalid input: 'list' must be a list")
        return response(400, {"error": "Invalid input, expected 'list' or 'listId'"})

    if path.endswith("/head"):
        LOG.info("Fetching head of the list")
        return head_of_list(list_data)
    elif path.endswith("/tail"):
        LOG.info("Fetching tail of the list")
        return tail_of_list(list_data)
    else:
        LOG.error("This API request is not supported")
        return response(400, {"error": "Unknown operation"})

# head function
def head_of_list(list_data):
    if list_data:
        return response(200, {"head": list_data[0]})
    else:
        return response(200, {"head": None})

# tail function
def tail_of_list(list_data):
    if list_data:
        return response(200, {"tail": list_data[1:]})
    else:
        return response(200, {"tail": []})