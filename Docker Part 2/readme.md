<details>
  
<summary>
  
# Задание 0.1 (Удаление)

</summary>    

## 1. Проверка версии Docker Compose перед удалением  

### Ввод:
```bash
docker-compose --version
``` 
### Вывод:
```text
Docker Compose version v5.1.1
```

## 2. Проверка версии Docker перед удалением

### Ввод:
```bash
docker --version
``` 
### Вывод:
```text
Docker version 29.3.1, build c2be9cc
```

## 3. Удаление snap-пакета Docker  

### Ввод:
```bash
sudo snap remove docker
``` 
### Вывод:
```text
docker removed (snap data snapshot saved)
```

## 4. Просмотр сохраненных снимков данных (snapshots)

### Ввод:
```bash
snap saved
``` 
### Вывод:
```text
Set  Snap    Age    Version  Rev   Size   Notes
1    docker  1m47s  29.3.1   3505  368MB  auto
```

## 5. Удаление сохраненного снимка под номером 1

### Ввод:
```bash
sudo snap forget 1
``` 
### Вывод:
```text
Snapshot #1 forgotten.
```

## 6. Повторная проверка снимков данных

### Ввод:
```bash
snap saved
``` 
### Вывод:
```text
No snapshots found.
```

## 7. Очистка остаточных директорий и конфигураций

### Ввод:
```bash
rm -rf ~/snap/docker
sudo rm -rf /var/snap/docker
sudo rm -rf /var/lib/docker
```

(Команды выполняются без вывода в терминал)

## 8. Проверка удаления Docker

### Ввод:
```bash
docker --version
``` 
### Вывод:
```text
-bash: /snap/bin/docker: No such file or directory
```

## 9. Проверка удаления Docker Compose

### Ввод:
```bash
docker-compose --version
``` 
### Вывод:
```text
-bash: /snap/bin/docker-compose: No such file or directory
```

## 10. Скриншот удаление Docker, Docker Compose

