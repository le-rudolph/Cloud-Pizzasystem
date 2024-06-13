from pydantic import BaseModel


class Product(BaseModel):
    name: str
    price: int
    size: str


class Order(BaseModel):
    products: list[Product]
