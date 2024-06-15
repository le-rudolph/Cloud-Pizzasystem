from pydantic import BaseModel

from .product import Product


class Order(BaseModel):
    Id: int
    Products: list[Product]
    Total: int
