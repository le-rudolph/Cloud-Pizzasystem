# Cloud Pizzasystem

Demo-Projekt eines Microservice-Clusters in der Azurecloud.

## Services

Das Pizzasystem bietet die Möglichkeit Produkte zu bestellen und den Fortschritt der Bestellung zu verfolgen.
Zudem können neue Produkte der Karte hinzugefügt werden.

- [Produktservice](/produktservice)
- [Bestellservice](/bestellservice)
- [Lieferantenservice](/lieferantenservice)

Zum Testen ohne Kubernetes steht eine Definition für Docker Compose zur Verfügung.
Der Bestellservice steht dann unter http://localhost:14621 zur Verfügung,
der Produktservice unter http://localhost:3000.

- `docker compose up --build`

## Terraform Config

Die Services lassen sich mit der [Terraform Config](/terraform-azure-config/) in einem Kubernetescluster in Azure starten.

## Weitere Dokumentation

Die Powerpoint-Präsentation sowie die dokumentierten Sichten finden sich unter [docs](docs/).

## Bildquellenangaben zum Quellcode

Das Hintergrundbild des Bestellservices stammt aus der Wikimedia Commons. 
Das Bild "Pizza-3007395" stammt von Igor Ovsyannykov, und ist gemeinfrei veröffentlicht worden.
