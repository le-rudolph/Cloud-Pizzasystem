# Lieferantenservice

Der Lieferantenservice nimmt Orders aus der `order` Queue entgegen und bestätigt die Zustellung eine Weile später über eine zweite
`delivery` Queue. Der Service ist als Python Skript realisiert, das die Queue regelmäßig abfragt.

Die `docker-compose.yaml` kann genutzt werden, um den Lieferantenservice alleine zu starten.

Die Bestellungen werden vom Bestellservice in die Queue geschrieben. Die Form der Objekte, die so ausgetauscht werden,
ist unten dargestellt.

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

## Quellcodestruktur

```
.
├── docker-compose.yaml
├── Dockerfile
├── README.md
├── requirements.txt                - pip packages
└── src
    ├── main.py                     - Einstiegspunkt
    ├── models                      - Datenstrukturen
    │   ├── delivery.py
    │   ├── order.py
    │   └── product.py
    └── services
        ├── delivery_service.py     - Simulation Lieferung
        ├── logger_service.py       - Logging Konfiguration     
        ├── mongo_service.py        - Datenbankzugriffe
        └── queue_service.py        - Queue-Bearbeitung
```

## Umgebungsvariablen

Queue setup:

- `QUEUE_HOST`: Hostname der Queue
- `QUEUE_NAME`: Name der Queue in RabbitMQ
- `QUEUE_USER`: Username in RabbitMQ
- `QUEUE_PASS`: Passwort in RabbitMQ

MongoDB credentials:

- `MONGO_HOST`: Hostname der MongoDB
- `MONGO_PORT`: Zu benutzender Port
- `MONGO_USER`: Username
- `MONGO_PASS`: Passwort