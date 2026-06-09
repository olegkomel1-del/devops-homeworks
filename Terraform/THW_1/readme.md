# Установка Terraform

### Скачиваем архив Terraform из зеркала яндекс 

```bash
wget https://hashicorp-releases.yandexcloud.net/terraform/1.12.0/terraform_1.12.0_linux_amd64.zip
```

### Распоковываем архив

```bash
unzip terraform_1.12.0_linux_amd64.zip
```

### Переносим файлы в глобальную директорию

```bash
sudo mv terraform /usr/local/bin/
```

### Удаляем архив

```bash
rm terraform_1.12.0_linux_amd64.zip
```

### Проверяем версию Terraform

```bash
terraform -version
```


> **Вывод:**
>```text
>Terraform v1.12.0
>on linux_amd64
>```


# Выполнение Задания 1

### Шаг 1: Инициализация проекта и скачивание зависимостей

Перешел в каталог `ter-homeworks/01/src`, настроил глобальный файл зеркала Яндекса `~/.terraformrc` и запустил команду `terraform init`.

> **Вывод terraform init:**
> ```text
> Initializing the backend...
> Initializing provider plugins...
> - Finding latest version of kreuzwerker/docker...
> - Finding latest version of hashicorp/random...
> - Installing kreuzwerker/docker v4.4.0...
> - Installed kreuzwerker/docker v4.4.0 (unauthenticated)
> - Installing hashicorp/random v3.9.0...
> - Installed hashicorp/random v3.9.0 (unauthenticated)
> 
> Terraform has been successfully initialized!
> ```

### Шаг 2: Изучение файла .gitignore

**Вопрос:** В каком terraform-файле, согласно этому .gitignore, допустимо сохранить личную, секретную информацию (логины, пароли, ключи, токены итд)?

**Ответ:** Личную и секретную информацию допустимо сохранять в файлах с расширением `*.tfvars` (например, `terraform.tfvars`) или `*.auto.tfvars` (например, `secrets.auto.tfvars`). В предоставленном файле `.gitignore` явно прописаны эти маски, что гарантирует игнорирование данных файлов утилитой Git. Они никогда не попадут в публичный репозиторий на GitHub, но локально Terraform их успешно прочитает.

### Шаг 3: Выполнение кода и поиск секрета в state-файле

Выполнил команду `terraform apply` и подтвердил создание ресурса. После успешного деплоя открыл созданный файл `terraform.tfstate` с помощью утилиты `cat`.

*   **Найденный секретный ключ:** `result`
*   **Значение ключа:** `Wm82dkYbN4uPnAAF`

> **Вывод блока ресурса из terraform.tfstate:**
> ```json
> "attributes": {
>   "bcrypt_hash": "\$2a\$10\$WFanStyGT6BmXWjUuLDyGuJLX.IJnZxD.V2ILrIilWan3bikjMEJ.",
>   "id": "none",
>   "length": 16,
>   "lower": true,
>   "result": "Wm82dkYbN4uPnAAF",
>   "special": false,
>   "upper": true
> }
> ```


### Шаг 4: Исправление закомментированных ошибок в коде

Раскомментировал блок создания Docker-контейнера в файле `main.tf` и запустил команду `terraform validate`. Команда выявила следующие намеренно допущенные ошибки:

1. **Отсутствие имени ресурса `docker_image`** — блок ресурса не содержал обязательного второго ярлыка (локального имени). Исправлено добавлением имени `"nginx"`.
2. **Невалидное имя ресурса `docker_container` (`1nginx`)** — имя локального ресурса в Terraform не может начинаться с цифры. Исправлено переименованием в `"nginx"`.
3. **Ошибочная передача образа контейнеру (`image = docker_image.nginx`)** — была попытка передать весь объект провайдера вместо конкретной строки с ID образа. Исправлено добавлением свойства `.image_id`.

**Исправленный фрагмент кода в main.tf:**
```hcl

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 9090
  }
}
```

> **Вывод команды terraform validate:**
> ```text
> Success! The configuration is valid.
> ```

### Шаг 5: Выполнение кода и проверка запущенных ресурсов

Применил конфигурацию командой `terraform apply` и проверил состояние запущенных контейнеров в операционной системе.

> **Вывод команды docker ps:**
> ```text
> CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
> 076b35a71ba6   5aca99593157   "/docker-entrypoint.…"   20 seconds ago   Up 19 seconds   0.0.0.0:9090->80/tcp   example_Wm82dkYbN4uPnAAF
> ```

### Шаг 6: Изменение имени контейнера и использование флага -auto-approve

