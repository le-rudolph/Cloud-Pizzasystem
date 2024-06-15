# Lieferantenservice

## Form der Bestellungen Beispiel

```json
{
    "Id": 7,
    "Products": [
        {
            "Name": "salami pizza",
            "Size": "m",
            "Quantity": 2
        },
        {
            "Name": "pizza hawaii",
            "Size": "l",
            "Quantity": 12
        }
    ],
    "Total": 42
}
```

- optional ``"Cash_payment": bool``?
- Barzahlung implizit über Existenz von ``"Total"``?

## Form der erledigten Lieferung Beispiel

```json
{
    "Id": "666d77ef367eda697f99e3c5",
    "Order": {
        "Id": 7,
        "Products": [
            {
                "Name": "salami pizza",
                "Size": "m",
                "Quantity": 2
            },
            {
                "Name": "pizza hawaii",
                "Size": "l",
                "Quantity": 12
            }
        ],
        "Total": 42
    },
    "Delivery_time": 47
}
```

- ``Id`` von mongo db? Oder gleiche ``Id`` wie ``Order``?
