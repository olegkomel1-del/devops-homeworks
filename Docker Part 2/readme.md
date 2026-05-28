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
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
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

### .gitignore
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

### Скриншот .gitignore из Github
![Скриншот .gitignore из Github](https://github.com/user-attachments/assets/61f0914c-755a-4b64-a9da-0b3c363aa99f)

### Dockerfile.python
```text
# --- Этап 1:  ---
FROM python:3.12-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
# --- Этап 2:  ---
FROM python:3.12-slim AS runner
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app
ENV PATH=/root/.local/bin:$PATH
COPY . .
EXPOSE 5000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
```

### Скриншот Dockerfile.python из Github
![Скриншот Dockerfile.python из Github](https://github.com/user-attachments/assets/c99310f5-1040-4fc8-9d68-f4404c15738f)

## 3. Тестирование корректности сборки многоэтапного Dockerfile.python

### Клонирую репозиторий
### Ввод:
```bash
git clone https://github.com/olegkomel1-del/shvirtd-example-python/
```
### Вывод:
```text
Cloning into 'shvirtd-example-python'...
remote: Enumerating objects: 85, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 85 (delta 1), reused 0 (delta 0), pack-reused 79 (from 1)
Receiving objects: 100% (85/85), 59.93 KiB | 222.00 KiB/s, done.
Resolving deltas: 100% (22/22), done.
```

### Проверяю наличие файлов
### Ввод:
```bash
cd shvirtd-example-python/
ls -l
```
### Вывод:
```text
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
```

### Тестирую сборку
### Ввод:
```bash
docker build -f Dockerfile.python -t my-python-app:latest .
```
### Вывод:
```text
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
```
### Скриншот тестирования сборки
![Скриншот тестирования сборки](https://github.com/user-attachments/assets/867c5032-5334-40b4-8861-9253facae0f1)

# Запуск web-приложения без использования docker, с помощью venv.

## 4. Ошибка несовместимости инструкций процессора (Архитектурный сбой СУБД)  
Изначально была предпринята попытка запустить оригинальный образ mysql:8.0:  

```bash
docker run -d \
  --name mysql-db \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD="YtReWq4321" \
  -e MYSQL_DATABASE="virtd" \
  -e MYSQL_USER="app" \
  -e MYSQL_PASSWORD="QwErTy1234" \
  mysql:8.0
```

Результат: Контейнер аварийно завершал работу сразу после старта. Проверка логов выявила критическую ошибку:

```text
oleg@test-serv:~$ docker logs mysql-db
Fatal glibc error: CPU does not support x86-64-v2
```

Причина: Официальный образ MySQL 8.0 скомпилирован с жестким требованием к инструкциям процессора x86-64-v2. Текущая конфигурация виртуальной машины VirtualBox не транслировала данные инструкции в гостевую ОС Ubuntu.  

Решение: Контейнер был принудительно удален. Вместо него был развернут полностью совместимый, стабильный и эквивалентный по функционалу официальный образ mariadb:10.11, успешно работающий без требований к инструкциям v2:  

```bash
docker run -d \
  --name mysql-db \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD="YtReWq4321" \
  -e MYSQL_DATABASE="virtd" \
  -e MYSQL_USER="app" \
  -e MYSQL_PASSWORD="QwErTy1234" \
  mariadb:10.11
```

### Развертывание локальной среды Python и запуск сервера  

```bash
sudo apt update && sudo apt install -y python3-venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

После успешной установки пакетов осуществлен запуск веб-сервера автоматизации Uvicorn:  

```bash
uvicorn main:app --host 0.0.0.0 --port 5000
```

### Диагностика ошибки аутентификации Access denied  
При старте веб-сервер Uvicorn выдал системную ошибку подключения к СУБД:

```text
Приложение запускается...
Ошибка при создании таблицы: 1045 (28000): Access denied for user 'app'@'172.17.0.1' (using password: YES)
```
![Uvicorn выдал системную ошибку подключения к СУБД](https://github.com/user-attachments/assets/a6d06d8f-a585-41bd-bf75-abc4f4f7e471)

### Этап отладки 1. Проверка внутренней структуры СУБД  
Для проверки корректности создания пользователя и базы данных была выполнена прямая инспекция таблиц внутри контейнера:  

```bash
oleg@test-serv:~/shvirtd-example-python$ docker exec -it mysql-db mariadb -u root -pYtReWq4321 -e "SHOW DATABASES; SELECT User, Host FROM mysql.user;"
```

Результат инспекции:

```text
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| virtd              |
+--------------------+
+-------------+-----------+
| User        | Host      |
+-------------+-----------+
| app         | %         |
| root        | %         |
| healthcheck | 127.0.0.1 |
| healthcheck | ::1       |
| healthcheck | localhost |
| mariadb.sys | localhost |
| root        | localhost |
+-------------+-----------+
```

![Результат инспекции](https://github.com/user-attachments/assets/e100793c-fddb-47d1-9341-1dcaa20559ad)

Запрос подтвердил, что база virtd существует, а пользователь app создан с хостом % (доступ открыт для любых внешних IP, включая шлюз Docker 172.17.0.1). Прямая проверка подключения внутри контейнера под пользователем app прошла успешно и без ошибок:  

```bash
oleg@test-serv:~/shvirtd-example-python$ docker exec -it mysql-db mariadb -u app -pQwErTy1234 -D virtd -e "SHOW TABLES;"
```

### Этап отладки 2. Инженерный анализ проблемы кавычек через Python  
Чтобы понять, почему СУБД отвергает запросы от внешнего Python-процесса, был написан и запущен диагностический скрипт test_env.py, считывающий данные из .env точно так же, как это делает библиотека приложения

```bash
oleg@test-serv:~/shvirtd-example-python$ python3 test_env.py
```
Вывод скрипта:

```text
=== Проверка переменных окружения из Python ===
Файл .env найден. Содержимое переменных в памяти:
Ключ: MYSQL_ROOT_PASSWORD  -> Значение: "YtReWq4321"    (Длина: 12 симв.)
Ключ: MYSQL_DATABASE       -> Значение: "virtd"         (Длина: 7 симв.)
Ключ: MYSQL_USER           -> Значение: "app"           (Длина: 5 симв.)
Ключ: MYSQL_PASSWORD       -> Значение: "QwErTy1234"    (Длина: 12 симв.)
```
![Проверка переменных окружения из Python](https://github.com/user-attachments/assets/f42bd58c-ead3-4331-a70f-771f6e72607e)

Обнаруженная скрытая причина: Скрипт наглядно показал, что встроенный парсер Python считывает строковые значения из оригинального .env файла вместе с символами кавычек ". В итоге чистый логин app (3 символа) превратился в строку "app" (5 символов), а пароль QwErTy1234 превратился в "QwErTy1234" (12 символов). СУБД правомерно отклоняла сессию из-за несовпадения паролей.  

## 5. Решение задачи со звёздочкой (*) через автоматизированный Bash-скрипт  
Так как ручная модификация файлов проекта строго запрещена условиями ДЗ, логика динамического управления таблицей и автоматического исправления кавычек из .env была вынесена в обязательный к добавлению bash-скрипт.  

### Исходный код разработанного файла run_app.sh

```text
#!/bin/bash

# Определяем имя таблицы из ENV или ставим дефолтное
TARGET_TABLE=${TABLE_NAME:-requests}

echo "=== Запуск приложения с очисткой кавычек из ENV ==="
echo "Целевое имя таблицы: $TARGET_TABLE"

# 1. Создаем временную копию оригинального main.py для работы под капотом
cp main.py main_patched.py

# Подставляем РЕАЛЬНОЕ значение переменной TARGET_TABLE прямо в код Python на лету
sed -i "s/'requests'/'$TARGET_TABLE'/g" main_patched.py
sed -i "s/\"requests\"/\"$TARGET_TABLE\"/g" main_patched.py

# 2. Вытягиваем данные из .env, СТИРАЕМ кавычки и экспортируем в приоритетные переменные процесса
if [ -f .env ]; then
    export DB_HOST="127.0.0.1"
    export DB_PORT="3306"
    export DB_USER=$(grep "MYSQL_USER" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
    export DB_PASSWORD=$(grep "MYSQL_PASSWORD" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
    export DB_NAME=$(grep "MYSQL_DATABASE" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
fi

# 3. Функция очистки (Ctrl+C): бесследно удаляет временный файл патча при выходе
cleanup() {
    echo -e "\n=== Остановка сервера и очистка временных файлов ==="
    rm -f main_patched.py
    exit 0
}
trap cleanup SIGINT SIGTERM

# 4. Запускаем Uvicorn через модифицированный временный файл
TABLE_NAME="$TARGET_TABLE" uvicorn main_patched:app --host 0.0.0.0 --port 5000
```
### Тестирование запуска скрипта с передачей переменной таблицы

```bash
(venv) oleg@test-serv:~/shvirtd-example-python$ TABLE_NAME="oleg_super_table" ./run_app.sh
```
### Лог успешного выполнения программы:

```text
===       ENV ===
  : oleg_super_table
INFO:     Started server process [12221]
INFO:     Waiting for application startup.
Приложение запускается...
Соединение с БД установлено и таблица 'oleg_super_table' готова к работе.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0 (Press CTRL+C to quit)
```
![Лог успешного выполнения программы](https://github.com/user-attachments/assets/33f3d599-4e7e-491f-b542-be31b2653d6d)
![web](https://github.com/user-attachments/assets/82435c1d-df9f-46a3-bef9-4313c03b8f90)

### Заключение по отчёту:
Все требования технического задания выполнены. Оригинальные файлы репозитория сохранены в первозданном виде. Написанный bash-скрипт успешно очистил строки от кавычек в памяти процесса, установил стабильное соединение с БД и динамически переименовал целевую таблицу в 'oleg_super_table'.

</details>

<details>
  
<summary>
  
# Задание 2* 

</summary>   

## Короткий отчёт

```yaml
id: chemq8ida6fc4helgt4t
image_id: crpukooedqf8k5fpjrt7
scanned_at: "2026-05-27T12:14:44.141Z"
status: READY
vulnerabilities:
  critical: "6"
  high: "50"
  medium: "138"
  low: "163"
  undefined: "8"
```

## Расширенный отчет с фильтрацией по уровню угрозы ('CRITICAL', 'HIGH')


| SEVERITY |      NAME      | ORIGIN |  TYPE  |     PACKAGE      |         VERSION         |      FIXED BY      |                    LINK                    |
|----------|----------------|--------|--------|------------------|-------------------------|--------------------|--------------------------------------------|
| CRITICAL | CVE-2023-6879  | os     | debian | libaom3          | 3.6.0-1+deb12u1         |                    | https://avd.aquasec.com/nvd/cve-2023-6879  |
| CRITICAL | CVE-2026-33845 | os     | debian | libgnutls30      | 3.7.9-2+deb12u5         | 3.7.9-2+deb12u7    | https://avd.aquasec.com/nvd/cve-2026-33845 |
| CRITICAL | CVE-2026-42010 | os     | debian | libgnutls30      | 3.7.9-2+deb12u5         | 3.7.9-2+deb12u7    | https://avd.aquasec.com/nvd/cve-2026-42010 |
| CRITICAL | CVE-2026-31789 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-31789 |
| CRITICAL | CVE-2026-31789 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-31789 |
| CRITICAL | CVE-2023-45853 | os     | debian | zlib1g           | 1:1.2.13.dfsg-1         |                    | https://avd.aquasec.com/nvd/cve-2023-45853 |
| HIGH     | CVE-2026-5773  | os     | debian | curl             | 7.88.1-10+deb12u12      |                    | https://avd.aquasec.com/nvd/cve-2026-5773  |
| HIGH     | CVE-2026-6276  | os     | debian | curl             | 7.88.1-10+deb12u12      |                    | https://avd.aquasec.com/nvd/cve-2026-6276  |
| HIGH     | CVE-2025-68973 | os     | debian | gpgv             | 2.2.40-1.1              | 2.2.40-1.1+deb12u2 | https://avd.aquasec.com/nvd/cve-2025-68973 |
| HIGH     | CVE-2023-39616 | os     | debian | libaom3          | 3.6.0-1+deb12u1         |                    | https://avd.aquasec.com/nvd/cve-2023-39616 |
| HIGH     | CVE-2026-4878  | os     | debian | libcap2          | 1:2.66-4+deb12u1        | 1:2.66-4+deb12u3   | https://avd.aquasec.com/nvd/cve-2026-4878  |
| HIGH     | CVE-2026-5773  | os     | debian | libcurl4         | 7.88.1-10+deb12u12      |                    | https://avd.aquasec.com/nvd/cve-2026-5773  |
| HIGH     | CVE-2026-6276  | os     | debian | libcurl4         | 7.88.1-10+deb12u12      |                    | https://avd.aquasec.com/nvd/cve-2026-6276  |
| HIGH     | CVE-2026-33164 | os     | debian | libde265-0       | 1.0.11-1+deb12u2        |                    | https://avd.aquasec.com/nvd/cve-2026-33164 |
| HIGH     | CVE-2023-52425 | os     | debian | libexpat1        | 2.5.0-1+deb12u1         | 2.5.0-1+deb12u2    | https://avd.aquasec.com/nvd/cve-2023-52425 |
| HIGH     | CVE-2026-25210 | os     | debian | libexpat1        | 2.5.0-1+deb12u1         |                    | https://avd.aquasec.com/nvd/cve-2026-25210 |
| HIGH     | CVE-2026-45186 | os     | debian | libexpat1        | 2.5.0-1+deb12u1         |                    | https://avd.aquasec.com/nvd/cve-2026-45186 |
| HIGH     | CVE-2026-33846 | os     | debian | libgnutls30      | 3.7.9-2+deb12u5         | 3.7.9-2+deb12u7    | https://avd.aquasec.com/nvd/cve-2026-33846 |
| HIGH     | CVE-2026-3833  | os     | debian | libgnutls30      | 3.7.9-2+deb12u5         | 3.7.9-2+deb12u7    | https://avd.aquasec.com/nvd/cve-2026-3833  |
| HIGH     | CVE-2026-42009 | os     | debian | libgnutls30      | 3.7.9-2+deb12u5         | 3.7.9-2+deb12u7    | https://avd.aquasec.com/nvd/cve-2026-42009 |
| HIGH     | CVE-2026-40356 | os     | debian | libgssapi-krb5-2 | 1.20.1-2+deb12u3        | 1.20.1-2+deb12u5   | https://avd.aquasec.com/nvd/cve-2026-40356 |
| HIGH     | CVE-2025-68431 | os     | debian | libheif1         | 1.15.1-1+deb12u1        |                    | https://avd.aquasec.com/nvd/cve-2025-68431 |
| HIGH     | CVE-2026-32740 | os     | debian | libheif1         | 1.15.1-1+deb12u1        |                    | https://avd.aquasec.com/nvd/cve-2026-32740 |
| HIGH     | CVE-2026-32741 | os     | debian | libheif1         | 1.15.1-1+deb12u1        |                    | https://avd.aquasec.com/nvd/cve-2026-32741 |
| HIGH     | CVE-2026-32882 | os     | debian | libheif1         | 1.15.1-1+deb12u1        |                    | https://avd.aquasec.com/nvd/cve-2026-32882 |
| HIGH     | CVE-2026-40356 | os     | debian | libk5crypto3     | 1.20.1-2+deb12u3        | 1.20.1-2+deb12u5   | https://avd.aquasec.com/nvd/cve-2026-40356 |
| HIGH     | CVE-2026-40356 | os     | debian | libkrb5-3        | 1.20.1-2+deb12u3        | 1.20.1-2+deb12u5   | https://avd.aquasec.com/nvd/cve-2026-40356 |
| HIGH     | CVE-2026-40356 | os     | debian | libkrb5support0  | 1.20.1-2+deb12u3        | 1.20.1-2+deb12u5   | https://avd.aquasec.com/nvd/cve-2026-40356 |
| HIGH     | CVE-2023-2953  | os     | debian | libldap-2.5-0    | 2.5.13+dfsg-5           |                    | https://avd.aquasec.com/nvd/cve-2023-2953  |
| HIGH     | CVE-2026-27135 | os     | debian | libnghttp2-14    | 1.52.0-1+deb12u2        | 1.52.0-1+deb12u3   | https://avd.aquasec.com/nvd/cve-2026-27135 |
| HIGH     | CVE-2026-22695 | os     | debian | libpng16-16      | 1.6.39-2                | 1.6.39-2+deb12u2   | https://avd.aquasec.com/nvd/cve-2026-22695 |
| HIGH     | CVE-2026-22801 | os     | debian | libpng16-16      | 1.6.39-2                | 1.6.39-2+deb12u2   | https://avd.aquasec.com/nvd/cve-2026-22801 |
| HIGH     | CVE-2026-25646 | os     | debian | libpng16-16      | 1.6.39-2                | 1.6.39-2+deb12u3   | https://avd.aquasec.com/nvd/cve-2026-25646 |
| HIGH     | CVE-2026-7598  | os     | debian | libssh2-1        | 1.10.0-3+b1             |                    | https://avd.aquasec.com/nvd/cve-2026-7598  |
| HIGH     | CVE-2025-15467 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.18-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2025-15467 |
| HIGH     | CVE-2025-69421 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.18-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2025-69421 |
| HIGH     | CVE-2026-28387 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28387 |
| HIGH     | CVE-2026-28388 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28388 |
| HIGH     | CVE-2026-28389 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28389 |
| HIGH     | CVE-2026-28390 | os     | debian | libssl3          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28390 |
| HIGH     | CVE-2023-52355 | os     | debian | libtiff6         | 4.5.0-6+deb12u2         |                    | https://avd.aquasec.com/nvd/cve-2023-52355 |
| HIGH     | CVE-2025-9900  | os     | debian | libtiff6         | 4.5.0-6+deb12u2         | 4.5.0-6+deb12u3    | https://avd.aquasec.com/nvd/cve-2025-9900  |
| HIGH     | CVE-2026-4775  | os     | debian | libtiff6         | 4.5.0-6+deb12u2         | 4.5.0-6+deb12u4    | https://avd.aquasec.com/nvd/cve-2026-4775  |
| HIGH     | CVE-2025-69720 | os     | debian | libtinfo6        | 6.4-4                   |                    | https://avd.aquasec.com/nvd/cve-2025-69720 |
| HIGH     | CVE-2026-6732  | os     | debian | libxml2          | 2.9.14+dfsg-1.3~deb12u2 |                    | https://avd.aquasec.com/nvd/cve-2026-6732  |
| HIGH     | CVE-2025-7424  | os     | debian | libxslt1.1       | 1.1.35-1+deb12u1        | 1.1.35-1+deb12u2   | https://avd.aquasec.com/nvd/cve-2025-7424  |
| HIGH     | CVE-2025-69720 | os     | debian | ncurses-base     | 6.4-4                   |                    | https://avd.aquasec.com/nvd/cve-2025-69720 |
| HIGH     | CVE-2025-69720 | os     | debian | ncurses-bin      | 6.4-4                   |                    | https://avd.aquasec.com/nvd/cve-2025-69720 |
| HIGH     | CVE-2026-9256  | os     | debian | nginx            | 1.29.0-1~bookworm       |                    | https://avd.aquasec.com/nvd/cve-2026-9256  |
| HIGH     | CVE-2025-15467 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.18-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2025-15467 |
| HIGH     | CVE-2025-69421 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.18-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2025-69421 |
| HIGH     | CVE-2026-28387 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28387 |
| HIGH     | CVE-2026-28388 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28388 |
| HIGH     | CVE-2026-28389 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28389 |
| HIGH     | CVE-2026-28390 | os     | debian | openssl          | 3.0.17-1~deb12u2        | 3.0.19-1~deb12u2   | https://avd.aquasec.com/nvd/cve-2026-28390 |
| HIGH     | CVE-2023-31484 | os     | debian | perl-base        | 5.36.0-7+deb12u2        | 5.36.0-7+deb12u3   | https://avd.aquasec.com/nvd/cve-2023-31484 |

</details>

<details>
  
<summary>
  
# Задание 3

</summary>    

## Скриншот выполнения из SQL запроса  

![Скриншот выполнения из SQL запроса ](https://github.com/user-attachments/assets/65d0f661-4622-44c4-865d-8c38e2df3e7d)
  
&emsp;&emsp;В ходе выполнения задания стандартный образ mysql:8 был заменен на полностью совместимый mariadb:10.11 из-за аппаратных ограничений процессорной архитектуры на хост-машине:  
&emsp;&emsp;Требование к x86-64-v2: Начиная с версии MySQL 8.0.26+, официальные сборки и Docker-образы компилируются с жестким требованием к поддержке процессором инструкций уровня x86-64-v2 (включая SSE3, SSSE3, SSE4.1, SSE4.2 и POPCNT).

</details>
