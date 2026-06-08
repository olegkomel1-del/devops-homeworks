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
