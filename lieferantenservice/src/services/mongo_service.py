import os
from time import sleep
import pymongo

from models.delivery import Delivery
from .logger_service import logger

DELIVERY_DB = "delivery"
DELIVERY_COLLECTION = "deliveries"
DB_HOST = os.environ["MONGO_HOST"]
DB_PORT = os.environ["MONGO_PORT"]
DB_USER = os.environ["MONGO_USER"]
DB_PASS = os.environ["MONGO_PASS"]

retries = 5
while retries > 0:
    mongo_client = pymongo.MongoClient(
        f"""mongodb://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}""")
    retries -= 1
    sleep(3)

logger.info(f"connected to mongodb at '{DB_HOST}'")
delivery_db = mongo_client[DELIVERY_DB]
delivery_collection = delivery_db[DELIVERY_COLLECTION]


def insert_delivery(delivery: Delivery):
    result = delivery_collection.insert_one(delivery.model_dump())
    logger.info(f"inserted delivery with id {result.inserted_id}")
    return str(result.inserted_id)
