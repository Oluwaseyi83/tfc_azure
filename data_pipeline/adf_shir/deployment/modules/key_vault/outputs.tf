output "key_vault_id" {
  value = azurerm_key_vault.vault.id
}

# output "admin_password_secret" {
#   value = azurerm_key_vault_secret.admin_user_password.value
# }
