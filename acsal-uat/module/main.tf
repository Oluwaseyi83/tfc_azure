resource "azurerm_resource_group" "example" {
    name = "rg_name"
    location = "Canada Central"
}

module "adf" {
    source = "./child/adf"
    data_factory_name = "goa-adf"
    resource_group_name = azurerm_resource_group.example.name
    location = azurerm_resource_group.example.location
  
}
