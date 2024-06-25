output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.pizza.name
}

output "subnet_name" {
  value = azurerm_subnet.pizza.name
}

output "public_ip" {
  value = azurerm_public_ip.pizza.ip_address
}

output "linux_virtual_machine_names" {
  value = [for s in azurerm_linux_virtual_machine.pizza : s.name[*]]
}
