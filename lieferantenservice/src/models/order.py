from pydantic import BaseModel

from .product import Product


class Order(BaseModel):
    products: list[Product]
    total: int
