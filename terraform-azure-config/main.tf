// random names for unique azure resources
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

// resource group to be created
resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
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

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.pizza_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myosdisk${count.index}"
  }

  custom_data    = base64encode(tls_private_key.pizza_ssh.private_key_pem)
  admin_username = var.username
}

resource "azurerm_managed_disk" "pizza" {
  count                = 2
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_virtual_machine_data_disk_attachment" "pizza" {
  count              = 2
  managed_disk_id    = azurerm_managed_disk.pizza[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.pizza[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

// execute setup scripts on vms 
resource "azurerm_virtual_machine_extension" "control_node_setup" {
  depends_on         = [azurerm_linux_virtual_machine.pizza[0], azurerm_linux_virtual_machine.pizza[1]]
  virtual_machine_id = azurerm_linux_virtual_machine.pizza[0].id
  name               = azurerm_linux_virtual_machine.pizza[0].name

  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
  {
      "script": "${base64encode(file(var.control_node_setup_script))}"
  }
  PROT
}
