# Cloud Pizzasystem

Demo-Projekt eines Microservice-Clusters in der Azurecloud.

## Services

Das Pizzasystem bietet die Möglichkeit Produkte zu bestellen und den Fortschritt der Bestellung zu verfolgen. Zudem können neue Produkte der Karte hinzugefügt werden.

- [Produktservice](/Produktservice)
- [Bestellservice](/bestellen)
- [Lieferantenservice](/lieferantenservice)

## Terraform Config

Die services lassen sich mit der [Terraform Config](/terraform-azure-config/) in einem Kubernetescluster in Azure starten.
