from pydantic import BaseModel

from .product import Product


class Order(BaseModel):
    Id: str
    Products: list[Product]
    Total: int
