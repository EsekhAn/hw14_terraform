output "registry_id" {
  description = "ID Container Registry"
  value       = yandex_container_registry.app.id
}

output "registry_url" {
  description = "Адрес реестра для тегов Docker"
  value       = "cr.yandex/${yandex_container_registry.app.id}"
}

output "builder_ip" {
  description = "Внешний IP сборочной машины"
  value       = yandex_compute_instance.builder.network_interface.0.nat_ip_address
}

output "prod_ip" {
  description = "Внешний IP производственной машины"
  value       = yandex_compute_instance.prod.network_interface.0.nat_ip_address
}