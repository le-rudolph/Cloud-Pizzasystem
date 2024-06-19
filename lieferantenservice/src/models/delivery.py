from pydantic import BaseModel

from .order import Order


class Delivery(BaseModel):
    Id: str | None = None
    Order: Order
    Delivery_time: int
