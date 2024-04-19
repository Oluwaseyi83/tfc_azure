# Create a Resource Group
resource "azurerm_resource_group" "testrg" {
  name     = "myResourceGroup"
  location = var.location # Change this to your desired region
}

#  Create Virtual Network
resource "azurerm_virtual_network" "testvn" {
  name                = "mytestVNet"
  resource_group_name = azurerm_resource_group.testrg.name
  location            = azurerm_resource_group.testrg.location
  address_space       = [var.address_space[0]]
}

resource "azurerm_availability_set" "azset" {
  name                         = "myAvailabilitySet"
  resource_group_name          = azurerm_resource_group.testrg.name
  location                     = azurerm_resource_group.testrg.location
  platform_fault_domain_count  = 2 # Specify the number of fault domains (availability zones)
  platform_update_domain_count = 2

  # Additional settings can be configured here if needed
}

# Create Availability Zones
resource "azurerm_subnet" "public_subnet_1" {
  name                 = "public_subnet_1"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes =   [var.address_prefixes[0]]
}

resource "azurerm_subnet" "public_subnet_2" {
  name                 = "public_subnet_2"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes     = [var.address_prefixes[1]]
}

resource "azurerm_subnet" "private_subnet_1" {
  name                 = "private_subnet_1"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes     = [var.address_prefixes[2]]
}

resource "azurerm_subnet" "private_subnet_2" {
  name                 = "private_subnet_2"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes     = [var.address_prefixes[3]]
}

# Security Group
resource "azurerm_network_security_group" "testSG" {
  name                = "securitygroup"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "testNIC" {
  name                = "test-nic"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
}






# resource "azurerm_linux_virtual_machine" "testVM" {
#   name                = "test-virtual-machine"
#   resource_group_name = azurerm_resource_group.testrg.name
#   location            = azurerm_resource_group.testrg.location
#   size                = var.vm_size
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.testNIC.id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("accesskeys.pub")
#   }

#   source_image_reference {
#     publisher = var.image_publisher
#     offer     = var.image_offer
#     sku       = var.image_sku
#     version   = var.image_version
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

# }