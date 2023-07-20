output "clb_instance_id" {
  value       = tencentcloud_clb_instance.clb_internal.id
  description = "clb instance Id"
}

output "clb_listener_id" {
  value       = tencentcloud_clb_listener.clb_listener.listener_id
  description = "clb listener Id"
}