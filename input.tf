variable "event_delivery_schema" {
  description = "The scheme for the event delivery service"
  type        = string
}

variable "event_subscription_name" {
  description = "The name of the event subscription"
  type        = string
}

variable "eventgrid_settings" {
  description = "The map block which contains nested settings"
  type        = any
}

variable "eventgrid_system_topic_id" {
  description = "The ID of the system topic the subscription is to join"
  type        = string
}

variable "eventhub_endpoint_id" {
  description = "The ID of an eventhub endpoint if used"
  type        = string
  default     = ""
}

variable "expiration_time_utc" {
  description = "The expiration time in RFC 3339 format"
  type        = string
  default     = ""
}

variable "hybrid_connection_endpoint_id" {
  description = "The ID of an hybrid_connection endpoint if used"
  type        = string
  default     = ""
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "included_event_types" {
  description = "A list of event types that the event grid is searching for"
  type        = list(any)
  default     = []
}

variable "labels" {
  type        = list(any)
  description = "The Labels of the event grid"
  default     = []
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "service_bus_queue_endpoint_id" {
  description = "The ID of an service bus queue endpoint if used"
  type        = string
  default     = ""
}

variable "service_bus_topic_endpoint_id" {
  description = "The ID of an service bus topic endpoint if used"
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}