Заменил префикс имени контейнера на `hello_world_` с сохранением интерполяции случайного пароля. Применил конфигурацию в автоматическом режиме с помощью флага `-auto-approve`.

> **Вывод команды docker ps после переименования:**
> ```text
> CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
> f16e22af634e   5aca99593157   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:9090->80/tcp   hello_world_Wm82dkYbN4uPnAAF
> ```

**Ответы на вопросы:**
*   **В чём опасность ключа `-auto-approve`?** Данный флаг полностью отключает интерактивную паузу для подтверждения со стороны инженера. Terraform не выводит финальный план изменений на подтверждение (`yes/no`). Если в коде была допущена ошибка, которая принудительно запускает пересоздание критически важного объекта (например, базы данных в продакшене), ключ `-auto-approve` мгновенно и без предупреждения уничтожит старый рабочий ресурс, что приведет к потере данных и простою сервисов.
*   **Зачем нужен этот ключ?** Он необходим для интеграции в автоматические автоматизированные CI/CD пайплайны (GitLab CI, GitHub Actions, Jenkins), где развертыванием инфраструктуры управляет робот, который физически не может ввести `yes` в консоли.

### Шаг 7: Уничтожение ресурсов и анализ состояния

Полностью очистил инфраструктуру лабораторной работы с помощью команды `terraform destroy -auto-approve`.

> **Вывод содержимого файла terraform.tfstate после удаления:**
> ```json
> {
>   "version": 4,
>   "terraform_version": "1.12.0",
>   "serial": 11,
>   "lineage": "c9b41da4-4b7d-aa3e-27c5-6ab1cb1e3f45",
>   "outputs": {},
>   "resources": [],
>   "check_results": null
> }
> ```

**Объяснение, почему при этом не был удалён docker-образ nginx:latest:**

1. **Согласно предоставленному коду проекта**, в файле `main.tf` внутри блока ресурса `docker_image` задан аргумент `keep_locally = true`.
2. **Согласно официальной документации terraform-провайдера docker** (раздел классификатора `resource docker_image`): 
   > *"keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will be deleted from the local Docker registry on destroy operation."*

Поскольку данный флаг активен (`true`), Terraform удалил сам запущенный контейнер, но оставил скачанный образ в локальном кэше хост-системы.

## Выполнение Задания 2* (Работа с Remote Docker Context и Секретами)

### Шаг 1: Настройка переменных и скрытие секретов

В каталоге проекта `src` был создан секретный файл конфигурации переменных `personal.auto.tfvars`. Данный файл содержит чувствительные данные доступа к Yandex Cloud и заблокирован для утилиты Git с помощью правил `.gitignore`.

**Содержимое файла personal.auto.tfvars:**
```hcl
yc_token     = "t1.9euel..." # Новый OAuth/IAM токен авторизации
yc_cloud_id  = "b1g..."     # ID Облака Yandex Cloud
yc_folder_id = "b1g8..."    # ID Каталога (Folder ID)
```

В файле `main.tf` были объявлены соответствующие входные переменные, а также настроены блоки провайдеров `yandex` и `docker` (с перенаправлением контекста на удаленную ВМ в облаке по SSH через конфигурационный файл `~/.ssh/config`):

```hcl
variable "yc_token" { type = string }
variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
    random = {
      source  = "hashicorp/random"
    }
  }
  required_version = "~>1.12.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

provider "docker" {
  host = "ssh://o_komel@111.88.240.140:22"
}
```

---

### Шаг 2: Конфигурация манифеста MySQL и развертывание в Облаке

В файле `main.tf` был описан манифест для генерации двух независимых случайных паролей (через `random_password`) и развертывания контейнера `mysql:8` на удаленном хосте. Имя контейнера генерируется динамически с использованием интерполяции и привязки строки root-пароля. Порт `3306` проброшен строго на локальный интерфейс ВМ (`127.0.0.1:3306`), изолируя базу данных от внешнего интернета.

**Используемый блок ресурсов в main.tf:**
```hcl
resource "random_password" "mysql_root_password" {
  length  = 16
  special = false
}

resource "random_password" "mysql_user_password" {
  length  = 16
  special = false
}

resource "docker_image" "mysql" {
  name = "mysql:8"
}

resource "docker_container" "mysql" {
  image = docker_image.mysql.image_id
  name  = "example_${random_password.mysql_root_password.result}"

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_user_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}
```

Деплой запущен на локальной машине командой `terraform apply -auto-approve` и завершился успехом (`Apply complete!`).

---

### Шаг 3: Контрольная проверка запущенных ресурсов на удаленной ВМ

Выполнил подключение к созданной виртуальной машине `remote-docker-host` по SSH и запросил состояние Docker-окружения.

