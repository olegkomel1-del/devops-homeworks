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
  name  = "nginx_server"
  image = docker_image.nginx.image_id
}
```

> **Вывод команды terraform validate:**
> ```text
> Success! The configuration is valid.
> ```

