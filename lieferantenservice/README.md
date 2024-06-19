# Lieferantenservice

Nimmt Orders aus der `order` Queue entgegen und bestätigt die Zustellung eine Weile später über eine zweite `delivery` Queue.

## Form der Bestellungen Beispiel

```json
{
    "Id": "ljkdrng45jdfngj4",
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

## Form der erledigten Lieferung Beispiel

```json
{
    "Id": "435jhb4h6gkj456",
    "Order": {
        "Id": "ljkdrng45jdfngj4",
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
