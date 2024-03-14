terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }
}

terraform {
backend "azurerm" {
 resource_group_name  = "StateFileRG"
  storage_account_name = "statefilestorage01"
  container_name       = "tstate"
  key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  }



