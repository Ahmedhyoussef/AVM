terraform {
  required_version = "~> 1.9"
  required_providers {
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id
}