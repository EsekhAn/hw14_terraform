terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone      = var.zone
  folder_id = var.folder_id
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_container_registry" "app" {
  name      = var.registry_name
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "builder_sa" {
  name      = "builder-sa"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "prod_sa" {
  name      = "prod-sa"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "builder_push" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.builder_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "builder_pull" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.builder_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "prod_pull" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.prod_sa.id}"
}

resource "yandex_compute_instance" "builder" {
  name        = "builder-vm"
  platform_id = "standard-v3"

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
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io
        - git
        - maven
      runcmd:
        - systemctl enable --now docker
        - usermod -aG docker ubuntu
    EOF
  }

  service_account_id = yandex_iam_service_account.builder_sa.id
}

resource "yandex_compute_instance" "prod" {
  name        = "prod-vm"
  platform_id = "standard-v3"

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
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - docker.io
      runcmd:
        - systemctl enable --now docker
        - usermod -aG docker ubuntu
    EOF
  }

  service_account_id = yandex_iam_service_account.prod_sa.id
}