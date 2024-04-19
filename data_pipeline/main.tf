resource "azurerm_resource_group" "Data_PipelineRG" {
  name     = "Data_PipelineRG"
  location = var.location
}

resource "azurerm_data_factory" "test_adf" {
  name                = "testadfterraform"
  location            = azurerm_resource_group.Data_PipelineRG.location
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  tags                = { Env = "Dev" }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "SelfHostedIR" {
  name            = "SelfHostedIR"
  data_factory_id = azurerm_data_factory.test_adf.id
}

resource "azurerm_data_factory_linked_service_web" "web_ls" {
  name                = "httplinkedservice"
  data_factory_id     = azurerm_data_factory.test_adf.id
  authentication_type = "Anonymous"
  url                 = "https://raw.githubusercontent.com/kaoutharElbakouri/2021-Olympics-in-Tokyo-Data/main/Athletes.csv"

  depends_on = [azurerm_data_factory.test_adf]
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "data_lake_storage_ls" {
  name                 = "datalakestoragels"
  data_factory_id      = azurerm_data_factory.test_adf.id
  use_managed_identity = true
  url                  = "https://storageaccterraformseyi.dfs.core.windows.net/"

  depends_on = [azurerm_data_factory.test_adf]
}

resource "azurerm_data_factory_dataset_http" "AthletesCSVdataset" {
  name                = "AthletesCSV"
  data_factory_id     = azurerm_data_factory.test_adf.id
  linked_service_name = azurerm_data_factory_linked_service_web.web_ls.name


  relative_url   = "https://raw.githubusercontent.com/kaoutharElbakouri/2021-Olympics-in-Tokyo-Data/main/Athletes.csv"
  request_method = "GET"


  depends_on = [azurerm_data_factory_linked_service_web.web_ls]
}

resource "azurerm_data_factory_custom_dataset" "AthletesADLS" {
  name            = "AthletesADLS"
  data_factory_id = azurerm_data_factory.test_adf.id
  type            = "DelimitedText"

  linked_service {
    name = azurerm_data_factory_linked_service_data_lake_storage_gen2.data_lake_storage_ls.name
  }

  type_properties_json = <<JSON
{
  "location": {
    "container":"azuredatalaketest",
    "folderPath": "raw_data",
    "type":"AzureBlobStorageLocation"
  }
}
JSON
  depends_on           = [azurerm_data_factory_linked_service_data_lake_storage_gen2.data_lake_storage_ls]
}



resource "azurerm_storage_account" "test_storage_account" {
  name                     = "storageaccterraformseyi"
  resource_group_name      = azurerm_resource_group.Data_PipelineRG.name
  location                 = azurerm_resource_group.Data_PipelineRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
  tags                     = { Env = "Dev" }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "azuredatalake_test" {
  name               = "azuredatalaketest"
  storage_account_id = azurerm_storage_account.test_storage_account.id
}


resource "azurerm_storage_data_lake_gen2_path" "raw_data" {
  path               = "raw_data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.azuredatalake_test.name
  storage_account_id = azurerm_storage_account.test_storage_account.id
  resource           = "directory"
}

resource "azurerm_storage_data_lake_gen2_path" "tranformed_data" {
  path               = "transformed_data"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.azuredatalake_test.name
  storage_account_id = azurerm_storage_account.test_storage_account.id
  resource           = "directory"
}

resource "azurerm_databricks_workspace" "databricks-test" {
  name                = "databricks-test_tf"
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  location            = azurerm_resource_group.Data_PipelineRG.location
  sku                 = "standard"
  tags                = { Env = "Dev" }
}

resource "azurerm_synapse_workspace" "synapse_workspace_tf" {
  name                                 = "synapse-workspace-tf"
  resource_group_name                  = azurerm_resource_group.Data_PipelineRG.name
  location                             = azurerm_resource_group.Data_PipelineRG.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.azuredatalake_test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "admin@12345"

  aad_admin {
    login     = "AzureAD Admin"
    object_id = "8d356d25-4253-43e5-9ac4-d018b8f8689e"
    tenant_id = "7c7586db-a1e1-4f37-ac42-03088c6ba25f"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = { Env = "Dev" }
}

resource "azurerm_service_plan" "test_appservice" {
  name                = "test_appservice"
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  location            = azurerm_resource_group.Data_PipelineRG.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "test_appservice" {
  name                = "test-appserviceseyi"
  location            = azurerm_resource_group.Data_PipelineRG.location
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  service_plan_id     = azurerm_service_plan.test_appservice.id

  site_config {}
}


