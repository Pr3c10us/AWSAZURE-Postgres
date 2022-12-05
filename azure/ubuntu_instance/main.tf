# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "mySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = var.resource_group_location
  resource_group_name =  var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "postgresinstancestorage"
  location                 = var.resource_group_location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "azure-pg"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_D2ds_v4"
  admin_username        = "ubuntu"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("postgres-instance-key.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202209200"
  }
  # custom_data = filebase64("script-init.sh")

  # connection {
  #   type        = "ssh"
  #   host     = self.public_ip_address
  #   user     = self.admin_username
  #   private_key = file("postgres_id_rsa")
  # }
  # provisioner "file" {
  #   source      = "./script-init.sh"
  #   destination = "/tmp/script-init.sh"

  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo done",
  #     "tr -d '\r' </tmp/script-init.sh >a.tmp",
  #     "mv a.tmp script-init.sh",
  #     "chmod +x ./script-init.sh",
  #     "sudo ./script-init.sh",
  #   ]
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo ${azurerm_linux_virtual_machine.myterraformvm.public_ip_address}",
  #     "#sudo -i -u postgres sshpass -p 'postgres' ssh-copy-id postgres@${azurerm_linux_virtual_machine.myterraformvm.public_ip_address}",
  #   ]
  # }
}

