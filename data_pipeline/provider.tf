terraform {
  cloud {
    organization = "Olu_Organization"

    workspaces {
      name = "First_Project_Workspace"
    }
  }

  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.94.0"
    }
  }
}

provider "azurerm" {
  features {}
}




