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
