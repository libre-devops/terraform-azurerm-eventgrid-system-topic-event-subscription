output "eventgrid_system_topic_event_subscription_id" {
  description = "The id of the custom subscription"
  value       = azurerm_eventgrid_system_topic_event_subscription.event_subscription.id
}

output "eventgrid_system_topic_event_subscription_labels" {
  description = "The labels of the custom subscription"
  value       = azurerm_eventgrid_system_topic_event_subscription.event_subscription.labels
}

output "eventgrid_system_topic_event_subscription_name" {
  description = "The name of the custom subscription"
  value       = azurerm_eventgrid_system_topic_event_subscription.event_subscription.id
}
