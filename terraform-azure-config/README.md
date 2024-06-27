# Terraform Config

In diesem Verzeichnis befindet sich die Terraform-Config, mit der die Infrastruktur des Systems beschrieben wird. Es werden zwei Linux VMs in einem virtuellen Netzwerk erstellt. Dieses ist über einen Load-Balancer mit einer Public-IP im Internet erreichbar. Ein Setup-Skript installiert Kubernetes auf den VMs und startet die beiliegenden Services.

```console
.
│   credentials_base.tf         - Template für credentials.tf
│   generated.tf                - Nicht Teil der Config, für Import von Ressourcen aus Azure 
│   imports.tf                  - Nicht Teil der Config, für Import von Ressourcen aus Azure 
│   main.tf                     - Definition Resource-Group, VM-Ressourcen, Ausführung Setup-Skript 
│   networking.tf               - Definition Netzwerkressourcen
│   outputs.tf                  - Definition des Deployment-Outputs
│   providers.tf                - Definition genutzter Provider (für terraform init)
│   README.md
│   ssh.tf                      - Erstellung SSH-Keys und File-Outputs
│   variables.tf                - Definition von Config-Variablen
├───scripts                     - Ordner für VM-Scripts
│       setup_control_node.sh   - Setup-Skript für Masternode
└───ssh                         - Dynamisch erstellt, enthält SSH-Keys
        private_key.pem
        public_key.pem
```

## Setup

Erfordert [AzureCLI](https://learn.microsoft.com/de-de/cli/azure/install-azure-cli) und [Terraform](https://developer.hashicorp.com/terraform/install). Für Terraform wird unter Windows die .exe einfach dem PATH hinzugefügt und das Tool dann auf der Konsole aufgerufen.

1. ``az login`` mit Credentials des Azure-Kontos. Die Subscription, unter der die Ressourcen erstellt werden sollen, muss ausgewählt werden.
2. `az account show` zeigt die aktuelle Subscription an. Ist hier nicht der korrekte Account zu sehen, kann mit `az account set --subscription "<SUBSCRIPTION_ID>"` gewechselt werden. Die ID ist im Azure-Portal zu finden.
3. `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"` erstellt einen Service Principal für Terraform, mit dem Aktionen in Azure durchgeführt werden können. Für diesen Befehl sind entsprechende Berechtigungen notwendig, insbesondere die Erlaubnis Rollen zuzuweisen. (Wir haben die Owner-Rolle benutzt, es sollte aber auch nur mit [RBAC-Permissions](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) möglich sein). Der Befehl liefert folgenden Output:

    ```console
    Creating 'Contributor' role assignment under scope '/subscriptions/<SUBSCRIPTION_ID>'
    The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
    {
    "appId": "xxxxxx-xxx-xxxx-xxxx-xxxxxxxxxx",
    "displayName": "azure-cli-2022-xxxx",
    "password": "xxxxxx~xxxxxx~xxxxx",
    "tenant": "xxxxx-xxxx-xxxxx-xxxx-xxxxx"
    }
    ```

    Diese Informationen müssen in einer Datei ``credentials.tf`` gespeichert werden. Ein Template ist als [`credentials_base.tf`](/terraform-azure-config/credentials_base.tf) hinterlegt.

    |AzureCLI  Output|credentials.tf mapping|
    |---|---|
    |``appId``|``client_id``|
    |``password``|``client_secret``|
    |``tenant``|``tenant_id``|
    |``'... /subscriptions/<SUBSCRIPTION_ID>'``|``subscription_id``|

4. ``terraform init`` initialisiert das Terraform backend und die Provider-Plugins.

## Deployment

Zum Deployment werden die folgenden Befehle im Verzeichnis `terraform-azure-config` ausgeführt:

1. ``terraform plan -out pizza_plan`` erstellt den Plan zur Herstellung der definierten Infrastruktur in einer Datei `pizza_plan`.
2. ``terraform apply "pizza_plan"`` führt den zuvor erstellten Plan aus.

Zum Schluss werden die erfolgreich erstellten Ressourcen angezeigt und Informationen, wie die Public-IP, ausgegeben. Diese Informationen können mit `terraform output` auch später erneut angezeigt werden.

### Setup-Skript

Das Kubernetescluster wird vom Skript [setup_control_node.sh](/terraform-azure-config/scripts/setup_control_node.sh) eingerichtet. Auf einer VM wird K3s installiert und als Master gestartet. Mit dem private SSH-Key wird auf der anderen VM ebenfalls K3s installiert. Diese VM tritt dem Cluster mit dem Mastertoken als Workernode bei. Das Skript klont das Github-Repository und nutzt die YAML-Files zum Deployment der Services. Dazu werden die Containerimages aus der Containerregistry des Github-Repositories gezogen.

### Nach dem Deployment

Nach kurzen Zeit sind die Services unter der ausgegebenen IP erreichbar. Das kann 1-5 Minuten dauern, da das Setup-Skript ohne Rückmeldung an Terraform arbeitet.

- Bestellservice - `http://<PUBLIC_IP>`
- Produktservice - `http://<PUBLIC_IP>:3000`

Die erstellten Ressourcen werden von Terraform in der Datei [``terraform.tfstate``](/terraform-azure-config/terraform.tfstate) verwaltet. Hier sind auch Daten, wie der private SSH-Key oder die Credentials gelistet.

Zur Auswertung des Deployments können die VMs untersucht werden. Im [Verzeichnis ssh](/terraform-azure-config/ssh) werden die SSH-Keys abgelegt, mit denen der Zugriff auf die VMs möglich ist. Sie sind erreichbar unter ``pizza@<PUBLIC_IP>:(22|23)``. Die Ports gehören den jeweiligen VMs.

SSH-Befehl z.B.:

`ssh -i ./ssh/private_key.pem pizza@<PUBLIC_IP>:22`

**Hinweis**: Unter Windows müssen unter Umständen strengere Berechtigungen für ``private_key.pem`` gesetzt werden (Datei -> Eigenschaften -> Sicherheit -> Erweitert -> Vererbung deaktivieren, überflüssige Nutzer entfernen, eigenen Vollzugriff setzen)

Zum Zerstören der Infrastruktur kann der Befehl `terraform destroy` ausgeführt werden.

## Quellen, Guides, Ressourcen

- Basiert auf dem [MS Quickstart Guide](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-cluster-create-terraform?tabs=azure-cli)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Remote Script Execution](https://stackoverflow.com/questions/54088476/terraform-azurerm-virtual-machine-extension/58776277#58776277)
