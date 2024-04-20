data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "testkeyvault" {
  name                        = "seyitestkeyvault"
  location                    = azurerm_resource_group.testrg.location
  resource_group_name         = azurerm_resource_group.testrg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Create", "Delete", "Get", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]

    secret_permissions = [ "Get","Set","Get","List", "Delete", "Purge", "Recover", "Restore" ]

    storage_permissions = [
      "Get",
    ]
  }
}


resource "azurerm_key_vault_secret" "vmpassword2" {
  name         = "vmpassword2"
  value        = random_password.vmpassword2.result
  key_vault_id = azurerm_key_vault.testkeyvault.id

  depends_on = [ azurerm_key_vault.testkeyvault ]
}

resource "random_password" "vmpassword2" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}