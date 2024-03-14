terraform {
  cloud {
    organization = "Olu_Organization"

    workspaces {
      name = "First_Project_Workspace"
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




