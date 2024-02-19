output "event_subscription_ids" {
  description = "The IDs of the Event Grid System Topic Event Subscriptions."
  value       = { for sub in azurerm_eventgrid_system_topic_event_subscription.event_subscription : sub.name => sub.id }
}

output "event_subscription_names" {
  description = "The names of the Event Grid System Topic Event Subscriptions."
  value       = [for sub in azurerm_eventgrid_system_topic_event_subscription.event_subscription : sub.name]
}

output "event_subscription_topic_names" {
  description = "The names of the System Topics associated with the Event Subscriptions."
  value       = [for sub in azurerm_eventgrid_system_topic_event_subscription.event_subscription : sub.system_topic]
}

output "event_subscription_rg_names" {
  description = "The resource group names of the Event Grid System Topic Event Subscriptions."
  value       = [for sub in azurerm_eventgrid_system_topic_event_subscription.event_subscription : sub.resource_group_name}
