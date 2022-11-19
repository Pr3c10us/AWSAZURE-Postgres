output "network_name" {
  value = azurerm_virtual_network.network.name
}

output "address_space" {
  value = azurerm_virtual_network.network.address_space
}

output "public_subnet_id" {
  value       = azurerm_subnet.public[0].id
  description = "the id of public subnet"
}