# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"

/*
resource "azurerm_lb" "pizza" {
  edge_zone           = null
  location            = "germanywestcentral"
  name                = "loadBalancer"
  resource_group_name = "rg-useful-goblin"
  sku                 = "Basic"
  sku_tier            = "Regional"
  tags                = {}
  frontend_ip_configuration {
    gateway_load_balancer_frontend_ip_configuration_id = null
    name                                               = "publicIPAddress"
    private_ip_address                                 = null
    private_ip_address_allocation                      = "Dynamic"
    private_ip_address_version                         = null
    public_ip_address_id                               = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/publicIPAddresses/publicIPForLB"
    public_ip_prefix_id                                = null
    subnet_id                                          = null
    zones                                              = []
  }
}

*/