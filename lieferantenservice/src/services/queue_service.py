import json
import os
import threading
from time import sleep
import pika
import pika.adapters.blocking_connection
from pika.adapters.blocking_connection import BlockingChannel
import pika.channel
import pika.credentials
import pika.exceptions
from pydantic_core import ValidationError

from models.order import Order

from .logger_service import logger
from .delivery_service import deliver_order

QUEUE_HOST = os.environ["QUEUE_HOST"]
QUEUE_USER = os.environ["QUEUE_USER"]
QUEUE_PASS = os.environ["QUEUE_PASS"]
QUEUE_NAME_INCOMING = os.environ["QUEUE_NAME"]
QUEUE_NAME_OUTGOING = "delivery"
RECEIVING_MESSAGE_TYPE = "orders.deliveries.new"
RECEIVING_MESSAGE_CONTENT_TYPE = "application/json"

SENDING_QUEUE_EXCHANGE = ""
SENDING_MESSAGE_TYPE_DELIVERY_FINISHED = "orders.deliveries.finish"
SENDING_MESSAGE_CONTENT_TYPE = "application/json"

connection = None
channel: BlockingChannel | None = None
lock = threading.Lock()


def connect_queue():
    global channel, connection

    logger.info(f"connecting to queue at {QUEUE_HOST}")
    queue_credentials = pika.credentials.PlainCredentials(
        username=QUEUE_USER, password=QUEUE_PASS)
    connection_params = pika.ConnectionParameters(
        host=QUEUE_HOST,
        credentials=queue_credentials,
        connection_attempts=5,
        retry_delay=3
    )
    try:
        connection = pika.BlockingConnection(connection_params)
    except pika.exceptions.AMQPConnectionError as e:
        logger.warning("could not connect to queue")
        raise e

    channel = connection.channel()
    channel.queue_declare(queue=QUEUE_NAME_INCOMING)
    channel.queue_declare(queue=QUEUE_NAME_OUTGOING)
    logger.info(f"""connection established with queue {
        QUEUE_NAME_INCOMING} at {QUEUE_HOST}""")


def setup_consumer(callback):
    global channel
    if channel is not None:
        channel.basic_consume(
            queue=QUEUE_NAME_INCOMING, on_message_callback=callback, auto_ack=True)
    else:
        raise RuntimeError("queue not connected")


def start_listening():
    """Start listening on order queue. Main loop of the service is here.

    Raises:
        RuntimeError: Raises error, if queue is not connected.
    """
    global channel, connection, lock
    if channel is not None:
        logger.info(f"listening for orders on {QUEUE_NAME_INCOMING}")
        try:
            # main event loop, with lock to enable multi-threading
            while connection is not None:
                with lock:
                    # get events
                    connection.process_data_events(time_limit=0)
                sleep(1)
        finally:
            connection.close()  # type: ignore
    else:
        raise RuntimeError("queue not connected")


def receive_message(channel, method, properties: pika.BasicProperties, body):
    """Callback for consuming messages from the queue.

    Args:
        channel: queue channel
        method: method
        properties (pika.BasicProperties): properties
        body: body
    """

    if properties.type != RECEIVING_MESSAGE_TYPE:
        logger.warning("received wrong message type, skipping")
        return

    if properties.content_type != RECEIVING_MESSAGE_CONTENT_TYPE:
        logger.warning(
            f"received wrong content-type {properties.content_type}, '{RECEIVING_MESSAGE_CONTENT_TYPE}' required")
        return

    try:
        received_order = Order.model_validate_json(body)
        logger.info(f"received order {received_order}")
        deliver_order(order=received_order)
    except ValidationError as e:
        logger.error(e)


def send_message(body: dict, message_id: str = "", message_type: str = ""):
    """Send messages to the queue.

    Args:
        body (dict): Dict to send as JSON.
        message_id (str, optional): Message ID. Defaults to "".
        message_type (str, optional): Message type. Defaults to "".
    """

    global channel, sending_properties, lock
    if channel is not None:
        body_string = json.dumps(body)

        sending_properties = pika.BasicProperties(
            content_type=SENDING_MESSAGE_CONTENT_TYPE, type=message_type, message_id=message_id)

        # lock to use connection across threads
        with lock:
            channel.basic_publish(exchange=SENDING_QUEUE_EXCHANGE,
                                  routing_key=QUEUE_NAME_OUTGOING,
                                  body=body_string,
                                  properties=sending_properties)
            logger.info(f"send message to {QUEUE_NAME_OUTGOING} queue")


def start_queue():
    connect_queue()
    setup_consumer(callback=receive_message)
    start_listening()
