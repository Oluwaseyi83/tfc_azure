# Create a Resource Group
resource "azurerm_resource_group" "testrg" {
  name     = "myResourceGroup"
  location = var.location # Change this to your desired region
}

resource "azurerm_data_factory" "main" {
  name                            = "seyitestadf"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.testrg.name
  managed_virtual_network_enabled = true
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "adf-ir" {
  name            = "Self-Hosted-IR"
  data_factory_id = azurerm_data_factory.main.id
}


output "data_factory_id" {
  value = azurerm_data_factory.main.id
}

