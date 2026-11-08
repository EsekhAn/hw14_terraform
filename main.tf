terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone      = var.zone
  folder_id = "b1gblakel3omsk92oj0q"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# ---------- СБОРОЧНЫЙ ИНСТАНС ----------
resource "yandex_compute_instance" "build" {
  name               = "${var.vm_name}-build"
  platform_id        = "standard-v3"
  service_account_id = var.service_account_id

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_key_path))}"
    user-data = templatefile("${path.module}/build.cloud-init.yaml", {
      bucket = var.bucket_name
    })
  }
}

# ---------- ПРОДОВЫЙ ИНСТАНС ----------
resource "yandex_compute_instance" "prod" {
  name               = "${var.vm_name}-prod"
  platform_id        = "standard-v3"
  service_account_id = var.service_account_id

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_key_path))}"
    user-data = templatefile("${path.module}/prod.cloud-init.yaml", {
      bucket = var.bucket_name
    })
  }

  depends_on = [yandex_compute_instance.build]
}