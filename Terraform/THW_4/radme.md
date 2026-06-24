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
Создал изолированную директорию `vpc` внутри папки `vms` со следующей структурой конфигурационных файлов.

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
Полностью удалил старые глобальные ресурсы сетей. Вместо них объявил два вызова нового модуля `vpc` для проектов `marketing` и `analytics`. 

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
>   ![Terraform Console VPC](https://github.com/user-attachments/assets/162e095c-365b-411f-8deb-02befbf3faee)


3. **Сгенерировал автоматическую документацию к модулю vpc с помощью terraform-docs:**
   Установил утилиту через snap-пакет и выполнил экспорт структуры таблиц в markdown:
   ```bash
   sudo snap install terraform-docs
   cd vpc
   terraform-docs markdown table . > README.md
   ```
>  ![1](https://github.com/user-attachments/assets/3436c19e-c6e3-4a96-8d49-c4d4c77aa040)


### С какими проблемами столкнулся и как их решил:

1. **Ошибка с провайдером HashiCorp:**
   Сначала `terraform init` намертво зависал и выдавал ошибку, пытаясь скачать плагин Яндекса с официального заблокированного сайта HashiCorp. Пока пытался разобраться, подумал что проблема в кэше и удалил `.terraform` и файлы состояния `terraform.tfstate`, забыв перед этим сделать очистку через `terraform destroy`. Из-за этого Terraform «забыл» про уже созданные в облаке серверы, и они остались там висеть «сиротами».
   
   *Как решил:* Разобрался, что внутри созданного локального модуля `vpc` не был явно указан источник провайдера. Добавил блок `required_providers` со ссылкой на зеркало `yandex-cloud/yandex` прямо в файлы модуля. После этого ошибка с HashiCorp ушла навсегда.

2. **Превышение лимитов на сети (Квоты Яндекса):**
   Когда запустил сборку, Яндекс выдал ошибку `Quota limit vpc.networks.count exceeded`. Модуль пытался создать две новые сети, но на бесплатном аккаунте разрешено иметь всего 2 сети одновременно. Лимит забился, так как в облаке всё ещё висели старые сервера от первого задания, о которых Terraform забыл на прошлом шаге.
   
   *Как решил:* Зашёл вручную в личный кабинет Yandex Cloud через браузер. Последовательно удалил руками старые виртуалки, их подсети и старую сеть `develop`. Как только место освободилось, заново запустил `terraform apply`, и все 6 новых ресурсов создались без единой ошибки.

## Задание 3

### Шаг 1: Вывел текущий список ресурсов из стейта

```bash
terraform state list
```
  
> ![terraform state list](https://github.com/user-attachments/assets/85b9c14c-7987-4106-8906-4f3753725b90)  

### Шаг 2: Полностью удалил модули vpc и виртуальные машины из стейта

```bash
terraform state rm module.vpc_marketing
terraform state rm module.vpc_analytics
terraform state rm yandex_compute_instance.marketing_server
terraform state rm yandex_compute_instance.analytics_server
```

> ![terraform state rm](https://github.com/user-attachments/assets/5385ca4c-f887-4814-b30d-195c92ae1f7e)


### Шаг 3: Импортировал все ресурсы обратно в состояние Terraform

```bash
# Восстановление сетевой структуры локальных модулей (Сети и Подсети)
terraform import module.vpc_marketing.yandex_vpc_network.network <ID_СЕТИ_MARKETING>
terraform import module.vpc_marketing.yandex_vpc_subnet.subnet <ID_ПОДСЕТИ_MARKETING>
terraform import module.vpc_analytics.yandex_vpc_network.network <ID_СЕТИ_ANALYTICS>
terraform import module.vpc_analytics.yandex_vpc_subnet.subnet <ID_ПОДСЕТИ_ANALYTICS>

# Восстановление виртуальных машин
terraform import yandex_compute_instance.marketing_server <ID_ВМ_MARKETING>
terraform import yandex_compute_instance.analytics_server <ID_ВМ_ANALYTICS>
```

### Шаг 4: Проверка конфигурации с помощью terraform plan
Запустил финальную сверку кода с восстановленным стейтом:
```bash
terraform plan
```
  
> ![terraform plan](https://github.com/user-attachments/assets/9dc9bb1d-19e9-4598-8a4f-d84a1e8b97a4)

## Задание 4*

### Шаг 1: Модернизировал локальный модуль vpc под работу с циклами

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
  description = "Название окружения для префикса имени сети"
}

variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "Список подсетей со своими зонами и CIDR блоками"
}
```

> **vpc/main.tf**
```hcl
resource "yandex_vpc_network" "network" {
  name = "\${var.env_name}-network"
}

resource "yandex_vpc_subnet" "subnet" {

  for_each       = { for subnet in var.subnets : subnet.zone => subnet }
  
  name           = "\${var.env_name}-\${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [each.value.cidr]
}
```

> **vpc/outputs.tf**
```hcl
output "subnets" {
  value       = yandex_vpc_subnet.subnet
  description = "Карта всех созданных подсетей в модуле"
}
```

### Шаг 2: Реализовал мульти-вызов модуля в корневом файле main.tf

> **main.tf**
```hcl
module "vpc_prod" {
  source   = "./vpc"
  env_name = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-d", cidr = "10.0.3.0/24" }
  ]
}

module "vpc_dev" {
  source   = "./vpc"
  env_name = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.10.1.0/24" }
  ]
}
```

### Шаг 3: Проверка конфигурации и результаты деплоя

1. **План выполнения конфигурации:**
   ```bash
   terraform plan
   ```
   > ![terraform plan](https://github.com/user-attachments/assets/fec1c7e4-83c5-4976-80d5-73213705ea66)


2. **Применение конфигурации и проверка в консоли YC:**
 
   ```bash
   terraform apply -auto-approve
   ```
   > ![terraform apply](https://github.com/user-attachments/assets/3a37cd21-5fa6-4533-bf14-5f92c6de2123)

3. **Инспекция выходной структуры данных:**

   ```bash
   terraform console
   > module.vpc_prod.subnets
   ```
      
   > ![terraform console](https://github.com/user-attachments/assets/e9a331e5-28f9-4136-9e93-c6941e86edb6)


