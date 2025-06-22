module "avm-res-resources-resourcegroup" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name = "${var.name_prefix}-rg"
  location = var.location
  tags = var.tags
}
module "avm-res-operationalinsights-workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  enable_telemetry                          = true
  location                                  = module.avm-res-resources-resourcegroup.resource.location
  resource_group_name                       = module.avm-res-resources-resourcegroup.name
  name                                      = "${var.name_prefix}-law"
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = "PerGB2018"
}
data "azurerm_client_config" "this" {}
resource "random_string" "name_suffix" {
  length  = 4
  special = false
  upper   = false
}
module "avm-res-keyvault-vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  enable_telemetry    = true
  location            = module.avm-res-resources-resourcegroup.resource.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  name                = "${var.name_prefix}-kv-${random_string.name_suffix.result}"
  tenant_id           = data.azurerm_client_config.this.tenant_id
  network_acls        = null

  diagnostic_settings = {
    to_la = {
      name                  = "${var.name_prefix}-kv-diags"
      workspace_resource_id = module.avm-res-operationalinsights-workspace.resource_id
    }
  }

  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.this.object_id
    }
  }
}