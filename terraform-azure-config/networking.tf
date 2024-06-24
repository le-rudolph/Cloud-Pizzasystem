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
  sku                 = "Standard"
  sku_tier            = "Regional"
  tags                = {}
  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pizza.id
  }
}

// probe to check vm health
resource "azurerm_lb_probe" "lb_probe" {
  interval_in_seconds = 5
  loadbalancer_id     = azurerm_lb.pizza.id
  name                = "health_probe"
  number_of_probes    = 1
  port                = 3500
  probe_threshold     = 1
  protocol            = "Tcp"
}

// backend address pools for load balancer rules
resource "azurerm_lb_backend_address_pool" "pizza" {
  loadbalancer_id = azurerm_lb.pizza.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_backend_address_pool" "control_pool" {
  loadbalancer_id    = azurerm_lb.pizza.id
  name               = "control_pool"
  virtual_network_id = azurerm_virtual_network.pizza.id
}

resource "azurerm_lb_backend_address_pool" "worker_pool" {
  loadbalancer_id = azurerm_lb.pizza.id
  name            = "worker_pool"
}

resource "azurerm_lb_backend_address_pool" "address_pool" {
  count              = 2
  loadbalancer_id    = azurerm_lb.pizza.id
  name               = "pool${count.index}"
  virtual_network_id = azurerm_virtual_network.pizza.id
}

// load balancer rules to map requests to cluster machines
// ssh access rules
resource "azurerm_lb_rule" "control_ssh_rule" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.control_pool.id]
  backend_port                   = 22
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port                  = 22
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = azurerm_lb.pizza.id
  name                           = "ssh_control"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol                       = "Tcp"
}

resource "azurerm_lb_rule" "worker_ssh_rule" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.worker_pool.id]
  backend_port                   = 22
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port                  = 23
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = azurerm_lb.pizza.id
  name                           = "ssh_worker"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol                       = "Tcp"
}

// service access rules
resource "azurerm_lb_rule" "worker_bestellservice_rule" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.worker_pool.id]
  backend_port                   = 14621
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port                  = 80
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = azurerm_lb.pizza.id
  name                           = "pizza_bestellservice"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol                       = "Tcp"
}

resource "azurerm_lb_rule" "worker_produktservice_rule" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.worker_pool.id]
  backend_port                   = 3000
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port                  = 81
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = azurerm_lb.pizza.id
  name                           = "pizza_produktservice"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol                       = "Tcp"
}

resource "azurerm_lb_rule" "test_rule" {
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.address_pool[0].id]
  backend_port                   = 3001
  disable_outbound_snat          = false
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port                  = 3001
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIPProtocol"
  loadbalancer_id                = azurerm_lb.pizza.id
  name                           = "testing"
  probe_id                       = azurerm_lb_probe.lb_probe.id
  protocol                       = "Tcp"
}

// network interfaces for vms
resource "azurerm_network_interface" "pizza" {
  count               = 2
  name                = "acctni${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "pizzaIPConfig${count.index}"
    subnet_id                     = azurerm_subnet.pizza.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "pizza" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.pizza[count.index].id
  ip_configuration_name   = "pizzaIPConfig${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.address_pool[count.index].id
}

resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}
