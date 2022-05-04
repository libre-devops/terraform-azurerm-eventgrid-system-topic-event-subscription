```hcl
// This module does not consider for CMKs and allows the users to manually set bypasses
#checkov:skip=CKV2_AZURE_1:CMKs are not considered in this module
#checkov:skip=CKV2_AZURE_18:CMKs are not considered in this module
#checkov:skip=CKV_AZURE_33:Storage logging is not configured by default in this module
#tfsec:ignore:azure-storage-queue-services-logging-enabled tfsec:ignore:azure-storage-allow-microsoft-service-bypass #tfsec:ignore:azure-storage-default-action-deny
module "sa" {
  source = "registry.terraform.io/libre-devops/storage-account/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  storage_account_name            = "st${var.short}${var.loc}${terraform.workspace}01"
  access_tier                     = "Hot"
  identity_type                   = "SystemAssigned"
  allow_nested_items_to_be_public = true

  storage_account_properties = {

    // Set this block to enable network rules
    network_rules = {
      default_action = "Allow"
    }

    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      default_service_version  = "2020-06-12"
      last_access_time_enabled = false

      deletion_retention_policies = {
        days = 10
      }

      container_delete_retention_policy = {
        days = 10
      }
    }

    routing = {
      publish_internet_endpoints  = false
      publish_microsoft_endpoints = true
      choice                      = "MicrosoftRouting"
    }
  }
}

#tfsec:ignore:azure-storage-no-public-access
resource "azurerm_storage_container" "event_grid_blob" {
  name                  = "blob${var.short}${var.loc}${terraform.workspace}01"
  storage_account_name  = module.sa.sa_name
  container_access_type = "container"
}

module "event_hub_namespace" {
  source = "registry.terraform.io/libre-devops/event-hub-namespace/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  event_hub_namespace_name = "evhns-${var.short}-${var.loc}-${terraform.workspace}-01"
  identity_type            = "SystemAssigned"
  settings = {
    sku                  = "Standard"
    capacity             = 1
    auto_inflate_enabled = false
    zone_redundant       = false

    network_rulesets = {
      default_action                 = "Deny"
      trusted_service_access_enabled = true

      virtual_network_rule = {
        subnet_id                                       = element(values(module.network.subnets_ids), 0) // uses sn1
        ignore_missing_virtual_network_service_endpoint = false
      }
    }
  }
}

module "event_hub" {
  source = "registry.terraform.io/libre-devops/event-hub/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  event_hub_name     = "evh-${var.short}-${var.loc}-${terraform.workspace}-01"
  namespace_name     = module.event_hub_namespace.name
  storage_account_id = module.sa.sa_id

  settings = {

    status            = "Active"
    partition_count   = "1"
    message_retention = "1"

    capture_description = {
      enabled             = false
      encoding            = "Avro"
      interval_in_seconds = "60"
      size_limit_in_bytes = "10485760"
      skip_empty_archives = false

      destination = {
        name                = "EventHubArchive.AzureBlockBlob"
        archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
        blob_container_name = azurerm_storage_container.event_grid_blob.name
      }
    }
  }
}

module "event_grid_system_topic" {
  source = "registry.terraform.io/libre-devops/eventgrid-system-topic/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  identity_type = "SystemAssigned"

  event_grid_name        = "evgst-${var.short}-${var.loc}-${terraform.workspace}-01"
  topic_type             = "Microsoft.Storage.StorageAccounts"
  source_arm_resource_id = module.sa.sa_id
}

module "event_grid_system_topic_subscription" {
  source = "registry.terraform.io/libre-devops/eventgrid-system-topic-event-subscription/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  event_subscription_name = "evgsub-${var.short}-${var.loc}-${terraform.workspace}-01"

  event_delivery_schema = "EventGridSchema"
  system_topic_name     = module.event_grid_system_topic.eventgrid_name
  eventhub_endpoint_id  = module.event_hub.id

  eventgrid_settings = {
    storage_blob_dead_letter_destination = {
      storage_account_id          = module.sa.sa_id
      storage_blob_container_name = azurerm_storage_container.event_grid_blob.name
    }
  }
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventgrid_system_topic_event_subscription.event_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_filtering_on_arrays_enabled"></a> [advanced\_filtering\_on\_arrays\_enabled](#input\_advanced\_filtering\_on\_arrays\_enabled) | Whether advanced filtered should be evaluated against an array instead of a single value | `bool` | `false` | no |
| <a name="input_event_delivery_schema"></a> [event\_delivery\_schema](#input\_event\_delivery\_schema) | The scheme for the event delivery service | `string` | n/a | yes |
| <a name="input_event_subscription_name"></a> [event\_subscription\_name](#input\_event\_subscription\_name) | The name of the event subscription | `string` | n/a | yes |
| <a name="input_eventgrid_settings"></a> [eventgrid\_settings](#input\_eventgrid\_settings) | The map block which contains nested settings | `any` | n/a | yes |
| <a name="input_eventhub_endpoint_id"></a> [eventhub\_endpoint\_id](#input\_eventhub\_endpoint\_id) | The ID of an eventhub endpoint if used | `string` | `null` | no |
| <a name="input_expiration_time_utc"></a> [expiration\_time\_utc](#input\_expiration\_time\_utc) | The expiration time in RFC 3339 format | `string` | `null` | no |
| <a name="input_hybrid_connection_endpoint_id"></a> [hybrid\_connection\_endpoint\_id](#input\_hybrid\_connection\_endpoint\_id) | The ID of an hybrid\_connection endpoint if used | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_included_event_types"></a> [included\_event\_types](#input\_included\_event\_types) | A list of event types that the event grid is searching for | `list(any)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | The Labels of the event grid | `list(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_service_bus_queue_endpoint_id"></a> [service\_bus\_queue\_endpoint\_id](#input\_service\_bus\_queue\_endpoint\_id) | The ID of an service bus queue endpoint if used | `string` | `null` | no |
| <a name="input_service_bus_topic_endpoint_id"></a> [service\_bus\_topic\_endpoint\_id](#input\_service\_bus\_topic\_endpoint\_id) | The ID of an service bus topic endpoint if used | `string` | `null` | no |
| <a name="input_system_topic_name"></a> [system\_topic\_name](#input\_system\_topic\_name) | The name of the system topic the subscription is to join | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eventgrid_system_topic_event_subscription_id"></a> [eventgrid\_system\_topic\_event\_subscription\_id](#output\_eventgrid\_system\_topic\_event\_subscription\_id) | The id of the custom subscription |
| <a name="output_eventgrid_system_topic_event_subscription_labels"></a> [eventgrid\_system\_topic\_event\_subscription\_labels](#output\_eventgrid\_system\_topic\_event\_subscription\_labels) | The labels of the custom subscription |
| <a name="output_eventgrid_system_topic_event_subscription_name"></a> [eventgrid\_system\_topic\_event\_subscription\_name](#output\_eventgrid\_system\_topic\_event\_subscription\_name) | The name of the custom subscription |
