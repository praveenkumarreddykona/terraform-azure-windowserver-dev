output "resource_group_id" {
  description = "ID of the created resource group."
  value       = azurerm_resource_group.example_rg.id
}

output "key_vault_id" {
  description = "ID of the created Key Vault."
  value       = azurerm_key_vault.example_kv.id
}

output "nsg_id" {
  description = "ID of the created Network Security Group."
  value       = azurerm_network_security_group.example_nsg.id
}

output "nic_id" {
  description = "ID of the created Network Interface."
  value       = azurerm_network_interface.example_nic.id
}

output "vnet_id" {
  description = "ID of the created Virtual Network."
  value       = azurerm_virtual_network.example_vnet.id
}

output "public_ip_id" {
  description = "ID of the created Public IP Address."
  value       = azurerm_public_ip.example_pip.id
}

output "vm_id" {
  description = "ID of the created Virtual Machine."
  value       = azurerm_virtual_machine.example_vm.id
}