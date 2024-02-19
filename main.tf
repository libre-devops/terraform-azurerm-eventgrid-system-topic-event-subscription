variable "eventgrid_system_event_subscriptions" {
  description = "The eventgrid system event subscriptions block"
  type = list(object({
    name                                 = string
    system_topic_name                    = string
    rg_name                              = string
    expiration_time_utc                  = optional(number)
    event_delivery_schema                = optional(string)
    advanced_filtering_on_arrays_enabled = optional(bool)
    labels                               = optional(list(string))
    eventhub_endpoint_id                 = optional(string)
    hybrid_connection_endpoint_id        = optional(string)
    service_bus_queue_endpoint_id        = optional(string)
    service_bus_topic_endpoint_id        = optional(string)
    included_event_types                 = optional(list(string))

    storage_queue_endpoint = optional(object({
      storage_account_id                    = string
      queue_name                            = string
      queue_message_time_to_live_in_seconds = optional(number)
    }))

    azure_function_endpoint = optional(object({
      function_id                       = string
      max_events_per_batch              = optional(number)
      preferred_batch_size_in_kilobytes = optional(number)
    }))

    webhook_endpoint = optional(object({
      url                               = string
      base_url                          = optional(string)
      max_events_per_batch              = optional(number)
      preferred_batch_size_in_kilobytes = optional(number)
      active_directory_tenant_id        = optional(string)
      active_directory_app_id_or_uri    = optional(string)
    }))

    subject_filter = optional(object({
      subject_begins_with = optional(string)
      subject_ends_with   = optional(string)
      case_sensitive      = optional(bool)
    }))


    delivery_identity = optional(object({
      type                   = string
      user_assigned_identity = optional(string)
    }))

    delivery_property = optional(object({
      header_name  = string
      type         = string // "Static" or "Dynamic"
      value        = optional(string)
      source_field = optional(string)
      secret       = optional(bool)

    }))

    advanced_filters = optional(object({
      bool_equals = optional(list(object({
        key   = string
        value = bool
      })))
      number_greater_than = optional(list(object({
        key   = string
        value = number
      })))
      number_greater_than_or_equals = optional(list(object({
        key   = string
        value = number
      })))
      number_less_than = optional(list(object({
        key   = string
        value = number
      })))
      number_less_than_or_equals = optional(list(object({
        key   = string
        value = number
      })))
      number_in = optional(list(object({
        key    = string
        values = list(number)
      })))
      number_not_in = optional(list(object({
        key    = string
        values = list(number)
      })))
      number_in_range = optional(list(object({
        key = string
        values = list(object({
          min = number
          max = number
        }))
      })))
      number_not_in_range = optional(list(object({
        key = string
        values = list(object({
          min = number
          max = number
        }))
      })))
      string_begins_with = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_not_begins_with = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_ends_with = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_not_ends_with = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_contains = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_not_contains = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_in = optional(list(object({
        key    = string
        values = list(string)
      })))
      string_not_in = optional(list(object({
        key    = string
        values = list(string)
      })))
      is_not_null = optional(list(object({
        key = string
      })))
      is_null_or_undefined = optional(list(object({
        key = string
      })))
    }))
    dead_letter_identity = optional(object({
      type                   = string
      user_assigned_identity = optional(string)
    }))

    storage_blob_dead_letter_destination = optional(object({
      storage_account_id          = string
      storage_blob_container_name = string
    }))

    retry_policy = optional(object({
      max_delivery_attempts = number
      event_time_to_live    = number
    }))
  }))
}

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
