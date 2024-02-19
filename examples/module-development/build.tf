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

module "eventgrid_system_topic" {
  source = "registry.terraform.io/libre-devops/eventgrid-system-topic/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.uid.id]

  name                   = "evgst-${var.short}-${var.loc}-${terraform.workspace}-${random_string.entropy.result}"
  topic_type             = "Microsoft.Storage.StorageAccounts"
  source_arm_resource_id = module.sa.storage_account_ids["sa${var.short}${var.loc}${var.env}01"]
}

module "eventgrid_system_topic_event_subscription" {
  source = "../../" # Assuming your module is located relative to the calling configuration

  eventgrid_system_event_subscriptions = [
    {
      name                                 = "eg-sub-${var.short}-${var.loc}-${var.env}-${random_string.entropy.result}"
      system_topic_name                    = module.eventgrid_system_topic.eventgrid_name
      rg_name                              = module.rg.rg_name
      expiration_time_utc                  = timeadd(local.now, "720h") # Example: 30 days from now
      event_delivery_schema                = "EventGridSchema"
      advanced_filtering_on_arrays_enabled = true

      azure_function_endpoint = {
        function_id                       = "function-app-id/functions/function-name"
        max_events_per_batch              = 100
        preferred_batch_size_in_kilobytes = 64
      }

      storage_queue_endpoint = {
        storage_account_id                    = module.sa.storage_account_ids["sa${var.short}${var.loc}${var.env}01"]
        queue_name                            = "eventqueue"
        queue_message_time_to_live_in_seconds = 86400 # 1 day
      }

      subject_filter = {
        subject_begins_with = "/blobServices/default/containers/name/log"
        subject_ends_with   = ".txt"
        case_sensitive      = false
      }

      advanced_filters = {
        bool_equals = [
          {
            key   = "DataVersion"
            value = true
          }
        ],
        string_contains = [
          {
            key    = "Subject"
            values = ["container1", "container2"]
          }
        ]
      }
    }
  ]
}
