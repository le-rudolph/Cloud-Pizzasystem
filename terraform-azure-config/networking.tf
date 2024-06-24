// virtual network for the cluster
resource "random_pet" "azurerm_virtual_network_name" {
  prefix = "vnet"
}

resource "azurerm_virtual_network" "pizza" {
  name                = random_pet.azurerm_virtual_network_name.id
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

// subnet in the virtual network
resource "random_pet" "azurerm_subnet_name" {
  prefix = "sub"
}

resource "azurerm_subnet" "pizza" {
  name                 = random_pet.azurerm_subnet_name.id
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.pizza.name
  address_prefixes     = ["10.0.2.0/24"]
}

// public ip to reach cluster
resource "azurerm_public_ip" "pizza" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

// load balancer
resource "azurerm_lb" "pizza" {
  location            = azurerm_resource_group.rg.location
  name                = "loadBalancer"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  sku_tier            = "Regional"
  tags                = {}
  frontend_ip_configuration {
    name                          = "publicIPAddress"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pizza.id
  }
}


# __generated__ by Terraform from "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/probes/ssh_test"
resource "azurerm_lb_probe" "lb_probe" {
  interval_in_seconds = 5
  loadbalancer_id     = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name                = "ssh_test"
  number_of_probes    = 1
  port                = 3500
  probe_threshold     = 1
  protocol            = "Tcp"
  request_path        = null
}

resource "azurerm_lb_backend_address_pool" "pizza" {
  loadbalancer_id = azurerm_lb.pizza.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_backend_address_pool" "control_pool" {
  loadbalancer_id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name            = "control_pool"
}

resource "azurerm_lb_backend_address_pool" "worker_pool" {
  loadbalancer_id = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name            = "worker_pool"
}


# __generated__ by Terraform from "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/pizza_bestellservice"
resource "azurerm_lb_rule" "worker_bestellservice_rule" {
  backend_address_pool_ids       = ["/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/backendAddressPools/worker_pool"]
  backend_port                   = 14621
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = "publicIPAddress"
  frontend_port                  = 81
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name                           = "pizza_bestellservice"
  probe_id                       = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/probes/ssh_test"
  protocol                       = "Tcp"
}

# __generated__ by Terraform from "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/ssh_test"
resource "azurerm_lb_rule" "control_ssh_rule" {
  backend_address_pool_ids       = ["/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/backendAddressPools/control_pool"]
  backend_port                   = 22
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = "publicIPAddress"
  frontend_port                  = 22
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name                           = "ssh_test"
  probe_id                       = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/probes/ssh_test"
  protocol                       = "Tcp"
}

# __generated__ by Terraform from "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/ssh_worker"
resource "azurerm_lb_rule" "worker_ssh_rule" {
  backend_address_pool_ids       = ["/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/backendAddressPools/worker_pool"]
  backend_port                   = 22
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = "publicIPAddress"
  frontend_port                  = 23
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name                           = "ssh_worker"
  probe_id                       = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/probes/ssh_test"
  protocol                       = "Tcp"
}

# __generated__ by Terraform from "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/loadBalancingRules/pizza_produktservice"
resource "azurerm_lb_rule" "worker_produktservice_rule" {
  backend_address_pool_ids       = ["/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/backendAddressPools/worker_pool"]
  backend_port                   = 3000
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = "publicIPAddress"
  frontend_port                  = 80
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer"
  name                           = "pizza_produktservice"
  probe_id                       = "/subscriptions/3466a3af-b29e-40a9-b653-d18a7c1dd1af/resourceGroups/rg-useful-goblin/providers/Microsoft.Network/loadBalancers/loadBalancer/probes/ssh_test"
  protocol                       = "Tcp"
}

resource "azurerm_network_interface" "pizza" {
  count               = 2
  name                = "acctni${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "pizzaIPConfig"
    subnet_id                     = azurerm_subnet.pizza.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}
