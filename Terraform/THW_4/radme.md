# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

## Задание 1

### Шаг 1: Разработал динамический шаблон конфигурации cloud-init.yml
Заменил хардкод SSH-ключей на переменную `${ssh_key}`. Добавил автоматическое обновление репозиториев и установку пакетов `vim` и `nginx`.

> **cloud-init.yml**
```yaml
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - \${ssh_key}

package_update: true
package_upgrade: false

packages:
  - vim
  - nginx
```

### Шаг 2: Настроил вызовы remote-модулей в файле main.tf

> **main.tf**
```hcl
# 1. Модуль для проекта Marketing
module "marketing_vm" {
  source         = "git::https://github.com"
  env_name       = "develop" 
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [yandex_vpc_subnet.develop_a.id]
  instance_name  = "marketing-server"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = { 
    project = "marketing"
  }

  metadata = {
    serial-port-enable = 1
    user-data          = templatefile("\${path.module}/cloud-init.yml", {
      ssh_key = file("/home/o_komel/ssh-key-1778067207541")
    })
  }
}

# 2. Модуль для проекта Analytics
module "analytics_vm" {
  source         = "git::https://github.com"
  env_name       = "develop" 
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-b"]
  subnet_ids     = [yandex_vpc_subnet.develop_b.id]
  instance_name  = "analytics-server"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = { 
    project = "analytics"
  }

  metadata = {
    serial-port-enable = 1
    user-data          = templatefile("\${path.module}/cloud-init.yml", {
      ssh_key = file("/home/o_komel/ssh-key-1778067207541")
    })
  }
}
```

### Шаг 3: Добавил объявление переменной в variables.tf
Объявил переменную `default_zone`, используемую в файле `providers.tf`.

> **variables.tf**
```hcl
variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Дефолтная зона доступности для ресурсов Yandex Cloud"
}
```

### Шаг 4: Развернул инфраструктуру и проверил результаты
Авторизация в облаке выполнена через переменную окружения `YC_FOLDER_ID`. Инфраструктура успешно создана: `Apply complete! Resources: 5 added, 0 changed, 0 destroyed.`

> 1. **Скриншот консоли Yandex Cloud с метками виртуальных машин:**
>   
> ![Yandex Cloud Labels](https://github.com/user-attachments/assets/33e90df3-d081-4d47-92cc-0a34ec20acde)

> 2. **Скриншот подключения по SSH и вывода команды sudo nginx -t:**
>   
> ![Nginx Test](https://github.com/user-attachments/assets/f2477f85-58fe-446e-994b-9a08235dd4d4)

> 3. **Скриншот содержимого модуля из terraform console:**
>
> ![Terraform Console Module](https://github.com/user-attachments/assets/aaf106ea-a613-4852-a174-5cceb47307ec)

## Задание 2

### Шаг 1: Разработал локальный модуль vpc
Создал изолированную директорию `vpc` внутри папки `vms` со следующей структурой конфигурационных файлов. Объявил обязательные входные переменные без дефолтных значений и настроил явную привязку к зеркалу Яндекса для исключения неявных конфликтов провайдеров.

> **vpc/variables.tf**
```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "env_name" {
  type        = string
  description = "Название окружения (используется как префикс для имени сети)"
}

variable "zone" {
  type        = string
  description = "Зона доступности для создаваемой подсети"
}

variable "cidr" {
  type        = string
  description = "CIDR блок для адресации подсети"
}
```

> **vpc/main.tf**
```hcl
resource "yandex_vpc_network" "network" {
  name = "\${var.env_name}-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "\${var.env_name}-\${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [var.cidr]
}
```

> **vpc/outputs.tf**
```hcl
output "subnet" {
  value       = yandex_vpc_subnet.subnet
  description = "Полный объект созданной подсети со всеми атрибутами"
}
```

### Шаг 2: Интегрировал локальный модуль в корневой main.tf и переписал ресурсы ВМ
Полностью удалил старые глобальные ресурсы сетей. Вместо них объявил два вызова нового модуля `vpc` для проектов `marketing` и `analytics`. Параметры ID сетей, подсетей и зон динамически передаются из выходов дочернего модуля во входные параметры стандартных ресурсов виртуальных машин.

> **main.tf**
```hcl
module "vpc_marketing" {
  source   = "./vpc"
  env_name = "marketing"
  zone     = "ru-central1-a"
  cidr     = "10.0.1.0/24"
}

module "vpc_analytics" {
  source   = "./vpc"
  env_name = "analytics"
  zone     = "ru-central1-b"
  cidr     = "10.0.2.0/24"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "marketing_server" {
  name        = "marketing-server"
  platform_id = "standard-v1"
  zone        = module.vpc_marketing.subnet.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = module.vpc_marketing.subnet.id
    nat       = true
  }

  labels = { project = "marketing" }

  metadata = {
    serial-port-enable = 1
    user-data          = templatefile("\${path.module}/cloud-init.yml", {
      ssh_key = file("/home/o_komel/ssh-key-1778067207541")
    })
  }
}

resource "yandex_compute_instance" "analytics_server" {
  name        = "analytics-server"
  platform_id = "standard-v1"
  zone        = module.vpc_analytics.subnet.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = module.vpc_analytics.subnet.id
    nat       = true
  }

  labels = { project = "analytics" }

  metadata = {
    serial-port-enable = 1
    user-data          = templatefile("\${path.module}/cloud-init.yml", {
      ssh_key = file("/home/o_komel/ssh-key-1778067207541")
    })
  }
}
```

### Шаг 3: Проверка результатов и генерация документации
1. Очистил устаревший кэш плагинов, успешно инициализировал и развернул чистую конфигурацию (всего добавлено 6 ресурсов):
   ```bash
   rm -rf .terraform .terraform.lock.hcl
   terraform init
   terraform apply -auto-approve
   ```
2. **Скриншот информации из terraform console о созданном модуле:**
   ![Terraform Console VPC](https://ваш-путь-к-скриншоту-vpc.png)

3. **Сгенерировал автоматическую документацию к модулю vpc с помощью terraform-docs:**
   Установил утилиту через snap-пакет и выполнил экспорт структуры таблиц в markdown:
   ```bash
   sudo snap install terraform-docs
   cd vpc
   terraform-docs markdown table . > README.md
   ```
   *(Вставьте ваш текущий скриншот с выводом cat README.md)*
