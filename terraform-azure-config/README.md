# Terraform Config

Quellen, Guides, Ressourcen:

- Basiert auf dem [MS Quickstart Guide](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-cluster-create-terraform?tabs=azure-cli)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Remote Script Execution](https://stackoverflow.com/questions/54088476/terraform-azurerm-virtual-machine-extension/58776277#58776277)

## How to use

Erfordert [AzureCLI](https://learn.microsoft.com/de-de/cli/azure/install-azure-cli) und [Terraform](https://developer.hashicorp.com/terraform/install).

Im Ordner terraform-azure-config:

1. ``az login`` mit Credentials des Azure-Kontos. Die Subscription, unter der die Ressourcen erstellt werden sollen, muss ausgewählt werden.
2. ``terraform init`` initialisiert das Terraform backend und die Provider-Plugins.
3. ``terraform plan -out pizza_plan`` erstellt den Plan zur Herstellung der definierten Infrastruktur.
4. ``terraform apply "pizza_plan"`` führt den Plan aus.