![Скриншот удаление Docker, Docker Compose](https://github.com/user-attachments/assets/c1e67e86-93db-4b97-ad19-17397c61a94c)

</details>

<details>
  
<summary>
  
# Задание 0.2 (Установка)

</summary>    

## 1. Установка необходимых системных утилит

### Ввод:
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
``` 
### Вывод:
```text
Получено 322 MB за 1мин 6с (4 894 kB/s)
Чтение списков пакетов… Готово

Уже установлен пакет curl самой новой версии (8.5.0-2ubuntu10.9).
Уже установлен пакет gnupg самой новой версии (2.4.4-2ubuntu17.4).
```

## 2. Проверка файла ключа

### Ввод:
```bash
gpg --show-keys /etc/apt/keyrings/docker.gpg
``` 
### Вывод:
```text
gpg: directory '/home/oleg/.gnupg' created
gpg: keybox '/home/oleg/.gnupg/pubring.kbx' created
gpg: can't open '/etc/apt/keyrings/docker.gpg': No such file or directory
```

## 3. Проверка папки для ключей и самого старого ключа (его удаление)

### Ввод:
```bash
ls -l /etc/apt/keyrings/
sudo rm -f /etc/apt/keyrings/docker.gpg
ls -l /etc/apt/keyrings/
``` 
### Вывод:
```text
-rw-r--r-- 1 root root 0 мая 26 12:12 docker.gpg
total 0
```

## 4. Скачиваем текстовый ключ, проверяем наличие ключей

### Ввод:
```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
ls -l /etc/apt/keyrings/
``` 
### Вывод:
```text
-rw-r--r-- 1 root root 3817 мая 26 12:21 docker.asc
-rw-r--r-- 1 root root    0 мая 26 12:20 docker.gpg
```

## 5. Назначаем права, проверяем валидность нового ключа

### Ввод:
```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
gpg --show-keys /etc/apt/keyrings/docker.asc
``` 
### Вывод:
```text
pub   rsa4096 2017-02-22 [SCEA]
      9DC858229FC7DD38854AE2D88D81803C0EBFCD88
uid                      Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

## 6. Подключение официального репозитория Docker, обновляем списки пакетов

### Ввод:
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://docker.com $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
``` 
### Вывод:
```text
Пол:5 https://download.docker.com/linux/ubuntu noble InRelease [48,5 kB]
Сущ:6 https://apt.releases.hashicorp.com noble InRelease
Пол:7 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages [55,7 kB]
Пол:8 https://download.docker.com/linux/ubuntu noble/stable amd64 Contents (deb) [1 539 B]
Получено 106 kB за 2с (70,3 kB/s)
```

## 7. Установка Docker и современного Docker Compose v2, проверка итоговой версии

### Ввод:
```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker-compose --version
docker compose version
``` 
### Вывод:
```text
Пол:5 https://download.docker.com/linux/ubuntu noble InRelease [48,5 kB]
Сущ:6 https://apt.releases.hashicorp.com noble InRelease
Пол:7 https://download.docker.com/linux/ubuntu noble/stable amd64 Packages [55,7 kB]
Пол:8 https://download.docker.com/linux/ubuntu noble/stable amd64 Contents (deb) [1 539 B]
Получено 106 kB за 2с (70,3 kB/s)
Command 'docker-compose' not found, but can be installed with:
sudo snap install docker          # version 29.3.1, or
sudo apt  install docker-compose  # version 1.29.2-6
See 'snap info docker' for additional versions.
Docker Compose version v5.1.4
```

## 8. Скриншот вывод версий Docker Compose
![Скриншот вывод версий Docker Compose](https://github.com/user-attachments/assets/eee10674-e9b5-4b95-8489-5935832a1f4d)

</details>

<details>
  
<summary>
  
# Задание 1 

</summary>    

## 1. Делаю в своем GitHub пространстве fork репозитория.

![Делаю в своем GitHub пространстве fork репозитория](https://github.com/user-attachments/assets/e9d39aa6-6327-4e48-8120-e8d226d94360)

## 2. Создаю файл Dockerfile.python на основе существующего Dockerfile и .dockerignore

```text
.git
.gitignore
__pycache__/
*.pyc
*.pyo
*.pyd
.env
venv/
.venv
env/
```
### Скриншот из Github
![Скриншот из Github](https://github.com/user-attachments/assets/61f0914c-755a-4b64-a9da-0b3c363aa99f)


Склонируйте ваш репозиторий по корректной ссылке
git clone https://github.com/olegkomel1-del/shvirtd-example-python/
Cloning into 'shvirtd-example-python'...
remote: Enumerating objects: 85, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 85 (delta 1), reused 0 (delta 0), pack-reused 79 (from 1)
Receiving objects: 100% (85/85), 59.93 KiB | 222.00 KiB/s, done.
Resolving deltas: 100% (22/22), done.

Проверяем наличие файлов
ls -l
drwxrwxr-x 2 oleg oleg 4096 мая 26 13:17 shvirtd-example-python

cd shvirtd-example-python/
ls -l
-rw-rw-r-- 1 oleg oleg   241 мая 26 13:25 Dockerfile
-rw-rw-r-- 1 oleg oleg   550 мая 26 13:25 Dockerfile.python
drwxrwxr-x 3 oleg oleg  4096 мая 26 13:25 haproxy
-rw-rw-r-- 1 oleg oleg  1036 мая 26 13:25 LICENSE
-rw-rw-r-- 1 oleg oleg  7030 мая 26 13:25 main.py
drwxrwxr-x 3 oleg oleg  4096 мая 26 13:25 nginx
-rw-rw-r-- 1 oleg oleg   567 мая 26 13:25 proxy.yaml
-rw-rw-r-- 1 oleg oleg  4093 мая 26 13:25 README.md
-rw-rw-r-- 1 oleg oleg    73 мая 26 13:25 requirements.txt
-rw-rw-r-- 1 oleg oleg 39767 мая 26 13:25 schema.pdf

Тестирование корректности сборки многоэтапного Dockerfile.python
docker build -f Dockerfile.python -t my-python-app:latest .
[+] Building 88.1s (13/13) FINISHED                                                                      docker:default
 => [internal] load build definition from Dockerfile.python                                                        0.1s
 => => transferring dockerfile: 596B                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                3.2s
 => [internal] load .dockerignore                                                                                  0.1s
 => => transferring context: 109B                                                                                  0.0s
 => [internal] load build context                                                                                  0.1s
 => => transferring context: 55.44kB                                                                               0.0s
 => [builder 1/5] FROM docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d289  6.6s
 => [builder 2/5] WORKDIR /app                                                                                     0.5s
 => [builder 3/5] RUN apt-get update && apt-get install -y --no-install-recommends     build-essential     && rm  42.1s
 => [builder 4/5] COPY requirements.txt .                                                                          0.3s
 => [builder 5/5] RUN pip install --no-cache-dir --user -r requirements.txt                                       21.7s
 => [runner 3/5] COPY --from=builder /root/.local /root/.local                                                     0.9s
 => [runner 4/5] COPY --from=builder /app /app                                                                     0.1s
 => [runner 5/5] COPY . .                                                                                          0.1s
 => exporting to image                                                                                            10.5s
 => => naming to docker.io/library/my-python-app:latest                                                            0.0s
 




</details>
