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
