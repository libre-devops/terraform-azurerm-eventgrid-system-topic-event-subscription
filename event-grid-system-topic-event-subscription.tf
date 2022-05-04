resource "azurerm_eventgrid_system_topic_event_subscription" "event_subscription" {
  name                = var.event_subscription_name
  system_topic        = var.system_topic_name
  resource_group_name = var.rg_name

  expiration_time_utc                  = var.expiration_time_utc
  event_delivery_schema                = var.event_delivery_schema
  advanced_filtering_on_arrays_enabled = var.advanced_filtering_on_arrays_enabled
  labels                               = var.labels
  eventhub_endpoint_id                 = try(var.eventhub_endpoint_id, null)
  hybrid_connection_endpoint_id        = try(var.hybrid_connection_endpoint_id, null)
  service_bus_queue_endpoint_id        = try(var.service_bus_queue_endpoint_id, null)
  service_bus_topic_endpoint_id        = try(var.service_bus_topic_endpoint_id, null)
  included_event_types                 = try(var.included_event_types, null)

  dynamic "azure_function_endpoint" {
    for_each = lookup(var.eventgrid_settings, "azure_function_endpoint", {}) != {} ? [1] : []
    content {
      function_id                       = lookup(var.eventgrid_settings.azure_private_endpoint, "function_id", null)
      max_events_per_batch              = lookup(var.eventgrid_settings.azure_private_endpoint, "max_events_per_batch", null)
      preferred_batch_size_in_kilobytes = lookup(var.eventgrid_settings.azure_private_endpoint, "preferred_batch_size_in_kilobytes", null)
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = lookup(var.eventgrid_settings, "storage_queue_endpoint", {}) != {} ? [1] : []
    content {
      storage_account_id                    = lookup(var.eventgrid_settings.storage_queue_endpoint, "storage_account_id", null)
      queue_name                            = lookup(var.eventgrid_settings.storage_queue_endpoint, "queue_name", null)
      queue_message_time_to_live_in_seconds = lookup(var.eventgrid_settings.storage_queue_endpoint, "queue_message_time_to_live_in_seconds", null)
    }
  }

  dynamic "storage_blob_dead_letter_destination" {
    for_each = lookup(var.eventgrid_settings, "storage_blob_dead_letter_destination", {}) != {} ? [1] : []
    content {
      storage_account_id          = lookup(var.eventgrid_settings.storage_blob_dead_letter_destination, "storage_account_id", null)
      storage_blob_container_name = lookup(var.eventgrid_settings.storage_blob_dead_letter_destination, "storage_blob_container_name", null)
    }
  }

  dynamic "dead_letter_identity" {
    for_each = lookup(var.eventgrid_settings, "dead_letter_identity", {}) != {} ? [1] : []
    content {
      type                 = lookup(var.eventgrid_settings.dead_letter_identity, "type", null)
      userAssignedIdentity = lookup(var.eventgrid_settings.dead_letter_identity, "userAssignedIdentity", null)
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(var.eventgrid_settings, "retry_policy", {}) != {} ? [1] : []
    content {
      max_delivery_attempts = lookup(var.eventgrid_settings.retry_policy, "max_delivery_attempts", null)
      event_time_to_live    = lookup(var.eventgrid_settings.retry_policy, "event_time_to_live", null)
    }
  }

  dynamic "webhook_endpoint" {
    for_each = lookup(var.eventgrid_settings, "webhook_endpoint", {}) != {} ? [1] : []
    content {
      url                               = lookup(var.eventgrid_settings.webhook_endpoint, "url", null)
      base_url                          = lookup(var.eventgrid_settings.webhook_endpoint, "base_url", null)
      max_events_per_batch              = lookup(var.eventgrid_settings.webhook_endpoint, "max_events_per_batch", null)
      preferred_batch_size_in_kilobytes = lookup(var.eventgrid_settings.webhook_endpoint, "preferred_batch_size_in_kilobytes", null)
      active_directory_tenant_id        = lookup(var.eventgrid_settings.webhook_endpoint, "active_directory_tenant_id", null)
      active_directory_app_id_or_uri    = lookup(var.eventgrid_settings.webhook_endpoint, "active_directory_app_id_or_uri", null)
    }
  }

  dynamic "subject_filter" {
    for_each = lookup(var.eventgrid_settings, "subject_filter", {}) != {} ? [1] : []
    content {
      subject_begins_with = lookup(var.eventgrid_settings.subject_filter, "subject_begins_with", null)
      subject_ends_with   = lookup(var.eventgrid_settings.subject_filter, "subject_ends_with", null)
      case_sensitive      = lookup(var.eventgrid_settings.subject_filter, "case_sensitive", null)
    }
  }

  dynamic "delivery_identity" {
    for_each = lookup(var.eventgrid_settings, "delivery_identity", {}) != {} ? [1] : []
    content {
      type                 = lookup(var.eventgrid_settings.delivery_identity, "type", null)
      userAssignedIdentity = lookup(var.eventgrid_settings.delivery_identity, "userAssignedIdentity", null)
    }
  }

  dynamic "delivery_property" {
    for_each = lookup(var.eventgrid_settings, "delivery_property", {}) != {} ? [1] : []
    content {
      header_name  = lookup(var.eventgrid_settings.delivery_property, "header_name", null)
      type         = lookup(var.eventgrid_settings.delivery_property, "type", null)
      value        = lookup(var.eventgrid_settings.delivery_property, "value", null)
      source_field = lookup(var.eventgrid_settings.delivery_property, "source_field", null)
      secret       = lookup(var.eventgrid_settings.delivery_property, "secret", null)
    }
  }

  dynamic "advanced_filter" {
    for_each = lookup(var.eventgrid_settings, "advanced_filter", {}) != {} ? [1] : []
    content {

      dynamic "bool_equals" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "bool_equals", {}) != {} ? [1] : []
        content {
          key   = lookup(var.eventgrid_settings.advanced_filter.bool_equals, "key", null)
          value = lookup(var.eventgrid_settings.advanced_filter.bool_equals, "value", null)
        }
      }

      dynamic "number_greater_than" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "number_greater_than", {}) != {} ? [1] : []
        content {
          key   = lookup(var.eventgrid_settings.advanced_filter.number_greater_than, "key", null)
          value = lookup(var.eventgrid_settings.advanced_filter.number_greater_than, "value", null)
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "number_greater_than_or_equals", {}) != {} ? [1] : []
        content {
          key   = lookup(var.eventgrid_settings.advanced_filter.number_greater_than_or_equals, "key", null)
          value = lookup(var.eventgrid_settings.advanced_filter.number_greater_than_or_equals, "value", null)
        }
      }

      dynamic "number_less_than" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "number_less_than", {}) != {} ? [1] : []
        content {
          key   = lookup(var.eventgrid_settings.advanced_filter.number_less_than, "key", null)
          value = lookup(var.eventgrid_settings.advanced_filter.number_less_than, "value", null)
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "number_less_than_or_equals", {}) != {} ? [1] : []
        content {
          key   = lookup(var.eventgrid_settings.advanced_filter.number_less_than_or_equals, "key", null)
          value = lookup(var.eventgrid_settings.advanced_filter.number_less_than_or_equals, "value", null)
        }
      }

      dynamic "number_in" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "number_in", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.number_in, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.number_in, "values", null)
        }
      }
      dynamic "number_not_in" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "number_not_in", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.number_not_in, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.number_not_in, "values", null)
        }
      }

      dynamic "string_begins_with" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_begins_with", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_begins_with, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_begins_with, "values", null)
        }
      }

      dynamic "string_not_begins_with" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_not_begins_with", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_not_begins_with, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filterstring_not_begins_with, "values", null)
        }
      }

      dynamic "string_ends_with" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_ends_with", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_ends_with, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_ends_with, "values", null)
        }
      }

      dynamic "string_not_ends_with" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_not_ends_with", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_not_ends_with, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_not_ends_with, "values", null)
        }
      }

      dynamic "string_contains" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_contains", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_contains, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_contains, "values", null)
        }
      }

      dynamic "string_not_contains" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_not_contains", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_not_contains, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_not_contains, "values", null)
        }
      }

      dynamic "string_in" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_in", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_in, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_in, "values", null)
        }
      }

      dynamic "string_not_in" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "string_not_in", {}) != {} ? [1] : []
        content {
          key    = lookup(var.eventgrid_settings.advanced_filter.string_not_in, "key", null)
          values = lookup(var.eventgrid_settings.advanced_filter.string_not_in, "values", null)
        }
      }

      dynamic "is_not_null" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "is_not_null", {}) != {} ? [1] : []
        content {
          key = lookup(var.eventgrid_settings.advanced_filter.is_not_null, "key", null)
        }
      }

      dynamic "is_null_or_undefined" {
        for_each = lookup(var.eventgrid_settings.advanced_filter, "is_null_or_undefined", {}) != {} ? [1] : []
        content {
          key = lookup(var.eventgrid_settings.advanced_filter.is_null_or_undefined, "key", null)
        }
      }
    }
  }
}

