from models.product import Product
from models.order import Order


o = Order(products=[Product(name='salami pizza', quantity=2),
          Product(name='pizza hawaii', quantity=12)], total=42)

print(o.model_json_schema())
print(o.model_dump_json())
