# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

## Задание 1

### Шаг 1: Изучил проект. Проверил какие в файле variables.tf объявлены переменные для Yandex provider.

### Шаг 2: Вручную на ресурсе console.yandex.cloud создал сервисную учетную запись. Командой yc iam key create создал ключ, внес имя ключа в .gitignore.

```bash
yc iam key create --service-account-name <NAME-SERV-ACC> --output .key.json
```

### Шаг 3: Сгенерировал ssh-ключ командой ssh-keygen. 

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```
> **Вывод:**
> ```text
> Generating public/private ed25519 key pair.
>Your identification has been saved in /home/o_komel/.ssh/id_ed25519
>Your public key has been saved in /home/o_komel/.ssh/id_ed25519.pub
>The key fingerprint is:
> ....
> ```

### Создал файл terraform.tfvars, добавил в него переменную vms_ssh_public_root_key, внес файл terraform.tfvars в .gitignore.

```bash
nano terraform.tfvars
```

> **terraform.tfvars**
> ```text
> vms_ssh_public_root_key = "<.....>"
> ```

### Шаг 4: Инициализация проекта.

При инициализации terraform init программа постоянно запрашивала ввод ИД облако и ИД папки, первое что начал менять это убрал данные запросы:  

> **variables.tf**
> ```text
> #variable "cloud_id" {
> #  type        = string
> #  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
> #}
>
> #variable "folder_id" {
> #  type        = string
> #  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
> #}
> ```

Я закомментировал переменные cloud_id и folder_id в коде, чтобы Terraform не запрашивал их ввод вручную. Благодаря интеграции с Yandex Cloud CLI, провайдер автоматически подтягивает ID облака и каталога из текущего активного профиля yc (настроенного ранее через yc init), а аутентификация при этом безопасно проходит через файл .key.json.

Провожу вторую инициализация terraform init, вижу что теперь terraform анонсит мои переменные cloud_id и folder_id в консоль. Для того чтобы terraform скрыл мои переменные, редактирую файл providers.tf:

> **providers.tf**
> ```text
>  cloud_id                 = sensitive("")
>  folder_id                = sensitive("")
> ```

После использования функции sensitive() переменные пропали из вывода консоли. Команды terraform init и terraform validate выполнились успешно.
Команда terraform apply выдала ошибку с ссылкой на 15 строку файла main.tf. Изучив файл нашёл 4 ошибки:

> **Ошибки :**  
> platform_id = "standart-v4" -> заменил на platform_id = "standard-v4"
>  
> cores         = 1           -> создавая виртуалки на веб ресурсе не замечал возможности выбрать одно ядро, поменял на cores         = 2
> 
> core_fraction = 5           -> создавая виртуалки на веб ресурсе не замечал возможности выбрать 5% гарантированной процессорной мощности, поменял на core_fraction = 20
> 
> ssh-keys           = "ubuntu:${var.vms_ssh_root_key}" -> из шага 3 следует что имя переменной vms_ssh_public_root_key, заменил на ssh-keys           = "ubuntu:${var.vms_ssh_public_root_key}"

Вторая и третья попытка ввести команду terraform apply также приводили к ошибкам:

> **Ошибки :**  
> В файле variables.tf была объявлена переменная с старым названием vms_ssh_root_key, заменил на vms_ssh_public_root_key
> 
> Terraform не поддерживает платформу standard-v4 в моей зоне, заменил на standard-v3

С четвертого раза команда terraform apply выолнилась успешно:

> **Вывод :**  
> ``` text
> yandex_compute_instance.platform: Creating...
> yandex_compute_instance.platform: Still creating... [00m10s elapsed]
> yandex_compute_instance.platform: Still creating... [00m20s elapsed]
> yandex_compute_instance.platform: Still creating... [00m30s elapsed]
> yandex_compute_instance.platform: Still creating... [00m40s elapsed]
> yandex_compute_instance.platform: Creation complete after 43s [id=fhmkr5ntl55rc24j7vco]
>
> Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
> ```

### Шаг 5: Подключение к ВМ по ssh и выполнение команды curl ifconfig.me

Добавил ключ в ssh агент:

```bash
eval $(ssh-agent) && ssh-add ~/.ssh/id_ed25519
```

Командой yc compute instance list посмотрел внешний IP адрес ВМ:

```Text
+----------------------+-------------------------------+---------------+---------+--------------+-------------+
|          ID          |             NAME              |    ZONE ID    | STATUS  | EXTERNAL IP  | INTERNAL IP |
+----------------------+-------------------------------+---------------+---------+--------------+-------------+
| fhmkr5ntl55rc24j7vco | netology-develop-platform-web | ru-central1-a | RUNNING | 93.77.183.35 | 10.0.1.32   |
+----------------------+-------------------------------+---------------+---------+--------------+-------------+
```

Подключился к ВМ по ssh, выполнил команду curl ifconfig.me:

```text
93.77.183.35
```

### Шаг 6: 

> **preemptible = true**
> 
> Этот параметр указывает облаку, что вы создаете «прерывистую» виртуальную машину. Облако предоставляет её из избыточных, временно свободных мощностей дата-центра.
>
> **Как это помогает в обучении :** Такая виртуалка стоит в разы дешевле обычной. Для тестов, развертывания домашних заданий и проверки кода Terraform вам не нужна отказоустойчивость. Если облаку потребуются ресурсы для коммерческих клиентов, вашу ВМ могут принудительно остановить, но для учёбы это не критично — вы всегда можете поднять её заново одной командой terraform apply.
> 
> **Ограничение :** Она работает непрерывно не более 24 часов, после чего автоматически останавливается. Для учебных сессий по 2–3 часа это идеальный вариант.

> **core_fraction=5**
>
> Этот параметр регулирует уровень производительности процессора. Он означает, что вашей виртуалке гарантированно выделяется только 5% вычислительной мощности физического ядра CPU. Если процессору понадобятся дополнительные ресурсы для кратковременной задачи (например, для компиляции или установки пакета), облако может временно выдать до 100% мощности (burst-режим), если физический процессор в этот момент не загружен другими пользователями.
>
> **Как это помогает в обучении :** Во время написания кода или тестирования конфигураций виртуалка 99% времени просто "простаивает" в ожидании ваших команд. Зачем переплачивать за 100% мощности ядра, если для работы в консоли Ubuntu достаточно минимального присутствия процессора? Понижение core_fraction до 5% или 20% срезает большую часть стоимости аренды процессора.

### Скриншоты к заданию 1:  

> Успешное применение команды terraform apply:
> ![1](https://github.com/user-attachments/assets/637727d2-d5b7-4058-80e7-ce71dab8cf24)

> Проверка создания ВМ в console.yandex.cloud:
> ![2](https://github.com/user-attachments/assets/755bede0-9976-4c96-919c-2a38c409e782)

> Выполнение команды curl ifconfig.me:  
> ![3](https://github.com/user-attachments/assets/868985eb-2794-4c4d-a382-8e35d2c0c9e7)

## Задание 2

### Шаг 1: Заменить все хардкод-значения на отдельные переменные.  
Для этого анонсирую меременные в файле **variables.tf**:  

> **variables.tf**
> ```text
> ...
> variable "vm_web_image_family" {
>   type        = string
>   default     = "ubuntu-2004-lts"
>   description = "OS image family for web VM"
> }
>
>
> variable "vm_web_name" {
>   type        = string
>   default     = "netology-develop-platform-web"
>   description = "Name of the web virtual machine"
> }
>
> variable "vm_web_platform_id" {
>   type        = string
>   default     = "standard-v3"
>   description = "Platform ID for web VM"
> }
>
> variable "vm_web_cores" {
>   type        = number
>   default     = 2
>   description = "Number of CPU cores"
> }
>
> variable "vm_web_memory" {
>    type        = number
>   default     = 1
>   description = "RAM size in GB"
> }
>
> variable "vm_web_core_fraction" {
>   type        = number
>   default     = 20
>   description = "Core fraction percentage"
> }
> ```

В файле main.tf меняю хардкод-значения на объявленные выше:

> **main.tf**
> ```text
> ...  
> resource "yandex_compute_instance" "platform" {  
>   name        = var.vm_web_name         
>   platform_id = var.vm_web_platform_id  
>    
>   resources {  
>     cores         = var.vm_web_cores          
>     memory        = var.vm_web_memory         
>     core_fraction = var.vm_web_core_fraction  
>   }  
> ...
> ```

Проверяю результат командой terraform plan изменений быть не должно:

> **Вывод фиксации изменения**
> ```text
> ...  
>          ~ initialize_params {  
>              ~ block_size  = 4096 -> (known after apply)  
>              + description = (known after apply)  
>              ~ image_id    = "fd8ucl971l0m6c5o8179" -> "fd8og910erljic63i7ln" # forces replacement  
>              + name        = (known after apply)  
>              ~ size        = 5 -> (known after apply)  
>              + snapshot_id = (known after apply)  
>                # (2 unchanged attributes hidden)  
>            }  
>        }  
> ...
> ```
> 

При проверке terraform plan после рефакторинга утилита показала деструктивное изменение (замену ВМ из-за изменения image_id).  

**Причина:** источник данных data "yandex_compute_image" "ubuntu" с параметром family = "ubuntu-2004-lts" динамически подтянул свежий ID образа, так как Yandex Cloud обновил базовый образ в своем репозитории.  

Сам рефакторинг кода на переменные выполнен корректно, хардкод убран. Чтобы избежать пересоздания ВМ на проде в реальных условиях, следовало бы временно зафиксировать старый ID через переменную или использовать lifecycle { ignore_changes = [boot_disk[0].initialize_params[0].image_id] }, но в рамках учебной задачи оставляю динамический поиск семейства, как требовалось в условиях.  

Командой terraform apply принимаю изменения и пересоздаю ВМ.

## Задание 3

### Шаг 1: Создать файл vms_platform.tf, перенести в него переменные созданные из задания 2, на первом шаге.

Перенес переменные из файла **variables.tf**  в файл **vms_platform.tf**.

### Шаг 2: Объявить в файле **vms_platform.tf** переменные для второй ВМ с префиксом vm_db_, в зоне "ru-central1-b".

**vms_platform.tf**  
> ```text  
> ...  
> variable "vm_db_zone" {  
>   type        = string  
>   default     = "ru-central1-b"  
>   description = "Target zone for DB instance"  
> }
>
> variable "vm_db_name" {
>   type    = string
>   default = "netology-develop-platform-db"
> }
>
> variable "vm_db_platform_id" {
>   type    = string
>   default = "standard-v3"
> }
>
> variable "vm_db_cores" {
>   type    = number
>   default = 2
> }
>
> variable "vm_db_memory" {
>   type    = number
>   default = 2
> }
>
> variable "vm_db_core_fraction" {
>   type    = number
>   default = 20
> }
> ...
> ```

Объявил переменную **var.default_cidr_b** в файле **variables.tf**:

>**variables.tf**
>```text
> variable "default_cidr_b" {
>   type        = list(string)
>   default     = ["10.0.2.0/24"]
>   description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
> }
>```

Добавил блок подсети и блок ресурсов для второй ВМ в файл **main.tf**

>**main.tf**
>```text
> resource "yandex_vpc_subnet" "develop_b" {
>   name           = "${var.vpc_name}-b"
>   zone           = var.vm_db_zone
>   network_id     = yandex_vpc_network.develop.id
>   v4_cidr_blocks = var.default_cidr_b
> }
>
> resource "yandex_compute_instance" "platform_db" {
>   name        = var.vm_db_name
>   platform_id = var.vm_db_platform_id
>   zone        = var.vm_db_zone 
>
>   resources {
>     cores         = var.vm_db_cores
>     memory        = var.vm_db_memory
>     core_fraction = var.vm_db_core_fraction
>   }
>```

### Шаг 3: Применить изменения

Приеняю изменения командами terraform validate, terraform  plan, terraform apply. Проверяю создание второй ВМ командой **yc compute instance list**:

```text
+----------------------+-------------------------------+---------------+---------+---------------+-------------+
|          ID          |             NAME              |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+-------------------------------+---------------+---------+---------------+-------------+
| epddt9rnfnvi7nslmiin | netology-develop-platform-db  | ru-central1-b | RUNNING | 51.250.22.210 | 10.0.2.21   |
| fhmr16i7s16hsuv7eok4 | netology-develop-platform-web | ru-central1-a | RUNNING | 89.169.159.36 | 10.0.1.7    |
+----------------------+-------------------------------+---------------+---------+---------------+-------------+
```

## Задание 4  

### Шаг 1: Объявить в файле outputs.tf один output , содержащий: instance_name, external_ip, fqdn для каждой из ВМ:

>**outputs.tf**
>```text
> output "vms_info" {
>   description = "Information about deployed virtual machines"
>   value = {
>     web_server = {
>       instance_name = yandex_compute_instance.platform.name
>       external_ip   = yandex_compute_instance.platform.network_interface[0].nat_ip_address
>       fqdn          = yandex_compute_instance.platform.fqdn
>     }
>     db_server = {
>       instance_name = yandex_compute_instance.platform_db.name
>       external_ip   = yandex_compute_instance.platform_db.network_interface[0].nat_ip_address
>       fqdn          = yandex_compute_instance.platform_db.fqdn
>     }
>   }
> }
>```

### Шаг 2: Применить изменения

Обновляю состояние без применнения изменений к основным ресрусам командой terraform apply -refresh-only, вывожу output командой **terraform output**:

```text
vms_info = {
  "db_server" = {
    "external_ip" = "51.250.22.210"
    "fqdn" = "epddt9rnfnvi7nslmiin.auto.internal"
    "instance_name" = "netology-develop-platform-db"
  }
  "web_server" = {
    "external_ip" = "89.169.159.36"
    "fqdn" = "fhmr16i7s16hsuv7eok4.auto.internal"
    "instance_name" = "netology-develop-platform-web"
  }
}
```

## Задание 5

### Шаг 1: В файле locals.tf описать в одном local-блоке имя каждой ВМ, использовать интерполяцию:

>**locals.tf**
>```text
> locals {
>   project = "netology"
>   env     = "develop"
>
>   vm_web_name = "${local.project}-${local.env}-platform-web"
>   vm_db_name  = "${local.project}-${local.env}-platform-db"
> }
>```

### Шаг 2: Заменить переменные внутри ресурса ВМ на созданные вами local-переменные.

>**main.tf**
>```text
> ...
> name        = local.vm_web_name
> ...
> name        = local.vm_db_name
> ...
>```

### Шаг 3: Применить изменения:

> **terraform plan**  
> ![1](https://github.com/user-attachments/assets/59016541-444e-41c6-88f6-d931027631ce)

## Задание 6

### Шаг 1: Объединить отдельные переменные в единую map-переменную vms_resources 

Переопределяю переменные в файле **vms_platform.tf**
```text
variable "vms_resources" {
  type = map(object({
    image_family  = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
      image_family  = "ubuntu-2004-lts"
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
    db = {
      image_family  = "ubuntu-2004-lts"
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}
variable "vms_metadata" {
  type = map(string)
  default = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5 ... sedser/jIqn7ulu7EvYsHAYqsvzPG o_komel@kms-test"
  }
}
```

### Шаг 2: Создайть и использовать отдельную map(object) переменную для блока metadata

> **terraform.tfvars**
> ```text
>  vms_metadata = {
>   serial-port-enable = "1"
>   ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJzy ... r/jIqn7ulu7EvYsHAYqsvzPG o_komel@kms-test"
> }
> ```

### Шаг 3: Найти и закоментировать все, более не используемые переменные проекта
Закоментировал все отдельные переменные в файле **vms_platform.tf**  

### Шаг 4: Выполнить проверку

> **terraform plan**  
> ![2](https://github.com/user-attachments/assets/4c2b0f60-42c2-48cc-9312-144e41ea4d17)

## Задание 7

### Шаг 1:  

> **local.test_list[1]**
> ```text
> "staging"
> ```

### Шаг 2:  

> **length(local.test_list)**
> ```text
> 3
> ```

### Шаг 3:

> **local.test_map["admin"]**
> ```text
> "John"
> ```

### Шаг 4:

> **"${local.test_map["admin"]} is ${keys(local.test_map)[0]} for production server based on OS ${local.servers["production"].image} with ${local.servers["production"].cpu} vcpu, ${local.servers["production"].ram} ram and ${length(local.servers["production"].disks)} virtual disks"**
> ```text
> "John is admin for production server based on OS ubuntu-20-04 with 10 vcpu, 40 ram and 4 virtual disks"
> ```

