resource "azurerm_resource_group" "Sub1_RG_uat" {
  name     = "Sub_RG_uat"
  location = var.location 

  tags  = { Env = "Dev" }
}


resource "azurerm_data_factory" "consoleadf_uat" {
  name                            = "consoleadf-uat"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.Sub1_RG_uat.name
  managed_virtual_network_enabled = true
  identity {
    type = "SystemAssigned"
  }
  tags  = { Env = "uat" }

}


resource "azurerm_data_factory_integration_runtime_self_hosted" "SHIR_uat" {
  name            = "SHIRuat"
  description = "For Onpremise DB"
  data_factory_id = azurerm_data_factory.consoleadf_uat.id
}

# import {
#   to = azurerm_data_factory_integration_runtime_azure.AutoResolvedIntegrationRuntime
#   id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG/providers/Microsoft.DataFactory/factories/consoleadf/integrationruntimes/AutoResolvedIntegrationRuntime"
# }

# resource "azurerm_data_factory_integration_runtime_azure" "AutoResolvedIntegrationRuntime" {
#   name            = "AutoResolvedIntegrationRuntime"
#   data_factory_id = azurerm_data_factory.consoleadf.id
#   location        = azurerm_resource_group.Sub1_RG.location
# }



data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "KeyVaultOluwaseyi_uat" {
  name                = "KeyVaultOluwaseyiuat"
  location            = azurerm_resource_group.Sub1_RG_uat.location
  resource_group_name = azurerm_resource_group.Sub1_RG_uat.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}


resource "azurerm_data_factory_linked_service_key_vault" "AzureKeyVault1_uat" {
  name            = "KeyVault1uat"
  data_factory_id = azurerm_data_factory.consoleadf_uat.id
  key_vault_id    = azurerm_key_vault.KeyVaultOluwaseyi_uat.id
}


resource "azurerm_data_factory_linked_service_sql_server" "SqlServerLinkedService_uat" {
  name              = "SqlServerLinked Service_uat"
  data_factory_id   = azurerm_data_factory.consoleadf_uat.id
  integration_runtime_name = "SHIRuat"
  connection_string = "Integrated Security=False;Data Source=OLUWASEYI;Initial Catalog=seyidemodb;User ID=OLUWASEYI"

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.AzureKeyVault1_uat.name
    secret_name         = "password"
  }
}

resource "azurerm_storage_account" "olwaseyiteststorageaccoun1" {
  name                            = "seyiteststorageaccoun1"
  resource_group_name             = azurerm_resource_group.Sub1_RG_uat.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = false
  large_file_share_enabled        = true
  allow_nested_items_to_be_public = false
  
}

resource "azurerm_storage_account" "olwaseyiteststorageaccoun11" {
  name                            = "seyiteststorageaccoun11"
  resource_group_name             = azurerm_resource_group.Sub1_RG_uat.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = false
  large_file_share_enabled        = true
  allow_nested_items_to_be_public = false
  
}

# resource "azurerm_storage_container" "testcontainer" {
#   name                  = "testcontainer"
#   storage_account_name  = azurerm_storage_account.olwaseyiteststorageaccoun1.name
#   container_access_type = "private"
# }