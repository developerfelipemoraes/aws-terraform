import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda handler for processing SQS events.
    Adapts the provided long-running consumer logic to event-driven Lambda.
    """
    logger.info("🚀 Lambda consumer started processing batch")

    messages = event.get("Records", [])
    if not messages:
        logger.info("No messages in event")
        return

    for msg in messages:
        try:
            body = msg["body"]
            logger.info(f"📥 Mensagem recebida: {body}")

            # Parsing JSON as per the original logic
            payload = json.loads(body)
            logger.info(f"✅ Processado com sucesso: {payload}")

        except Exception as e:
            logger.error(f"❌ Erro ao processar mensagem: {e}")
            # In a real-world scenario, we might want to raise the exception
            # or return batchItemFailures so the message isn't deleted from the queue.
            # To match the original script's "catch and log" behavior (which effectively consumes the message),
            # we suppress the exception here.
            pass

    return {"statusCode": 200, "body": "Batch processed"}
