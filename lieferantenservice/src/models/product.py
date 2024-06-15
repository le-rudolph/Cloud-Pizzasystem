from pydantic import BaseModel


class Product(BaseModel):
    Name: str
    Size: str
    Quantity: int
