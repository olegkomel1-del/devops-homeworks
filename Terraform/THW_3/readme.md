# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»

## Задание 1

Добавил ранее созданый ключ файл в **providers.tf**, передал значение переменной **folder_id** в переменное окружение, инициализировал **terraform init**, проверил синтаксис и структуру файлов кода **terraform validate**, выполнил код **terraform apply**.  
В личном кабинете **console.yandex.cloud** проверил появление группы безопасности **example_dynamic**:  

> **Группа безопасности example_dynamic**:  
>   
> ![1](https://github.com/user-attachments/assets/239ac41c-31b2-4e42-ace0-0400e5a83105)
 
## Задание 2

### Шаг 1: Разработал конфигурацию переменных в файле variables.tf. 

```hcl
variable "each_vm" {
  type = list(object({
    vm_name       = string
    cpu           = number
    ram           = number
    disk_volume   = number
    core_fraction = number
  }))
  default = [
    {
      vm_name       = "main"
      cpu           = 4
      ram           = 4
      disk_volume   = 20
      core_fraction = 20
    },
    {
      vm_name       = "replica"
      cpu           = 2
      ram           = 2
      disk_volume   = 15
      core_fraction = 20
    }
  ]
}
```

### Шаг 2: Добавил блок locals для динамического чтения ранее сгенерированного публичного SSH-ключа id_ed25519.pub с помощью встроенной функции file.

```hcl
locals {
  ssh_key = "ubuntu:${file("/home/o_komel/.ssh/id_ed25519.pub")}"
}
```

### Шаг 3: Создал файл for_each-vm.tf для развертывания инфраструктуры баз данных.

```bash
nano for_each-vm.tf
```

> **for_each-vm.tf**
> ```hcl
> resource "yandex_compute_instance" "db_vm" {
>   for_each = { for vm in var.each_vm : vm.vm_name => vm }
>   name        = each.key
>   platform_id = var.vms_resources.web.platform_id
> 
>   resources {
>     cores         = each.value.cpu
>     memory        = each.value.ram
>     core_fraction = each.value.core_fraction
>   }
> 
>   boot_disk {
>     initialize_params {
>       image_id = data.yandex_compute_image.ubuntu.id
>       size     = each.value.disk_volume
>     }
>   }
> 
>   network_interface {
>     subnet_id = yandex_vpc_subnet.develop.id
>     nat       = true
>   }
> 
>   metadata = merge(var.vms_metadata, {
>     ssh-keys = local.ssh_key
>   })
> }
> ```

### Шаг 4: Создал файл count-vm.tf для веб-серверов. 

```bash
nano count-vm.tf
```

> **count-vm.tf**
> ```hcl
> resource "yandex_compute_instance" "web_vm" {
>   count = 2
>   name        = "web-${count.index + 1}"
>   platform_id = var.vms_resources.web.platform_id
> 
>   resources {
>     cores         = var.vms_resources.web.cores
>     memory        = var.vms_resources.web.memory
>     core_fraction = var.vms_resources.web.core_fraction
>   }
> 
>   boot_disk {
>     initialize_params {
>       image_id = data.yandex_compute_image.ubuntu.id
>       size     = 10
>     }
>   }
> 
>   network_interface {
>     subnet_id          = yandex_vpc_subnet.develop.id
>     nat                = true
>     security_group_ids = [yandex_vpc_security_group.example.id]
>   }
> 
>   metadata = merge(var.vms_metadata, {
>     ssh-keys = local.ssh_key
>   })
> 
>   depends_on = [yandex_compute_instance.db_vm]
> }
> ```

### Шаг 5: Выполнил валидацию проекта и успешно применил конфигурацию.

```bash
terraform validate
terraform apply -auto-approve
```

> **Вывод terraform validate:**
> ```text
> Success! The configuration is valid.
> Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
> ```

> **Скриншот из console.yandex.cloud**:  
> 
> ![2](https://github.com/user-attachments/assets/ac8411d3-1793-46ad-a48d-feb438f94dd5)

## Задание 3

### Шаг 1: Создал файл disk_vm.tf. Описал в нём создание 3 одинаковых виртуальных дисков размером 1 Гб с помощью ресурса yandex_compute_disk и цикла count. Имена дисков параметризировал через count.index.

```bash
nano disk_vm.tf
```

### Шаг 2: В этом же файле описал одиночную ВМ "storage". Для подключения созданных дисков использовал динамический блок dynamic "secondary_disk", который с помощью встроенного цикла for_each перебирает список созданных дисков и автоматически забирает их disk_id.

> **disk_vm.tf**
> ```hcl
> resource "yandex_compute_disk" "storage_disks" {
>   count = 3
>   name  = "storage-disk-${count.index + 1}"
>   zone  = var.default_zone
>   size  = 1
> }
> 
> resource "yandex_compute_instance" "storage_vm" {
>   name        = "storage"
>   platform_id = var.vms_resources.web.platform_id
> 
>   resources {
>     cores         = 2
>     memory        = 2
>     core_fraction = 20
>   }
> 
>   boot_disk {
>     initialize_params {
>       image_id = data.yandex_compute_image.ubuntu.id
>       size     = 10
>     }
>   }
> 
>   dynamic "secondary_disk" {
>     for_each = yandex_compute_disk.storage_disks
>     content {
>       disk_id = secondary_disk.value.id
>     }
>   }
> 
>   network_interface {
>     subnet_id = yandex_vpc_subnet.develop.id
>     nat       = true
>   }
> 
>   metadata = merge(var.vms_metadata, {
>     ssh-keys = local.ssh_key
>   })
> }
> ```

### Шаг 3: Проверил конфигурацию и применил изменения.

```bash
terraform validate
terraform apply -auto-approve
```

> **Вывод terraform validate:**
> ```text
> Success! The configuration is valid.
> Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
> ```

> **Скриншот из console.yandex.cloud**:  
> 
> ![3](https://github.com/user-attachments/assets/77c0e4ea-6563-4b10-b413-25ebfa8eb45f)

