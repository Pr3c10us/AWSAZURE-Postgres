# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "NetworkSecurityGroup"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    # Set destination port range to 22 for SSH and 5432 for PostgreSQL
    destination_port_ranges     = ["22","5432"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "PublicIP"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "AZ_NIC"
  location            = var.resource_group_location
  resource_group_name =  var.resource_group_name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group =  var.resource_group_name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = var.resource_group_location
  resource_group_name      =  var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# # Create (and display) an SSH key
# resource "tls_private_key" "example_ssh" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "azure-pg"
  location              = var.resource_group_location
  resource_group_name   =  var.resource_group_name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
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
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
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

