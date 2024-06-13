# Lieferantenservice

Form der Bestellungen Beispiel:

```json
{
    "products": [
        {
            "name": "salami pizza",
            "quantity": 2
        },
        {
            "name": "pizza hawaii",
            "quantity": 12
        }
    ],
    "total": 42
}
```

Form der erledigten Lieferung Beispiel:

```json
{
    "Order": {
        "products": [
            {
                "name": "salami pizza",
                "quantity": 2
            },
            {
                "name": "pizza hawaii",
                "quantity": 12
            }
        ],
        "total": 42
    },
    "Delivery_time": 31
}
```
