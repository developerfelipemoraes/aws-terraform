import json
import os
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sqs = boto3.client("sqs")
TARGET_QUEUE_URL = os.environ["TARGET_QUEUE_URL"]

def handler(event, context):
    logger.info("Event received: %s", json.dumps(event))

    for record in event["Records"]:
        body = record["body"]
        logger.info("Processing message: %s", body)

        sqs.send_message(
            QueueUrl=TARGET_QUEUE_URL,
            MessageBody=json.dumps({
                "originalMessage": body,
                "processedBy": "lambda-poc"
            })
        )

    return {"status": "ok"}