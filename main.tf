terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.22.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "homelabrg" {
  name     = var.rgname
  location = var.rglocation
}

# create security group
resource "azurerm_network_security_group" "homelabsg" {
  name                = "homelab-security-group"
  location            = azurerm_resource_group.homelabrg.location
  resource_group_name = azurerm_resource_group.homelabrg.name

  security_rule {
    name                       = "allow-rdp-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389" # allow rdp on this port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# network security group
resource "azurerm_virtual_network" "homelabvnet" {
  name                = var.vnname
  location            = azurerm_resource_group.homelabrg.location
  resource_group_name = azurerm_resource_group.homelabrg.name
  address_space       = ["10.0.0.0/16"] # cidr of 10.0.0.0/16
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24" #subnet in virtual network with 10.0.1.0/24 prefix
    security_group = azurerm_network_security_group.homelabsg.id
  }

  tags = {
    environment = "homelab"
  }
}

# need network interface and public ip to connect
# create public ip
resource "azurerm_public_ip" "example" {
  name                = "homelabpublicip"
  resource_group_name = azurerm_resource_group.homelabrg.name
  location            = azurerm_resource_group.homelabrg.location
  allocation_method   = "Static"

  tags = {
    environment = "homelab"
  }
}

# create network interface
resource "azurerm_network_interface" "example" {
  name                = var.niname
  location            = azurerm_resource_group.homelabrg.location
  resource_group_name = azurerm_resource_group.homelabrg.name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

data "azurerm_subnet" "example" {
  name = var.snname
  #virtual_network_name = "homelab-net"
  virtual_network_name = azurerm_virtual_network.homelabvnet.name
  resource_group_name  = azurerm_resource_group.homelabrg.name
  #resource_group_name  = azurerm_virtual_network.homelabvnet.name # hard coding this broke it for some reason
}

output "subnet_id" {
  value = data.azurerm_subnet.example.id
}

# create windows vm
resource "azurerm_windows_virtual_machine" "example" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.homelabrg.name
  location            = azurerm_resource_group.homelabrg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}