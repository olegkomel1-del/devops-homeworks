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

## Задание 4

### Шаг 1: Создал файл-шаблон hosts.tpl.

```bash
nano hosts.tpl
```

> **hosts.tpl**
> ```ini
> [webservers]
> %{ for i in webservers ~}
> ${i.name} ansible_host=${i.network_interface.nat_ip_address} fqdn=${i.fqdn}
> %{ endfor ~}
> 
> [databases]
> %{ for i in databases ~}
> ${i.name} ansible_host=${i.network_interface.nat_ip_address} fqdn=${i.fqdn}
> %{ endfor ~}
> 
> [storage]
> %{ for i in storage ~}
> ${i.name} ansible_host=${i.network_interface.nat_ip_address} fqdn=${i.fqdn}
> %{ endfor ~}
> ```

### Шаг 2: Создал файл ansible.tf.

```bash
nano ansible.tf
```

> **ansible.tf**
> ```hcl
> resource "local_file" "hosts_cfg" {
>   filename = "${path.module}/hosts.cfg"
> 
>   content = templatefile("${path.module}/hosts.tpl", {
>     webservers = yandex_compute_instance.web_vm
>     databases  = values(yandex_compute_instance.db_vm)
>     storage    = [yandex_compute_instance.storage_vm]
>   })
> }
> ```

### Шаг 3: Проверил конфигурацию, применил изменения и вывел содержимое сгенерированного файла в терминал.

```bash
terraform validate
terraform apply -auto-approve
cat hosts.cfg
```

> **Вывод команды cat hosts.cfg:**
> ```text
> [webservers]
> web-1 ansible_host=93.77.184.5 fqdn=fhm4lvnpptlupjt8j5nl.auto.internal
> web-2 ansible_host=84.201.159.213 fqdn=fhmq94d851b5prp370n1.auto.internal
> 
> [databases]
> main ansible_host=93.77.191.199 fqdn=fhmmfpgps3e2f5ajvict.auto.internal
> replica ansible_host=93.77.191.3 fqdn=fhmdcnlv8s0g3ffllb2u.auto.internal
> 
> [storage]
> storage ansible_host=111.88.250.56 fqdn=fhmjk0ar3c1oldkudmqe.auto.internal
> ```

