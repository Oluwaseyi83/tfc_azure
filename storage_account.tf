resource "azurerm_storage_account" "olwaseyiteststorageaccoun1" {
  name                            = "seyiteststorageaccoun1"
  resource_group_name             = azurerm_resource_group.testrg.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = false
  large_file_share_enabled        = true
  allow_nested_items_to_be_public = false
  
}

resource "azurerm_storage_container" "testcontainer" {
  name                  = "testcontainer"
  storage_account_name  = azurerm_storage_account.olwaseyiteststorageaccoun1.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "copy_script" {
  name                   = "./scripts/gatewayInstall.sh"
  storage_account_name   = azurerm_storage_account.olwaseyiteststorageaccoun1.name
  storage_container_name = azurerm_storage_container.testcontainer.name
  type                   = "Block"
  source                 = "./scripts/gatewayInstall.sh"
}

data "azurerm_storage_account_sas" "sas_token" {
  connection_string = azurerm_storage_account.olwaseyiteststorageaccoun1.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "15m")

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
  depends_on = [
    azurerm_storage_blob.copy_script
  ]
}

output "storage_account_name" {
  value = azurerm_storage_account.olwaseyiteststorageaccoun1.name
}

output "storage_account_connectiong_string" {
  value = azurerm_storage_account.olwaseyiteststorageaccoun1.primary_blob_connection_string
  sensitive = true
}

output "blob_url" {
  value = azurerm_storage_blob.copy_script.url
}

output "sas_url_query_string" {
  value = data.azurerm_storage_account_sas.sas_token.sas
  sensitive = true
}