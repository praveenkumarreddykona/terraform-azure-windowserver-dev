resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {  
  name     = var.rg-name
  location = var.location[var.locationCode]
  tags = {
    ExpirationDate = formatdate("M/D/YYYY", timeadd(timestamp(), "${(var.Timeperiod+1)*24}h"))
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.vm-name}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"
  sku_tier            = "Regional"
}


resource "azurerm_key_vault" "vault" {
  name                       = "kv-${var.vm-name}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "List",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}


resource "azurerm_key_vault_secret" "secret" {
  name         = "secret-${var.vm-name}"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.vault.id
}


resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm-name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "PORT_3389"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix    = var.access-ip
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm-name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/24"]
  subnet {
    name           = "private"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.nsg.id
  }
}

data "azurerm_subnet" "snet" {
  name = "private"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
}
output "DeploymentDetails" {
    value = data.azurerm_subnet.snet.id
  }

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm-name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.vm-name}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.sizes[var.vm-size]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.skus[var.os-version]
    version   = "latest"
  }
  storage_os_disk {
    name              = "SMAOsDisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
   os_profile {
    computer_name  = "${var.vm-name}"
    admin_username = "sysadmin"
    admin_password = random_password.password.result
  }
  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  virtual_machine_id = azurerm_virtual_machine.vm.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = var.shutdown_loction_code[var.locationCode]

  notification_settings {
    enabled         = false
  }
 }