module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${var.env}-${random_string.entropy.result}"
  location = local.location
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}


resource "azurerm_user_assigned_identity" "uid" {
  name                = "uid-${var.short}-${var.loc}-${var.env}-${random_string.entropy.result}"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = module.rg.rg_tags
}

locals {
  now                 = timestamp()
  seven_days_from_now = timeadd(timestamp(), "168h")
}

module "sa" {
  source = "cyber-scot/storage-account/azurerm"
  storage_accounts = [
    {
      name     = "sa${var.short}${var.loc}${var.env}01"
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      identity_type = "UserAssigned"
      identity_ids  = [azurerm_user_assigned_identity.uid.id]

      network_rules = {
        bypass                     = ["AzureServices", "Logging", "Metrics"]
        default_action             = "Allow"
        ip_rules                   = []
        virtual_network_subnet_ids = []
      }
    }
  ]
}


module "event_grid_system_topic" {
  source = "../../"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.uid.id]

  name                   = "evgst-${var.short}-${var.loc}-${terraform.workspace}-${random_string.entropy.result}"
  topic_type             = "Microsoft.Storage.StorageAccounts"
  source_arm_resource_id = module.sa.storage_account_ids["sa${var.short}${var.loc}${var.env}01"]
}
