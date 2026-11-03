# Домашнее задание к занятию «Вычислительные мощности. Балансировщики нагрузки»

## Задание 1. Object Storage, Instance Group (LAMP) и сетевой балансировщик

### 1. Создание бакета и загрузка картинки
Создан публичный бакет в Object Storage и загружен файл `dog.jpg`. Файл доступен по прямой ссылке:
`https://storage.yandexcloud.net/o-komel-hw-2026/dog.jpg`

### 2. Terraform-конфигурация

**main.tf**
```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = ".key.json"
  zone = "ru-central1-a"
}

variable "folder_id" {}
variable "ssh_key_path" {}

resource "yandex_vpc_network" "net" {
  name = "lamp-net"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_iam_service_account" "sa" {
  name = "lamp-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_compute_instance_group" "lamp" {
  name               = "lamp-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.sa.id

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit" 
      }
    }

    network_interface {
      network_id = yandex_vpc_network.net.id
      subnet_ids = [yandex_vpc_subnet.public.id]
    }

    metadata = {
      ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
      user-data = <<EOF
#cloud-config
write_files:
  - path: /var/www/html/index.html
    content: |
      <html><body><h1>LAMP is working</h1>
      <img src="https://storage.yandexcloud.net/o-komel-hw-2026/dog.jpg" style="max-width: 500px;">
      </body></html>
EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  health_check {
    interval = 30
    timeout  = 10
    tcp_options {
      port = 80
    }
  }

  load_balancer {
    target_group_name = "lamp-tg"
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "lamp-nlb"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp.load_balancer[0].target_group_id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }
}
```

### 3. Демонстрация работы
После применения конфигурации балансировщик получил публичный IP `51.250.74.227`. 

![demo1](https://github.com/user-attachments/assets/b1758c19-25b9-43a5-ae3e-5c5c06b86212)

При обращении по этому IP открывается веб-страница с картинкой из бакета:

![demo2](https://github.com/user-attachments/assets/ea2babba-afff-4cfa-9214-275fa2a4234f)

