resource "null_resource" "tfc_test" {
    provisioner "local-exec" {
        command = "echo 'test_config'"
      
    }
  
}


terraform {
  cloud {
    organization = "OYADEYI-TECH-SERVICES"

    workspaces {
      name = "azure_dev_workspace"
    }
  }
}
 
provider "azurerm" {
  features {}

  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id
  client_id         = var.client_id
  client_secret     = var.client_secret
}


variable "subscription_id" {
  type = string
  default = "value"
}

variable "tenant_id" {
  type = string
  default = "value"
}

variable "location" {
  type = string
  default = "value"
}

variable "client_id" {
  type = string
  default = "value"
}

variable "client_secret" {
  type = string
  default = "value"
}



# Create a Resource Group
resource "azurerm_resource_group" "testrg" {
  name     = "myResourceGroup"
  location = "East US" # Change this to your desired region
}

#  Create Virtual Network
resource "azurerm_virtual_network" "testvn" {
  name                = "mytestVNet"
  resource_group_name = azurerm_resource_group.testrg.name
  location            = azurerm_resource_group.testrg.location
  address_space       = ["10.0.0.0/16"]
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
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "public_subnet_2" {
  name                 = "public_subnet_2"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "private_subnet_1" {
  name                 = "private_subnet_1"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "private_subnet_2" {
  name                 = "private_subnet_2"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.testvn.name
  address_prefixes     = ["10.0.4.0/24"]
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

resource "azurerm_linux_virtual_machine" "testVM" {
  name                = "test-virtual-machine"
  resource_group_name = azurerm_resource_group.testrg.name
  location            = azurerm_resource_group.testrg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.testNIC.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("accesskeys.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}


////////////////////////////////////////////////////////////////////////////////////////
creation of container and blob storage

resource "azurerm_storage_container" "test_container" {
  name                  = "containerterraform"
  storage_account_name  = azurerm_storage_account.test_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob_storage" {
  name                   = "blobstorageterraform"
  storage_account_name   = azurerm_storage_account.test_storage_account.name
  storage_container_name = azurerm_storage_container.test_container.name
  type                   = "Block"
}



////////////////////////////////////////////////////////////////////////////

 to create mysql_db_server
resource "azurerm_mysql_server" "mysqlserver" {
  name                = "mysqlserver-tf"
  location            = azurerm_resource_group.Data_PipelineRG.location
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name

  administrator_login          = "myadmin"
  administrator_login_password = "admin@12345"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "mysqltest_db" {
  name                = "mysqltestdb_tf"
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  server_name         = azurerm_mysql_server.mysqlserver.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"

  # prevent the possibility of accidental data loss
  lifecycle { prevent_destroy = false }
}


resource "azurerm_data_factory_dataset_data_lake_storage_gen2" "AthletesADLSdataset" {
  name                = "AthletesADLS"
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  data_factory_id     = azurerm_data_factory.test_adf.id
  format_type         = "DelimitedText"
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.data_lake_storage_ls.name
  file_system         = "azuredatalaketest"
  folder_path         = "raw_data"
  file_name           = []
  import_schema       = []
  annotations         = []
  compression_type    = []
  parameters          = {}

  depends_on = [azurerm_storage_data_lake_gen2_path.raw_data]

}