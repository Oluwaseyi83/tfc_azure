import {
  to = azurerm_resource_group.Sub1_RG
  id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG"
}

resource "azurerm_resource_group" "Sub1_RG" {
  name     = "Sub1_RG"
  location = var.location 

  tags  = { Env = "Dev" }
}


import {
  to = azurerm_data_factory.consoleadf
  id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG/providers/Microsoft.DataFactory/factories/consoleadf"
}

resource "azurerm_data_factory" "consoleadf" {
  name                            = "consoleadf"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.Sub1_RG.name
  managed_virtual_network_enabled = true
  identity {
    type = "SystemAssigned"
  }
  tags  = { Env = "Dev" }

}

import {
  to = azurerm_data_factory_integration_runtime_self_hosted.SHIR
  id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG/providers/Microsoft.DataFactory/factories/consoleadf/integrationruntimes/SHIR"
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "SHIR" {
  name            = "SHIR"
  description = "For Onpremise DB"
  data_factory_id = azurerm_data_factory.consoleadf.id
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


import {
  to = azurerm_key_vault.KeyVaultOluwaseyi
  id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG/providers/Microsoft.KeyVault/vaults/KeyVaultOluwaseyi"
}

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "KeyVaultOluwaseyi" {
  name                = "KeyVaultOluwaseyi"
  location            = azurerm_resource_group.Sub1_RG.location
  resource_group_name = azurerm_resource_group.Sub1_RG.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

import {
  to = azurerm_data_factory_linked_service_key_vault.AzureKeyVault1
  id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG/providers/Microsoft.DataFactory/factories/consoleadf/linkedservices/AzureKeyVault1"
}

resource "azurerm_data_factory_linked_service_key_vault" "AzureKeyVault1" {
  name            = "AzureKeyVault1"
  data_factory_id = azurerm_data_factory.consoleadf.id
  key_vault_id    = azurerm_key_vault.KeyVaultOluwaseyi.id
}

import {
  to = azurerm_data_factory_linked_service_sql_server.SqlServerLinkedService
  id = "/subscriptions/0549fbff-7954-4588-8cde-a47a5fb0af5f/resourceGroups/Sub1_RG/providers/Microsoft.DataFactory/factories/consoleadf/linkedservices/SqlServerLinked Service"
}   

resource "azurerm_data_factory_linked_service_sql_server" "SqlServerLinkedService" {
  name              = "SqlServerLinked Service"
  data_factory_id   = azurerm_data_factory.consoleadf.id
  integration_runtime_name = "SHIR"
  connection_string = "Integrated Security=False;Data Source=OLUWASEYI;Initial Catalog=seyidemodb;User ID=OLUWASEYI"

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.AzureKeyVault1.name
    secret_name         = "password"
  }
}

