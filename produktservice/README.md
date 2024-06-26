# Produktservice

Im Produktservice können neue Produkte mit Namen und einem Preis für
die Größen S, M und L erstellt werden. Der Produktservice ist über dem Port ``3000`` erreichbar. 
Die gespeicherten Produkte können über die URL ``/pizza`` abgefragt werden.

Die `docker-compose.yml` kann genutzt werden, um den Lieferantenservice alleine zu starten.

## Form der Produkte Beispiel

```json
{
  "Pommes": {
    "S": 300,
    "M": 400,
    "L": 500
  },
  "Pizza": {
    "S": 800,
    "M": 900
  }
}
```

## Quellcodestruktur

```
.
├── app.js              - Einstiegspunkt
├── docker-compose.yml  - 
├── Dockerfile          - Containerdefinition
├── model.js            - Datenstrukturen
├── package.json        - Nötige Abhängigkeiten
├── package-lock.json   
├── public              - Statische Dateien
│   ├── index.html
│   ├── script.js
│   └── style.css
└── README.md
```