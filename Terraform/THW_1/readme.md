# Установка Terraform

### Скачиваем архив Terraform из зеркала яндекс 

```bash
wget https://hashicorp-releases.yandexcloud.net/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
```

### Распоковываем архив

```bash
unzip terraform_1.5.7_linux_amd64.zip
```

### Переносим файлы в глобальную директорию

```bash
sudo mv terraform /usr/local/bin/
```

### Удаляем архив

```bash
rm terraform_1.5.7_linux_amd64.zip
```

### Проверяем версию Terraform

```bash
terraform -version
```

```
**Text**
Terraform v1.5.7
on linux_amd64
```