> **Вывод команды docker ps на удаленной ВМ:**
> ```text
> CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                 NAMES
> edac6fedddf1   c36050afdca8   "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   127.0.0.1:3306->3306/tcp, 33060/tcp   example_OG8EcsANVDfqAJCV
> ```

Провалился внутрь запущенного контейнера базы данных с помощью команды `docker exec` для валидации секретных переменных окружения.

> **Вывод команды docker exec -it example_OG8EcsANVDfqAJCV env:**
> ```text
> PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
> HOSTNAME=edac6fedddf1
> TERM=xterm
> MYSQL_ROOT_HOST=%
> MYSQL_ROOT_PASSWORD=OG8EcsANVDfqAJCV
> MYSQL_DATABASE=wordpress
> MYSQL_PASSWORD=scETLL60BitGoizw
> MYSQL_USER=wordpress
> GOSU_VERSION=1.19
> MYSQL_MAJOR=8.4
> MYSQL_VERSION=8.4.9-1.el9
> MYSQL_SHELL_VERSION=8.4.9-1.el9
> HOME=/root
> ```

**Вывод:** Тестирование подтверждает корректную работу интерполяции строк в Terraform. Контейнер успешно получил уникальное имя `example_OG8EcsANVDfqAJCV` на основе сгенерированного root-пароля. Внутри контейнера присутствуют все секретные ENV-переменные с уникальными значениями паролей, сгенерированных провайдером `random`.

### Итоговый скриншот
![Итоговый скриншот](https://github.com/user-attachments/assets/94097446-4ff1-4a99-86c8-4a696b5ef681)


## Выполнение Задания 3* (Переход на OpenTofu и проверка совместимости)

### Шаг 1: Установка OpenTofu
Скачал официальный дистрибутив OpenTofu версии 1.8.8 в виде бинарного zip-архива с GitHub. Распаковал утилиту и перенес исполняемый файл в глобальную директорию `/usr/local/bin/`.

> **Вывод команды tofu --version:**
> ```text
> OpenTofu v1.8.8
> on linux_amd64
> ```

---

### Шаг 2: Обеспечение совместимости и локальная инициализация плагинов
При использовании OpenTofu в изолированной среде без внешнего доступа к реестрам возник конфликт нейминга: утилита искала провайдеры по умолчанию в пространстве имён `registry.opentofu.org`. 

Для обеспечения совместимости в манифесте `main.tf` были явно переопределены источники (source) провайдеров на глобальный реестр `registry.terraform.io`, что позволило OpenTofu бесшовно использовать кэш, ранее скачанный утилитой Terraform:

```hcl
terraform {
  required_providers {
    yandex = {
      source = "registry.terraform.io/yandex-cloud/yandex"
    }
    docker = {
      source = "registry.terraform.io/kreuzwerker/docker"
    }
    random = {
      source = "registry.terraform.io/hashicorp/random"
    }
  }
  required_version = ">= 1.5.0"
}
```

Инициализация выполнена локально из существующего кэша провайдеров без обращения к внешней сети с помощью флага `-plugin-dir`:
```bash
tofu init -plugin-dir=.terraform/providers
```

> **Вывод команды tofu init:**
> ```text
> Initializing the backend...
> Initializing provider plugins...
> OpenTofu has been successfully initialized!
> ```

---

### Шаг 3: Проверка состояния инфраструктуры через OpenTofu
Запустил применение манифестов конфигурации через OpenTofu для проверки существующего состояния ресурсов на удаленной ВМ.

```bash
tofu apply -auto-approve
```

> **Вывод команды tofu apply:**
> ```text
> random_password.mysql_root_password: Refreshing state... [id=none]
> random_password.mysql_user_password: Refreshing state... [id=none]
> docker_image.mysql: Refreshing state... [id=sha256:c36050afdca8...]
> docker_container.mysql: Refreshing state... [id=edac6fedddf1...]
> 
> No changes. Infrastructure is up-to-date.
> 
> Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
> ```

**Вывод:** Тестирование подтверждает полную бинарную, логическую и архитектурную обратную совместимость OpenTofu с существующими конфигурационными файлами формата HCL и state-файлами `terraform.tfstate`. Утилита `tofu` успешно прочитала текущую конфигурацию, подключилась к удаленному Docker-контексту по SSH-каналу и подтвердила актуальность развернутого контейнера MySQL без необходимости пересоздания ресурсов.

### Итоговый скриншот
![Итоговый скриншот](https://github.com/user-attachments/assets/49f0c7ae-aadf-4d25-a4fe-e00116a11dcd)
