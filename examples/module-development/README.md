```hcl
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

resource "azurerm_storage_queue" "queue" {
  name                 = "queue1"
  storage_account_name = module.sa.storage_account_names["sa${var.short}${var.loc}${var.env}01"]
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
      name                                 = "egsub-${var.short}-${var.loc}-${var.env}-${random_string.entropy.result}"
      system_topic_name                    = module.eventgrid_system_topic.eventgrid_name
      rg_name                              = module.rg.rg_name
      expiration_time_utc                  = timeadd(local.now, "720h") # Example: 30 days from now
      event_delivery_schema                = "EventGridSchema"
      advanced_filtering_on_arrays_enabled = true

      storage_queue_endpoint = {
        storage_account_id                    = module.sa.storage_account_ids["sa${var.short}${var.loc}${var.env}01"]
        queue_name                            = azurerm_storage_queue.queue.name
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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.91.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventgrid_system_topic"></a> [eventgrid\_system\_topic](#module\_eventgrid\_system\_topic) | registry.terraform.io/libre-devops/eventgrid-system-topic/azurerm | n/a |
| <a name="module_eventgrid_system_topic_event_subscription"></a> [eventgrid\_system\_topic\_event\_subscription](#module\_eventgrid\_system\_topic\_event\_subscription) | ../../ | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | registry.terraform.io/libre-devops/rg/azurerm | n/a |
| <a name="module_sa"></a> [sa](#module\_sa) | cyber-scot/storage-account/azurerm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_queue.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_user_assigned_identity.uid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.entropy](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current_creds](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.mgmt_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.mgmt_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_ssh_public_key.mgmt_ssh_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/ssh_public_key) | data source |
| [azurerm_user_assigned_identity.mgmt_user_assigned_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | This is passed as an environment variable, it is for the shorthand environment tag for resource.  For example, production = prod | `string` | `"prd"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The shorthand name of the Azure location, for example, for UK South, use uks.  For UK West, use ukw. Normally passed as TF\_VAR in pipeline | `string` | `"uks"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of this resource | `string` | `"tst"` | no |
| <a name="input_short"></a> [short](#input\_short) | This is passed as an environment variable, it is for a shorthand name for the environment, for example hello-world = hw | `string` | `"lbd"` | no |

## Outputs

No outputs.
