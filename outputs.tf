output "build_ip" {
  description = "Внешний IP сборочного инстанса"
  value       = yandex_compute_instance.build.network_interface[0].nat_ip_address
}

output "prod_ip" {
  description = "Внешний IP продового инстанса"
  value       = yandex_compute_instance.prod.network_interface[0].nat_ip_address
}

output "prod_url" {
  description = "URL приложения на продовом инстансе"
  value       = "http://${yandex_compute_instance.prod.network_interface[0].nat_ip_address}:8080/hello/"
}