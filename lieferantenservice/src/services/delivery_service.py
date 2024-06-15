import random
import threading

from . import queue_service
from . import mongo_service
from .logger_service import logger

from models.order import Order
from models.delivery import Delivery


def deliver_order(order: Order):
    delivery_time = get_random_delivery_time()

    delivery = Delivery(Id=order.Id, Order=order, Delivery_time=delivery_time)
    mongo_service.insert_delivery(delivery=delivery)

    delivery_from_db = mongo_service.find_delivery(delivery.Id)
    logger.info(f"delivery in db: {delivery_from_db}")

    deliver_thread = threading.Timer(
        interval=delivery_time, function=finish_delivery, kwargs={"delivery": delivery})
    logger.info(f"starting delivery, ETA: {delivery_time}")
    deliver_thread.start()


def get_random_delivery_time():
    return random.randint(10, 60)


def finish_delivery(delivery: Delivery):
    logger.info(f"""finished delivery {delivery} in {
                delivery.Delivery_time} seconds""")
    queue_service.send_message(
        delivery.model_dump(),
        message_type=queue_service.SENDING_MESSAGE_TYPE_DELIVERY_FINISHED)
