import random
import threading

from . import queue_service
from .logger_service import logger

from models.order import Order


def deliver_order(order: Order):
    delivery_time = get_random_delivery_time()
    deliver_thread = threading.Timer(
        interval=delivery_time, function=finish_delivery, kwargs={"order": order, "delivery_time": delivery_time})
    logger.info(f"starting delivery, ETA: {delivery_time}")
    deliver_thread.start()


def get_random_delivery_time():
    return random.randint(10, 60)


def finish_delivery(order: Order, delivery_time: int):
    logger.info(f"finished delivery in {delivery_time} seconds")
    queue_service.send_message(
        {"Order": order.model_dump(), "Delivery_time": delivery_time},
        message_type=queue_service.SENDING_MESSAGE_TYPE_DELIVERY_FINISHED)
