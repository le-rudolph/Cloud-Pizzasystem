# Bestellservice

Hier können Bestellungen getätigt, und der Status dieser angezeigt werden.
Das Zubereiten einer Zustellung wird simuliert und nach einer zufälligen Zeit abgeschlossen.

Der Service ist in Go geschrieben,
der Container besteht letztlich nur aus der erzeugten Binary,
in der alle Abhängigkeiten und statische Dateien enthalten sind.

Es bestehen folgende Abhängigkeiten zu den anderen Services:
- Vom Produktservice werden beim Seitenaufruf die Produkte per HTTP abgerufen.
- Bestellungen und deren Status werden in einer MongoDB abgelegt.
- "Lieferfähige" Bestellungen werden an einer RabbitMQ abgegeben,
  und "gelieferte" Bestellungen von dort abgerufen.

```mermaid
graph LR
    b[<b>Bestellservice</b>]
    m[MongoDB]
    q[RabbitMQ]
    p[Produktservice]
    
    b --> m
    b -->|Frage Produkte ab| p
    b -->|Sende lieferbereite Bestellungen,<br>Warte auf gelieferte Bestellungen| q
```

## Quellcodestruktur

```
.
├── config.go   - Konfiguration aus Umgebungsvariablen
├── Dockerfile
├── go.mod      - Abhängigkeiten
├── go.sum      - Prüfsummen der Abhängigkeiten
├── main.go     - Einstiegspunkt
├── queue.go    - Simulation von Küche und Senden/Empfangen von Bestellung von/zu Eventqueue
├── README.md
├── server.go   - HTTP-Routinen
├── static      - Statische Dateien
│   ├── pizza.jpg
│   └── style.css
├── templates   - HTML-Vorlagen
│   ├── index.gohtml
│   └── status.gohtml
└── types.go    - Datenstrukturen
```

## Umgebungsvariablen

* `QUEUE_URI`: Uri zur RabbitMQ im Format `amqp://nutername:passwort@hostname:port`
* `DATABASE_URI`: Uri zur MongoDB im Format `mongodb://nutzername:passwort@hostname`
* `DATABASE_DB`: Collection in der MongoDB
* `SERVER_ADDRESS`: eigene Adresse des Webservers im Format `ip-adresse:port`, Standardwert ist hier `0.0.0.0:14621`
* `PRODUCTS_URL`: URL zum Produktservice im Format `http://hostname/endpunkt/`
