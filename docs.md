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
