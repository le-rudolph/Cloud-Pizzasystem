from pydantic import BaseModel

from .order import Order


class Delivery(BaseModel):
    Id: int
    Order: Order
    Delivery_time: int
