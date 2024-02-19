```hcl
resource "azurerm_eventgrid_system_topic_event_subscription" "event_subscription" {
  for_each = { for k, v in var.eventgrid_system_event_subscriptions : k => v }

  name                                 = each.value.name
  system_topic                         = each.value.system_topic_name
  resource_group_name                  = each.value.rg_name
  expiration_time_utc                  = each.value.expiration_time_utc
  event_delivery_schema                = each.value.event_delivery_schema
  advanced_filtering_on_arrays_enabled = each.value.advanced_filtering_on_arrays_enabled
  labels                               = each.value.labels
  eventhub_endpoint_id                 = each.value.eventhub_endpoint_id
  hybrid_connection_endpoint_id        = each.value.hybrid_connection_endpoint_id
  service_bus_queue_endpoint_id        = each.value.service_bus_queue_endpoint_id
  service_bus_topic_endpoint_id        = each.value.service_bus_topic_endpoint_id
  included_event_types                 = each.value.included_event_types

  dynamic "storage_queue_endpoint" {
    for_each = each.value.storage_queue_endpoint != null ? [each.value.storage_queue_endpoint] : []
    content {
      storage_account_id                    = storage_queue_endpoint.value.storage_account_id
      queue_name                            = storage_queue_endpoint.value.queue_name
      queue_message_time_to_live_in_seconds = storage_queue_endpoint.value.queue_message_time_to_live_in_seconds
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = each.value.azure_function_endpoint != null ? [each.value.azure_function_endpoint] : []
    content {
      function_id                       = azure_function_endpoint.value.function_id
      max_events_per_batch              = azure_function_endpoint.value.max_events_per_batch
      preferred_batch_size_in_kilobytes = azure_function_endpoint.value.preferred_batch_size_in_kilobytes
    }
  }

  dynamic "webhook_endpoint" {
    for_each = each.value.webhook_endpoint != null ? [each.value.webhook_endpoint] : []
    content {
      url                               = webhook_endpoint.value.url
      max_events_per_batch              = webhook_endpoint.value.max_events_per_batch
      preferred_batch_size_in_kilobytes = webhook_endpoint.value.preferred_batch_size_in_kilobytes
      active_directory_tenant_id        = webhook_endpoint.value.active_directory_tenant_id
      active_directory_app_id_or_uri    = webhook_endpoint.value.active_directory_app_id_or_uri
    }
  }

  dynamic "subject_filter" {
    for_each = each.value.subject_filter != null ? [each.value.subject_filter] : []
    content {
      subject_begins_with = subject_filter.value.subject_begins_with
      subject_ends_with   = subject_filter.value.subject_ends_with
      case_sensitive      = subject_filter.value.case_sensitive
    }
  }

  dynamic "dead_letter_identity" {
    for_each = each.value.dead_letter_identity != null ? [each.value.dead_letter_identity] : []
    content {
      type                   = dead_letter_identity.value.type
      user_assigned_identity = dead_letter_identity.value.user_assigned_identity
    }
  }

  // Handling the storage_blob_dead_letter_destination
  dynamic "storage_blob_dead_letter_destination" {
    for_each = each.value.storage_blob_dead_letter_destination != null ? [
      each.value.storage_blob_dead_letter_destination
    ] : []
    content {
      storage_account_id          = storage_blob_dead_letter_destination.value.storage_account_id
      storage_blob_container_name = storage_blob_dead_letter_destination.value.storage_blob_container_name
    }
  }

  // Handling the retry_policy
  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      max_delivery_attempts = retry_policy.value.max_delivery_attempts
      event_time_to_live    = retry_policy.value.event_time_to_live
    }
  }
  dynamic "advanced_filter" {
    for_each = [each.value.advanced_filters]
    content {

      dynamic "bool_equals" {
        for_each = advanced_filter.value.bool_equals != null ? advanced_filter.value.bool_equals : []
        content {
          key   = bool_equals.value.key
          value = bool_equals.value.value
        }
      }

      dynamic "number_greater_than" {
        for_each = advanced_filter.value.number_greater_than != null ? advanced_filter.value.number_greater_than : []
        content {
          key   = number_greater_than.value.key
          value = number_greater_than.value.value
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = advanced_filter.value.number_greater_than_or_equals != null ? advanced_filter.value.number_greater_than_or_equals : []
        content {
          key   = number_greater_than_or_equals.value.key
          value = number_greater_than_or_equals.value.value
        }
      }

      dynamic "number_less_than" {
        for_each = advanced_filter.value.number_less_than != null ? advanced_filter.value.number_less_than : []
        content {
          key   = number_less_than.value.key
          value = number_less_than.value.value
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = advanced_filter.value.number_less_than_or_equals != null ? advanced_filter.value.number_less_than_or_equals : []
        content {
          key   = number_less_than_or_equals.value.key
          value = number_less_than_or_equals.value.value
        }
      }

      dynamic "number_in" {
        for_each = advanced_filter.value.number_in != null ? advanced_filter.value.number_in : []
        content {
          key    = number_in.value.key
          values = number_in.value.values
        }
      }

      dynamic "number_not_in" {
        for_each = advanced_filter.value.number_not_in != null ? advanced_filter.value.number_not_in : []
        content {
          key    = number_not_in.value.key
          values = number_not_in.value.values
        }
      }

      dynamic "number_in_range" {
        for_each = advanced_filter.value.number_in_range != null ? advanced_filter.value.number_in_range : []
        content {
          key    = number_in_range.value.key
          values = number_in_range.value.values
        }
      }

      dynamic "number_not_in_range" {
        for_each = advanced_filter.value.number_not_in_range != null ? advanced_filter.value.number_not_in_range : []
        content {
          key    = number_not_in_range.value.key
          values = number_not_in_range.value.values
        }
      }

      dynamic "string_begins_with" {
        for_each = advanced_filter.value.string_begins_with != null ? advanced_filter.value.string_begins_with : []
        content {
          key    = string_begins_with.value.key
          values = string_begins_with.value.values
        }
      }

      dynamic "string_not_begins_with" {
        for_each = advanced_filter.value.string_not_begins_with != null ? advanced_filter.value.string_not_begins_with : []
        content {
          key    = string_not_begins_with.value.key
          values = string_not_begins_with.value.values
        }
      }

      dynamic "string_ends_with" {
        for_each = advanced_filter.value.string_ends_with != null ? advanced_filter.value.string_ends_with : []
        content {
          key    = string_ends_with.value.key
          values = string_ends_with.value.values
        }
      }

      dynamic "string_not_ends_with" {
        for_each = advanced_filter.value.string_not_ends_with != null ? advanced_filter.value.string_not_ends_with : []
        content {
          key    = string_not_ends_with.value.key
          values = string_not_ends_with.value.values
        }
      }

      dynamic "string_contains" {
        for_each = advanced_filter.value.string_contains != null ? advanced_filter.value.string_contains : []
        content {
          key    = string_contains.value.key
          values = string_contains.value.values
        }
      }

      dynamic "string_not_contains" {
        for_each = advanced_filter.value.string_not_contains != null ? advanced_filter.value.string_not_contains : []
        content {
          key    = string_not_contains.value.key
          values = string_not_contains.value.values
        }
      }

      dynamic "string_in" {
        for_each = advanced_filter.value.string_in != null ? advanced_filter.value.string_in : []
        content {
          key    = string_in.value.key
          values = string_in.value.values
        }
      }

      dynamic "string_not_in" {
        for_each = advanced_filter.value.string_not_in != null ? advanced_filter.value.string_not_in : []
        content {
          key    = string_not_in.value.key
          values = string_not_in.value.values
        }
      }

      dynamic "is_not_null" {
        for_each = advanced_filter.value.is_not_null != null ? advanced_filter.value.is_not_null : []
        content {
          key = is_not_null.value.key
        }
      }

      dynamic "is_null_or_undefined" {
        for_each = advanced_filter.value.is_null_or_undefined != null ? advanced_filter.value.is_null_or_undefined : []
        content {
          key = is_null_or_undefined.value.key
        }
      }
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
| <a name="input_eventgrid_system_event_subscriptions"></a> [eventgrid\_system\_event\_subscriptions](#input\_eventgrid\_system\_event\_subscriptions) | The eventgrid system event subscriptions block | <pre>list(object({<br>    name                                 = string<br>    system_topic_name                    = string<br>    rg_name                              = string<br>    expiration_time_utc                  = optional(string)<br>    event_delivery_schema                = optional(string)<br>    advanced_filtering_on_arrays_enabled = optional(bool)<br>    labels                               = optional(list(string))<br>    eventhub_endpoint_id                 = optional(string)<br>    hybrid_connection_endpoint_id        = optional(string)<br>    service_bus_queue_endpoint_id        = optional(string)<br>    service_bus_topic_endpoint_id        = optional(string)<br>    included_event_types                 = optional(list(string))<br><br>    storage_queue_endpoint = optional(object({<br>      storage_account_id                    = string<br>      queue_name                            = string<br>      queue_message_time_to_live_in_seconds = optional(string)<br>    }))<br><br>    azure_function_endpoint = optional(object({<br>      function_id                       = string<br>      max_events_per_batch              = optional(string)<br>      preferred_batch_size_in_kilobytes = optional(string)<br>    }))<br><br>    webhook_endpoint = optional(object({<br>      url                               = string<br>      base_url                          = optional(string)<br>      max_events_per_batch              = optional(string)<br>      preferred_batch_size_in_kilobytes = optional(string)<br>      active_directory_tenant_id        = optional(string)<br>      active_directory_app_id_or_uri    = optional(string)<br>    }))<br><br>    subject_filter = optional(object({<br>      subject_begins_with = optional(string)<br>      subject_ends_with   = optional(string)<br>      case_sensitive      = optional(bool)<br>    }))<br><br><br>    delivery_identity = optional(object({<br>      type                   = string<br>      user_assigned_identity = optional(string)<br>    }))<br><br>    delivery_property = optional(object({<br>      header_name  = string<br>      type         = string // "Static" or "Dynamic"<br>      value        = optional(string)<br>      source_field = optional(string)<br>      secret       = optional(bool)<br><br>    }))<br><br>    advanced_filters = optional(object({<br>      bool_equals = optional(list(object({<br>        key   = string<br>        value = bool<br>      })))<br>      number_greater_than = optional(list(object({<br>        key   = string<br>        value = string<br>      })))<br>      number_greater_than_or_equals = optional(list(object({<br>        key   = string<br>        value = string<br>      })))<br>      number_less_than = optional(list(object({<br>        key   = string<br>        value = string<br>      })))<br>      number_less_than_or_equals = optional(list(object({<br>        key   = string<br>        value = string<br>      })))<br>      number_in = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      number_not_in = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      number_in_range = optional(list(object({<br>        key = string<br>        values = list(object({<br>          min = string<br>          max = string<br>        }))<br>      })))<br>      number_not_in_range = optional(list(object({<br>        key = string<br>        values = list(object({<br>          min = string<br>          max = string<br>        }))<br>      })))<br>      string_begins_with = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_not_begins_with = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_ends_with = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_not_ends_with = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_contains = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_not_contains = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_in = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      string_not_in = optional(list(object({<br>        key    = string<br>        values = list(string)<br>      })))<br>      is_not_null = optional(list(object({<br>        key = string<br>      })))<br>      is_null_or_undefined = optional(list(object({<br>        key = string<br>      })))<br>    }))<br>    dead_letter_identity = optional(object({<br>      type                   = string<br>      user_assigned_identity = optional(string)<br>    }))<br><br>    storage_blob_dead_letter_destination = optional(object({<br>      storage_account_id          = string<br>      storage_blob_container_name = string<br>    }))<br><br>    retry_policy = optional(object({<br>      max_delivery_attempts = string<br>      event_time_to_live    = string<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_subscription_ids"></a> [event\_subscription\_ids](#output\_event\_subscription\_ids) | The IDs of the Event Grid System Topic Event Subscriptions. |
| <a name="output_event_subscription_names"></a> [event\_subscription\_names](#output\_event\_subscription\_names) | The names of the Event Grid System Topic Event Subscriptions. |
| <a name="output_event_subscription_rg_names"></a> [event\_subscription\_rg\_names](#output\_event\_subscription\_rg\_names) | The resource group names of the Event Grid System Topic Event Subscriptions. |
| <a name="output_event_subscription_topic_names"></a> [event\_subscription\_topic\_names](#output\_event\_subscription\_topic\_names) | The names of the System Topics associated with the Event Subscriptions. |
