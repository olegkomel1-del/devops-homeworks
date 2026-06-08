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
<div style="background-color: #f1f3f5; padding: 6px 16px; border-top-left-radius: 8px; border-top-right-radius: 8px; font-family: monospace; font-size: 14px; color: #333; font-weight: bold; border: 1px solid #e1e4e8; border-bottom: none;">text</div>
Terraform v1.5.7
on linux_amd64
```
