resource "azurerm_virtual_machine" "testVM" {
  name                  = "testvm"
  location              = azurerm_resource_group.testrg.location
  resource_group_name   = azurerm_resource_group.testrg.name
  network_interface_ids = [azurerm_network_interface.testNIC.id]
  vm_size               = "Standard_DS1_v2"

 storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "vmpassword1"
    admin_password = azurerm_key_vault_secret.vmpassword2.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Dev"
  }

  depends_on = [ azurerm_key_vault.testkeyvault ]
}




resource "azurerm_virtual_machine_extension" "self-ir-cs" {
  name                 = "self-hosted-ir-script"
  virtual_machine_id   = azurerm_virtual_machine.testVM.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  auto_upgrade_minor_version = true
  settings             = <<SETTINGS
    {
      "fileUris": ["${azurerm_storage_blob.copy_script.url}${data.azurerm_storage_account_sas.sas_token.sas}&sr=b"],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File gatewayInstall.ps1 ${azurerm_data_factory_integration_runtime_self_hosted.adf-ir.primary_authorization_key}"
    }
SETTINGS
}