// random names for unique azure resources
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

// resource group to be created
resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

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

resource "azurerm_public_ip" "pizza" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "pizza" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.pizza.id
  }
}

resource "azurerm_lb_backend_address_pool" "pizza" {
  loadbalancer_id = azurerm_lb.pizza.id
  name            = "BackEndAddressPool"
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

resource "random_pet" "azurerm_linux_virtual_machine_name" {
  prefix = "vm"
}

resource "azurerm_linux_virtual_machine" "pizza" {
  count                 = 2
  name                  = "${random_pet.azurerm_linux_virtual_machine_name.id}${count.index}"
  location              = azurerm_resource_group.rg.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.pizza[count.index].id]
  size                  = "Standard_A2_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.username
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myosdisk${count.index}"
  }

  computer_name  = "hostname"
  admin_username = var.username
}

resource "azurerm_managed_disk" "pizza" {
  count                = 2
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1024"
}

resource "azurerm_virtual_machine_data_disk_attachment" "pizza" {
  count              = 2
  managed_disk_id    = azurerm_managed_disk.pizza[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.pizza[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}
