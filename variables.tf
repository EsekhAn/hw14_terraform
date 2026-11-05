variable "zone" {
  description = "Зона доступности"
  default     = "ru-central1-d"
}

variable "folder_id" {
  description = "ID каталога Yandex Cloud"
  default     = "b1gblakel3omsk92oj0q"
}

variable "vm_cores" {
  description = "Количество ядер CPU"
  default     = 2
}

variable "vm_memory" {
  description = "Объём оперативной памяти (ГБ)"
  default     = 4
}

variable "disk_size" {
  description = "Размер загрузочного диска (ГБ)"
  default     = 15
}

variable "subnet_id" {
  description = "Подсеть ru-central1-d"
  type        = string
  default     = "fl8tj1vcc0r960mgdmnk"
}

variable "ssh_key_path" {
  description = "Путь к локальному публичному SSH-ключу"
  default     = "~/.ssh/id_rsa.pub"
}

variable "registry_name" {
  description = "Имя Container Registry"
  default     = "java-app-registry"
}