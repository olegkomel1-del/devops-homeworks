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

### Шаг 2: Настроил вызовы remote-модулей в файле main.tf<img width="1828" height="155" alt="10" src="https://github.com/user-attachments/assets/0f2e5d4a-08de-4efe-af46-77c81f48adc1" />


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

