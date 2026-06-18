# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»

## Задание 1

Добавил ранее созданый ключ файл в **providers.tf**, передал значение переменной **folder_id** в переменное окружение, инициализировал **terraform init**, проверил синтаксис и структуру файлов кода **terraform validate**, выполнил код **terraform apply**.  
В личном кабинете **console.yandex.cloud** проверил появление группы безопасности **example_dynamic**:  

> **Группа безопасности example_dynamic**:  
>   
> ![1](https://github.com/user-attachments/assets/239ac41c-31b2-4e42-ace0-0400e5a83105)
 
## Задание 2

### Шаг 1: Разработал конфигурацию переменных в файле variables.tf. Описал мапу базовых ресурсов vms_resources с ограничением core_fraction на 20% для экономии бюджета, а также строго типизированный список объектов each_vm для конфигурации баз данных с индивидуальными параметрами CPU, RAM и дисков.

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

### Шаг 2: Добавил блок locals для динамического чтения ранее сгенерированного публичного SSH-ключа id_ed25519.pub с помощью встроенной функции file, исключив прямое хардкодинг ключей в кодовой базе.

```hcl
locals {
  ssh_key = "ubuntu:${file("/home/o_komel/.ssh/id_ed25519.pub")}"
}
```

### Шаг 3: Создал файл for_each-vm.tf для развертывания инфраструктуры баз данных. С помощью выражения цикла for трансформировал исходный список объектов во вспомогательную карту (map) для корректной работы мета-аргумента for_each.

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

### Шаг 4: Создал файл count-vm.tf для веб-серверов. С помощью мета-аргумента count задал итерацию на 2 копии. Использовал арифметическое выражение со значением count.index для именования виртуальных машин строго как web-1 и web-2. Подключил группу безопасности example из первого задания и добавил мета-аргумент depends_on для соблюдения очередности создания инфраструктуры (строго после развертывания СУБД).

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
> ```