> **Скриншот из консоли терминала**:  
> 
> ![4](https://github.com/user-attachments/assets/5b9136fe-1e6b-4977-a14a-5a5f66005ad2)

## Задание 5* (Необязательное)

### Шаг 1: Создал файл outputs.tf.

```bash
nano outputs.tf
```

> **outputs.tf**
> ```hcl
> output "all_vms_info" {
>   description = "Список словарей со всеми созданными ВМ из ресурсов count, for_each и одиночной ВМ storage"
> 
>   value = concat(
>     [
>       for vm in yandex_compute_instance.web_vm : {
>         name = vm.name
>         id   = vm.id
>         fqdn = vm.fqdn
>       }
>     ],
>     [
>       for vm in values(yandex_compute_instance.db_vm) : {
>         name = vm.name
>         id   = vm.id
>         fqdn = vm.fqdn
>       }
>     ],
>     [
>       {
>         name = yandex_compute_instance.storage_vm.name
>         id   = yandex_compute_instance.storage_vm.id
>         fqdn = yandex_compute_instance.storage_vm.fqdn
>       }
>     ]
>   )
> }
> ```

### Шаг 2: Обновил состояние конфигурации и вывел структурированный список всех 5 ВМ в консоль.

```bash
terraform refresh
terraform output all_vms_info
```

> **Вывод команды terraform output all_vms_info:**
> ```text
> all_vms_info = [
>   {
>     "fqdn" = "fhm4lvnpptlupjt8j5nl.auto.internal"
>     "id" = "fhm4lvnpptlupjt8j5nl"
>     "name" = "web-1"
>   },
>   {
>     "fqdn" = "fhmq94d851b5prp370n1.auto.internal"
>     "id" = "fhmq94d851b5prp370n1"
>     "name" = "web-2"
>   },
>   {
>     "fqdn" = "fhmmfpgps3e2f5ajvict.auto.internal"
>     "id" = "fhmmfpgps3e2f5ajvict"
>     "name" = "main"
>   },
>   {
>     "fqdn" = "fhmdcnlv8s0g3ffllb2u.auto.internal"
>     "id" = "fhmdcnlv8s0g3ffllb2u"
>     "name" = "replica"
>   },
>   {
>     "fqdn" = "fhmjk0ar3c1oldkudmqe.auto.internal"
>     "id" = "fhmjk0ar3c1oldkudmqe"
>     "name" = "storage"
>   },
> ]
> ```

> **Скриншот из консоли терминала**:  
> 
> ![4](https://github.com/user-attachments/assets/4c12e074-04d8-45db-9b9b-3c7515e852c9)


## Задание 6* (Необязательное)

### Шаг 1: Обновил индекс пакетов и установил утилиту Ansible в систему, чтобы у Terraform была возможность вызывать сценарии локально.

```bash
sudo apt update && sudo apt install -y ansible
```

### Шаг 2: Модифицировал файл ansible.tf. Добавил в него ресурс null_resource и provisioner "local-exec" для автоматического запуска ansible-playbook после генерации инвентаря. Для предотвращения падения Терраформа из-за сетевой недоступности изолированных ВМ добавил флаг on_failure = continue.

```bash
nano ansible.tf
```

> **Обновленный ansible.tf**
> ```hcl
> resource "local_file" "hosts_cfg" {
>   filename = "${path.module}/hosts.cfg"
> 
>   content = templatefile("${path.module}/hosts.tpl", {
>     webservers = yandex_compute_instance.web_vm
>     databases  = values(yandex_compute_instance.db_vm)
>     storage    = [yandex_compute_instance.storage_vm]
>   })
> }
> 
> resource "null_resource" "web_hosts_provision" {
>   depends_on = [local_file.hosts_cfg]
>   triggers = {
>     policy_tf = join(",", [for v in yandex_compute_instance.web_vm : v.network_interface.0.ip_address])
>   }
>   provisioner "local-exec" {
>     command    = "sleep 30 && ansible-playbook -i ${local_file.hosts_cfg.filename} ${path.module}/test.yml"
>     on_failure = continue
>   }
> }
> ```

### Шаг 3: Перешёл в файлы count-vm.tf, for_each-vm.tf и disk_vm.tf, где в блоках конфигурации сетевых интерфейсов network_interface отключил внешние IP-адреса, переведя параметр в nat=false.

```bash
# В файлах count-vm.tf, for_each-vm.tf, disk_vm.tf:
network_interface {
  subnet_id = yandex_vpc_subnet.develop.id
  nat       = false
}
```

### Шаг 4: Модифицировал файл outputs.tf.

```bash
nano outputs.tf
```

> **Обновленный outputs.tf**
> ```hcl
> output "all_vms_info" {
>   description = "Список словарей со всеми созданными ВМ из ресурсов count, for_each и одиночной ВМ storage"
> 
>   value = concat(
>     [
>       for vm in yandex_compute_instance.web_vm : {
>         name        = vm.name
>         id          = vm.id
>         fqdn        = vm.fqdn
>         local_ip    = vm.network_interface.0.ip_address
>         external_ip = vm.network_interface.0.nat_ip_address
>       }
>     ],
>     [
>       for vm in values(yandex_compute_instance.db_vm) : {
>         name        = vm.name
>         id          = vm.id
>         fqdn        = vm.fqdn
>         local_ip    = vm.network_interface.0.ip_address
>         external_ip = vm.network_interface.0.nat_ip_address
>       }
>     ],
>     [
>       {
>         name        = yandex_compute_instance.storage_vm.name
>         id          = yandex_compute_instance.storage_vm.id
>         fqdn        = yandex_compute_instance.storage_vm.fqdn
>         local_ip    = yandex_compute_instance.storage_vm.network_interface.0.ip_address
>         external_ip = yandex_compute_instance.storage_vm.network_interface.0.nat_ip_address
>       }
>     ]
>   )
> }
> ```

### Шаг 5: Запустил сборку инфраструктуры. 

```bash
terraform apply -auto-approve
```

> **Скриншот из консоли терминала**:  
> 
> ![5](https://github.com/user-attachments/assets/9f80cd9d-8f8c-4f3d-9566-6c3cd5b83bdb)


## Задание 7* (Необязательное)

### Шаг 1: Объявил исходную тестовую структуру данных vpc внутри блока locals в файле variables.tf.

```hcl
locals {
  vpc = {
    network_id = "enp7i560tb28nageq0cc"
    subnet_ids = [
      "e9b0le401619ngf4h68n",
      "e2lbar6u8b2ftd7f5hia",
      "b0ca48coorjjq93u36pl",
      "fl8ner8rjsio6rcpcf0h",
    ]
    subnet_zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-c",
      "ru-central1-d",
    ]
  }
}
```

### Шаг 2: Запустил интерактивный режим работы конфигуратора и ввёл динамическое выражение. 

```bash
terraform console
```

> **Выражение в terraform console:**
> ```hcl
> { 
>   network_id   = local.vpc.network_id, 
>   subnet_ids   = [for idx, id in local.vpc.subnet_ids : id if idx != 2], 
>   subnet_zones = [for idx, zone in local.vpc.subnet_zones : zone if idx != 2] 
> }
> ```

> **Конечный результат вывода:**
>
> ![6](https://github.com/user-attachments/assets/bb095f94-6615-4909-b3a8-28fe8a626516)

## Задание 8* (Необязательное)

### Шаг 1: Создал тестовый файл bad_hosts.tpl и вставил в него предложенный в задании код с намеренно допущенными ошибками. В файле ansible.tf временно переключил функцию templatefile на чтение этого сломанного шаблона.

### Шаг 2: Запустил боевую проверку синтаксиса через утилиту terraform validate.

```bash
terraform validate
```

> **Вывод лога ошибки от terraform validate:**
> ```text
> │ Error: Error in function call
> │ 
> │   on ansible.tf line 4, in resource "local_file" "hosts_cfg":
> │    4:     content = templatefile("\${path.module}/bad_hosts.tpl", {
> │ 
> │ Call to function "templatefile" failed: ./bad_hosts.tpl:3,85-86: Invalid character; This character is not used within the language., and 1 other diagnostic(s).
> ```

### Шаг 3: Провел аудит лога и устранил две ошибки в bad_hosts.tpl:
1. **Пропущена закрывающая фигурная скобка `}`** в блоке интерполяции адреса: `ansible_host=${i["network_interface"]["nat_ip_address"]`. Из-за этого парсер посчитал остаток строки частью выражения.
2. **Лишний пробел в имени ключа** платформы: `i["platform_id "]`. Изменил его на строгое имя `"platform_id"`.

После внесения правок и возврата оригинального шаблона в ansible.tf, проверка успешно прошла со статусом `Success!`.

> **Скриншот из консоли терминала**:  
> 
> ![7](https://github.com/user-attachments/assets/92645642-45f9-4f60-99ad-4356e8ee0762)


