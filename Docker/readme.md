# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»  

## Задача 1  

  **Ссылка на Docker контейнер:** [custom-nginx на Docker Hub](https://hub.docker.com/repository/docker/komel0leg/custom-nginx/tags/general-1.0.0/sha256:f051d8c69b43d3242ad25983ab1ba855d5cf8c1029d3ff71b337ac1984c911df)  

  Команда для pull контейнера:  
  ```bash  
  docker pull komel0leg/custom-nginx:general-1.0.0
```

## Задача 2  

### 1. Запуск контейнера с длинным именем
**Ввод:**
```bash
docker run -d --name Komel-Oleg-Mihailovich-custom-nginx-t2 -p 127.0.0.1:8080:80 custom_nginx:latest
```
**Вывод:**
```text
5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5
```

### 2. Переименование контейнера
**Ввод:**
```bash
docker rename Komel-Oleg-Mihailovich-custom-nginx-t2 custom-nginx-t2
```
*(Команда выполняется в фоне, вывод в консоль отсутствует)*

### 3. Проверка статуса, сетевых портов и логов контейнера
**Ввод:**
```bash
date +"%d-%m-%Y %H:%M:%S" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
```
**Вывод:**
```text
16.05.2026 02:35:26.909368078 UTC
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS                    NAMES
5241a0d49f50   custom_nginx:latest   "/docker-entrypoint.…"   About a minute   Up About a minute   127.0.0.1:8080->80/tcp   custom-nginx-t2
LISTEN 0      4096       127.0.0.1:8080       0.0.0.0:*
2026/05/16 02:34:09 [notice] 1#1: start worker process 29
PGh0bWw+CjxoZWFlPmdpcFZXkXSTFSlDGlG0Sb2d5CjwvYWdhVzD4KP6JVzHk+CjVxMTSJ1HdpbGwgYWU9
```

### 4. Проверка доступности веб-сервера через curl
**Ввод:**
```bash
curl -I http://127.0.0.1:8080
```
**Вывод:**
```text
HTTP/1.1 200 OK
Server: nginx/1.29.0
Date: Sat, 16 May 2026 02:36:00 GMT
Content-Type: text/html
Content-Length: 95
Last-Modified: Sat, 16 May 2026 01:29:46 GMT
Connection: keep-alive
ETag: "6a07c88a-5f"
Accept-Ranges: bytes
```
<details>
<summary>📸 Посмотреть полный скриншот из консоли для 2 задачи</summary>  

![Скриншот по второй задачи](https://github.com/user-attachments/assets/98da4add-11ba-47b7-a40f-3ffcf8d37053)  

</details>

## Задача 3  

### 1. Остановка, запуск и вход внутрь контейнера
**Ввод:**
```bash
docker attach custom-nginx-t2
# (После нажатия Ctrl+C для выхода и остановки контейнера)
docker ps -a
docker start custom-nginx-t2
docker exec -it custom-nginx-t2 bash
```
**Вывод:**
```text
2026/05/16 03:09:28 [notice] 1#1: signal 2 (SIGINT) received, exiting
2026/05/16 03:09:28 [notice] 29#29: exiting
2026/05/16 03:09:29: exit
2026/05/16 03:09:28 [notice] 1#1: signal 17 (SIGCHLD) received from 29
2026/05/16 03:09:28 [notice] 1#1: worker process 29 exited with code 0
2026/05/16 03:09:29 [notice] 1#1: exit

CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS                       PORTS     NAMES
5241a0d49f50   custom_nginx:latest   "/docker-entrypoint.…"   35 minutes ago   Exited (0) 15 seconds ago              custom-nginx-t2
496a78e68e8b   custom_nginx          "/docker-entrypoint.…"   About an hour ago Exited (137) 38 minutes ago           general
7d5afcc978d0   ubuntu:20.04          "/bin/bash"              9 days ago       Exited (0) 9 days ago                  vagrant_docker_test_default_1778074530

custom-nginx-t2
root@5241a0d49f50:/usr/share/nginx/html#
```

### 2. Обновление пакетов и установка редактора nano внутри контейнера
**Ввод:**
```bash
apt-get update && apt-get install -y nano
```
**Вывод:**
```text
Get:1 http://debian.org bookworm InRelease [151 kB]
...
The following NEW packages will be installed:
  libgpm2 libncursesw6 nano
0 upgraded, 3 newly installed, 0 to remove and 38 not upgraded.
Need to get 838 kB of archives.
...
Setting up nano (7.2-1+deb12u1) ...
update-alternatives: using /bin/nano to provide /usr/bin/editor (editor) in auto mode
```

### 3. Изменение конфигурации Nginx и проверка доступности
**Ввод:**
```bash
nano /etc/nginx/conf.d/default.conf
nginx -s reload
curl http://127.0.0.1:80
```
**Вывод:**
```text
2026/05/16 03:13:22 [notice] 174#174: signal process started
curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Couldn't connect to server
```

<details>
<summary>📸 Посмотреть полный скриншот выполнения шага 1</summary>  
 
![Скриншот 1 части 3 задачи](https://github.com/user-attachments/assets/1aeaf3bf-eb46-4490-a454-869151b70bf9) 

</details>  

> [!NOTE]
> **Объяснение:** Контейнер остановился, потому что команда `docker attach` привязывает ваш терминал к основному процессу внутри контейнера, которым является Nginx. Когда мы нажали `Ctrl + C`, мы прервали главный процесс. Так как в Docker контейнер живет ровно столько, сколько живет его основной процесс, завершение Nginx привело к немедленной остановке всего контейнера.

### 4. Редактирование конфигурационного файла Nginx
Изменил порт в файле конфигурации `/etc/nginx/conf.d/default.conf` через редактор `nano` на порт `81`:

```nginx
server {
    listen       81;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
### 5. Проверка доступности Nginx на новом порту

**Ввод (внутри контейнера):**
```bash
curl http://127.0.0.1:81
exit
```
**Вывод:**
```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```

### 6. Проверка проброса портов с хост-машины

**Ввод (на хост-системе):**
```bash
ss -tlpn | grep 127.0.0.1:8080
docker port custom-nginx-t2
curl http://127.0.0.1:8080
```
**Вывод:**
```text
LISTEN 0      4096       127.0.0.1:8080       0.0.0.0:*
80/tcp -> 127.0.0.1:8080
curl: (52) Empty reply from server
```

> [!WARNING]
> **Причина ошибки (Empty reply from server):** Запрос `curl` на хосте завершился ошибкой, так как при старте контейнера был настроен маппинг портов `8080:80`. После того как внутри контейнера в конфигурации Nginx порт был изменен с `80` на `81`, трафик с хоста (порт 8080) переправляется на порт 80 контейнера, который теперь никто не слушает.

<details>
<summary>📸 Посмотреть полный скриншот тестов портов и curl</summary>

![Скриншот тестов портов и curl](https://github.com/user-attachments/assets/53b35063-6977-4f7f-8d10-a1adb18a3def)

</details>

## Пункт 11*  

### 7. Остановка контейнера и попытка остановки демона Docker

**Ввод:**
```bash
docker stop custom-nginx-t2
sudo systemctl stop docker
```
**Вывод:**
```text
custom-nginx-t2
Failed to stop docker.service: Unit docker.service not loaded.
```

> [!WARNING]
> **Важное примечание:** На данном этапе я не придал значения ошибке `Unit docker.service not loaded`. Демон Docker не был остановлен стандартным системным диспетчером, что в дальнейшем привело к проблемам с выполнением следующих заданий.

<details>
<summary>📸 Посмотреть скриншот неудачной остановки демона</summary>

![Cкриншот с ошибками systemctl](https://github.com/user-attachments/assets/509b95b6-ee86-414e-991f-37a56e07438e)

</details>

### 8. Попытка поиска конфигурационного файла контейнера на хосте

**Ввод:**
```bash
docker inspect custom-nginx-t2 | grep Id
sudo nano /var/lib/docker/containers/5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5/config.v2.json
cd /var/lib/docker
```
**Вывод:**
```text
    "Id": "5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5",
-bash: cd: /var/lib/docker: No such file or directory
```

> [!CAUTION]
> **Очередная проблема:** При попытке перейти в директорию `/var/lib/docker` система сообщила, что такого пути не существует. 


<details>
<summary>📸 Посмотреть скриншот ошибки отсутствия директории /var/lib/docker</summary>

![скриншот ошибки отсутствия директории /var/lib/docker</summary](https://github.com/user-attachments/assets/ed08062c-8e3b-4683-beaf-ebcf95e41c27)

</details>

### 9. Глобальный поиск директории контейнера по системе

**Ввод:**
```bash
sudo find / -name "5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5"
```
**Вывод:**
```text
find: warning: the -d option is deprecated; please use -depth instead...
/var/snap/docker/common/var-lib-docker/containers/5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5
/var/snap/docker/common/var-lib-docker/image/overlay2/layerdb/mounts/5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5
```

> [!NOTE]
> **Ход мыслей:** С помощью команды `find` удалось обнаружить реальное расположение конфигурационных файлов контейнера. На тот момент истинная причина (установка Docker через пакетный менеджер Snap) ещё не была очевидна, но целевой путь `/var/snap/docker/...` был успешно найден.

<details>
<summary>📸 Посмотреть скриншот успешного поиска через find</summary>

![Cкриншот консоли с результатами find](https://github.com/user-attachments/assets/78ca173e-2298-4668-b089-ed9296245e84)

</details>

### 10. Редактирование низкоуровневых конфигурационных файлов контейнера

Перешел по найденному Snap-пути и открыл файлы конфигурации контейнера через `nano` для ручного изменения портов:

```bash
cd /var/snap/docker/common/var-lib-docker/containers/5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5
sudo nano config.v2.json
sudo nano hostconfig.json
```

> [!IMPORTANT]
> **Итог редактирования:** Были внесены изменения в порты внутри `hostconfig.json` и `config.v2.json`. В файле `config.v2.json` конфигурацию необходимо было поправить в двух местах, однако удалось применить только в одном. 
> 
> **Причина:** Так как демон Docker не был предварительно остановлен (из-за специфики Snap-пакета), запущенная служба удерживала конфигурацию контейнера в оперативной памяти и динамически перезаписывала JSON-файлы на диске, блокируя ручные изменения.

<details>
<summary>📸 Посмотреть скриншот структуры файлов config.v2.json и hostconfig.json в nano</summary>

![Cкриншот открытого JSON-файла](https://github.com/user-attachments/assets/283bf64a-c56f-49c3-baa1-20a3d78af673)
![Cкриншот открытого JSON-файла](https://github.com/user-attachments/assets/9136916a-169d-4059-a8b6-c2a674979e8d)

</details>

### 11. Запуск контейнера после ручной правки конфигурации

**Ввод:**
```bash
docker start custom-nginx-t2
curl http://127.0.0.1:8080
```
**Вывод:**
```text
custom-nginx-t2
curl: (56) Recv failure: Connection reset by peer
```

> [!CAUTION]
> **Анализ ошибки (Connection reset by peer):** Данная ошибка указывает на то, что сетевой запрос доходит до порта, но соединение принудительно сбрасывается со стороны контейнера. Это прямое следствие частичного изменения файлов конфигурации: из-за того, что демон Docker перезаписал данные в `config.v2.json`, возник рассинхрон в сетевых параметрах контейнера, что сделало его некорректно работающим. После этого я приступил к детальному поиску причин сбоя.

<details>
<summary>📸 Посмотреть скриншот ошибки Connection reset by peer</summary>

![Скриншот с выводом curl (56)](https://github.com/user-attachments/assets/189ba553-7b0a-4a63-a3b6-49a23ddbe141)

</details>

### 12. Финальная проверка состояния и маппинга портов

**Ввод:**
```bash
docker exec -it custom-nginx-t2 curl http://127.0.0.1:81
docker port custom-nginx-t2
```
**Вывод:**
```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
80/tcp -> 127.0.0.1:8080
```

> [!NOTE]
> **Итоговый вывод :**  Веб-сервер внутри контейнера успешно отвечает на порту `81`. Однако привязать к нему внешний порт хост-машины через прямое редактирование конфигурационных файлов `config.v2.json` и `hostconfig.json` не удалось, так как работающий в фоне демон Snap-Docker перезаписал конфигурацию обратно на исходную (`80/tcp -> 127.0.0.1:8080`). Для успешного применения таких изменений требуется полная остановка службы Docker (в данном случае через `sudo snap stop docker`).

<details>
<summary>📸 Посмотреть скриншот финальной проверки портов</summary>

![Cкриншот с тестом curl и docker port](https://github.com/user-attachments/assets/52f019f9-da15-493f-ae5b-6f8a0e5d09f7)

</details>

### 13. Успешное исправление конфигурации при остановленном демоне Snap-Docker

**Ход решения проблемы:**
1. Полностью остановил службу Docker, управляемую пакетным менеджером Snap.
2. Внес изменения в файлы конфигурации `hostconfig.json` и `config.v2.json` (теперь в `config.v2.json` были успешно изменены оба упоминания старого порта).
3. Запустил службу Docker обратно и проверил доступность веб-сервера с хост-машины.

**Ввод:**
```bash
sudo snap stop docker
sudo nano /var/snap/docker/common/var-lib-docker/containers/5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5/config.v2.json
sudo nano /var/snap/docker/common/var-lib-docker/containers/5241a0d49f50c91d518d1e15fb2252d57a551f1f8bd5b7552cde152a404c41d5/hostconfig.json
sudo snap start docker
docker start custom-nginx-t2
curl http://127.0.0.1:8080
```
**Вывод:**
```text
2026-05-16T11:40:48Z INFO Waiting for "snap.docker.dockerd.service" to stop.
Stopped.
Started.
custom-nginx-t2
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```

> [!NOTE]
> **Итог:** После корректной остановки демона изменения портов успешно применились. Теперь внешний порт хост-машины `8080` корректно пробрасывается на измененный внутренний порт контейнера `81`, а веб-сервер Nginx успешно отдает приветственную страницу. Пункт 11* полностью решён.

<details>
<summary>📸 Посмотреть скриншот успешного применения конфигурации и проверки curl</summary>

![Финальный скриншот](https://github.com/user-attachments/assets/5e06a134-10da-431a-8a6d-5071abac20fe)

</details>

### 14. Очистка ресурсов после выполнения работы

После успешной проверки работы контейнера и отладки сетевых портов, удалил развернутый контейнер методом принудительного удаления (без предварительной остановки):

**Ввод:**
```bash
docker rm -f custom-nginx-t2
docker ps
```
**Вывод:**
```text
custom-nginx-t2
```
*(Вывод `docker ps` пуст, так как запущенных контейнеров не осталось)*

<details>
<summary>📸 Посмотреть скриншот удаления контейнера</summary>

![Скриншот удаления](https://github.com/user-attachments/assets/682e6dcd-95b8-4d3f-9215-20977c43015f)

</details>

## Задача 4

Работа с общими томами данных (Docker Volumes) между хост-системой и контейнерами CentOS и Debian.

### 1. Попытка запуска контейнера CentOS и исправление тега образа
**Ввод:**
```bash
docker run -d --name centos-container -v $(pwd):/data centos sleep infinity
# (После ошибки отсутствия манифеста latest)
docker run -d --name centos-container -v $(pwd):/data centos:7 sleep infinity
```
**Вывод:**
```text
Unable to find image 'centos:latest' locally
docker: Error response from daemon: manifest for centos:latest not found: manifest unknown: manifest unknown
...
7: Pulling from library/centos
Digest: sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d32916d6487418ea4
Status: Downloaded newer image for centos:7
e5685816243658b951773057354df0f404f8941bb03e75bddd101b40b5376f72
```

### 2. Запуск контейнера Debian и проверка работающих сред
**Ввод:**
```bash
docker run -d --name debian-container -v $(pwd):/data debian sleep infinity
docker ps
```
**Вывод:**
```text
CONTAINER ID   IMAGE      COMMAND            CREATED          STATUS          PORTS     NAMES
15e6adbeb369   debian     "sleep infinity"   5 seconds ago    Up 4 seconds              debian-container
e56858162436   centos:7   "sleep infinity"   43 seconds ago   Up 42 seconds             centos-container
```

### 3. Запись данных в файлы из контейнера и хост-машины
**Ввод:**
```bash
docker exec -it centos-container sh -c "echo 'Hello from CentOS' > /data/file1.txt"
echo "Hello from Host" > file2.txt
```
*(Файлы создаются в общей смонтированной директории `$(pwd)` хоста и `/data` контейнеров)*

### 4. Чтение и проверка общих данных из контейнера Debian
**Ввод:**
```bash
docker exec -it debian-container sh -c "ls -la /data && cat /data/file1.txt && cat /data/file2.txt"
```
**Вывод:**
```text
total 84
drwxr-x--- 11 1000 1000 4096 May 16 12:36 .
drwxr-xr-x  1 root root 4096 May 16 12:35 ..
-rw-r--r--  1 root root   18 May 16 12:36 file1.txt
-rw-r--r--  1 1000 1000   16 May 16 12:36 file2.txt
...
Hello from CentOS
Hello from Host
```

> [!NOTE]
> **Вывод по эксперименту:** Контейнер Debian успешно видит и читает файлы `file1.txt` (созданный внутри CentOS) и `file2.txt` (созданный на хосте). Это подтверждает корректную работу сквозного монтирования папки хоста `$(pwd)` в изолированные директории `/data` обоих контейнеров.

### 5. Принудительное удаление контейнеров и очистка созданных файлов
**Ввод:**
```bash
docker rm -f centos-container debian-container && rm file1.txt file2.txt
# (Дополнительное ручное удаление остатков файлов при необходимости)
rm file1.txt
docker ps
ls
```
**Вывод:**
```text
centos-container
debian-container
rm: remove write-protected regular file 'file1.txt'? y
```

<details>
<summary>📸 Посмотреть полный скриншот выполнения Задачи 4</summary>

![Финальный скриншот](https://github.com/user-attachments/assets/99c350c2-d451-4bc8-be7c-bf6deb3ecef2)

</details>

## Задача 5

### 1. Подготовка рабочей директории и траблшутинг путей
**Ввод:**
```bash
mkdir -p /tmp/netology/docker/task5
cd /tmp/netology/docker/task5
nano compose.yaml
nano docker-compose.yaml
docker compose up -d
ls
# (После ошибки отсутствия конфигурационного файла переносим проект в домашнюю директорию)
mkdir -p ~/netology/docker/task5
cd ~/netology/docker/task5
```
**Вывод:**
```text
docker compose up -d
no configuration file provided: not found
compose.yaml  docker-compose.yaml
```

> [!WARNING]
> **Разбор проблемы:** При первой попытке запуска в директории `/tmp` утилита `docker compose` выдала ошибку отсутствия файлов конфигурации, несмотря на то, что `ls` подтвердил их наличие. Это частая проблема Snap-версий Docker, которые имеют ограниченный доступ к глобальным временным каталогам системы (`/tmp`). Для исправления этой проблемы рабочее окружение было перенесено в домашнюю директорию пользователя `~/netology/...`.

<details>
<summary>📸 Посмотреть полный скриншот подготовки рабочей директории и траблшутинга путей</summary>

![Скриншот подготовки рабочей директории и траблшутинга путей](https://github.com/user-attachments/assets/f81b37b0-f468-46cf-897d-1cd88b8c21f4)

</details>

### 2. Копирование конфигурации и запуск Docker Compose

**Ввод:**
```bash
cp /tmp/netology/docker/task5/*.yaml .
ls
docker compose up -d
docker compose ps
```
**Вывод:**
```text
compose.yaml  docker-compose.yaml

WARN[0000] Found multiple config files with supported names: /home/oleg/netology/docker/task5/compose.yaml, /home/oleg/netology/docker/task5/docker-compose.yaml
WARN[0000] Using /home/oleg/netology/docker/task5/compose.yaml
WARN[0000] /home/oleg/netology/docker/task5/compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
[+] up 10/10
 ⠿ Image portainer/portainer-ce:latest Pulled
 ⠿ Container task5-portainer-1         Started

WARN[0000] Found multiple config files with supported names...
WARN[0000] Using /home/oleg/netology/docker/task5/compose.yaml
...
NAME                IMAGE                            COMMAND        SERVICE     CREATED             STATUS
task5-portainer-1   portainer/portainer-ce:latest    "/portainer"   portainer   About a minute ago  Up About a minute
```

> [!IMPORTANT]
> **Анализ приоритетов конфигурационных файлов:**
> При запуске оркестратора утилита обнаружила два файла конфигурации. В соответствии со спецификацией Docker Compose, файл **`compose.yaml`** имеет наивысший приоритет, поэтому система выбрала именно его для развертывания панели управления Portainer, проигнорировав `docker-compose.yaml`.
> 
> Также лог предупреждает, что директива `version` в современных версиях Docker Compose является устаревшей (`obsolete`) и автоматически игнорируется.

<details>
<summary>📸 Посмотреть скриншот запуска Portainer через Docker Compose</summary>

![Скриншот консоли с варнингами и успешным запуском](https://github.com/user-attachments/assets/7d502955-6d37-43e3-895d-9b5e43b2c51e)

</details>

### 3. Содержимое конфигурационного файла compose.yaml

В файле конфигурации была использована директива `include` для импорта стороннего конфигурационного файла:

```yaml
version: "3"

include:
  - path: docker-compose.yaml

services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
### 4. Результат совместного развертывания сервисов через include

После сохранения файла `compose.yaml` была выполнена повторная сборка окружения. Утилита `docker compose` успешно подтянула конфигурацию локального реестра (Registry) из импортированного файла.

**Ввод:**
```bash
nano compose.yaml
docker compose up -d
docker compose ps
```
**Вывод:**
```text
WARN Found multiple config files with supported names...
WARN Using /home/oleg/netology/docker/task5/compose.yaml
...
[+] up 9/9
 ⠿ Image registry:2            Pulled
 ⠿ Network task5_default       Created
 ⠿ Container task5-portainer-1 Running
 ⠿ Container task5-registry-1  Started

NAME                IMAGE                           COMMAND                  SERVICE     CREATED          STATUS          PORTS
task5-portainer-1   portainer/portainer-ce:latest   "/portainer"             portainer   6 minutes ago    Up 6 minutes    
task5-registry-1    registry:2                      "/entrypoint.sh /etc…"   registry    5 seconds ago    Up 5 seconds    0.0.0.0:5000->5000/tcp, [::]:5000->5000/tcp
```

<details>
<summary>📸 Посмотреть финальный скриншот работы двух сервисов</summary>

![Скриншот, где видны оба запущенных контейнера](https://github.com/user-attachments/assets/4cd3fda6-89ec-4125-8746-616882364cb9)

</details>

### 5. Тегирование и отправка локального образа в собственный Registry

Для проверки работоспособности поднятого Docker Registry локальный образ `custom_nginx` был переименован (тегирован) и отправлен в локальный реестр на порт `5000`:

**Ввод:**
```bash
docker tag custom_nginx:latest 127.0.0.1:5000/custom_nginx:latest
docker push 127.0.0.1:5000/custom_nginx:latest
```
**Вывод:**
```text
The push refers to repository [127.0.0.1:5000/custom_nginx]
be551fb4e2bc: Pushed
5f70bf18a086: Pushed
2e174fd56089: Pushed
727839498dfa: Pushed
508937af8963: Pushed
e9b5d470f331: Pushed
5e1b8f458cec: Pushed
d89e58119fc7: Pushed
eb5f13bce993: Pushed
latest: digest: sha256:f051d8c69b43d3242ad25983ab1ba855d5cf8c1029d3ff71b337ac1984c911df size: 2191
```

<details>
<summary>📸 Посмотреть скриншот отправки образа (docker push)</summary>

![Скриншот из терминала](https://github.com/user-attachments/assets/36d4a516-b69d-4869-8c59-432ff368c8d9)

</details>

### 6. Создание стека (Stack) в веб-интерфейсе Portainer

Для финального развертывания веб-сервера был использован графический интерфейс Portainer (Community Edition). В разделе **Stacks** через встроенный веб-редактор (**Web editor**) был создан стек с именем `netology-nginx`.

Конфигурация созданного стека:
```yaml
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx:latest
    ports:
      - "9090:80"
```

> [!NOTE]
> **Итог работы:** Окружение полностью связано между собой. Portainer успешно забирает кастомный образ веб-сервера из нашего локального приватного репозитория `127.0.0.1:5000` и разворачивает его в виде изолированного стека на порту `9090`. 

<details>
<summary>📸 Посмотреть скриншот конфигурации стека в веб-интерфейсе Portainer</summary>

![Скриншот с Portainer](https://github.com/user-attachments/assets/cd1fb94c-7337-4ce5-8d1d-0db8cf451afd)

</details>

### 7. Инспектирование запущенного контейнера в Portainer

Для окончательной проверки параметров развернутого сервиса был выполнен просмотр низкоуровневой конфигурации контейнера (аналог команды `docker inspect`).

Ключевые параметры конфигурации из JSON-вывода:
```json
{
  "Args": [],
  "Config": {
    "Cmd": [
      "nginx",
      "-g",
      "daemon off;"
    ],
    "Env": [
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      "NGINX_VERSION=1.29.0"
    ],
    "ExposedPorts": {
      "80/tcp": {}
    }
  },
  "Image": "127.0.0.1:5000/custom-nginx:latest",
  "Labels": {
    "com.docker.compose.project": "netology-nginx",
    "com.docker.compose.service": "nginx"
  },
  "Created": "2026-05-16T13:07:59.064085859Z",
  "Driver": "overlay2"
}
```

> [!NOTE]
> **Итоговое заключение:** Анализ метаданных подтверждает, что стек `netology-nginx` функционирует корректно. Сервер использует кастомный образ Nginx версии `1.29.0`, успешно скачанный из локального репозитория, и работает на сетевом драйвере `overlay2`. 

<details>
<summary>📸 Посмотреть полный скриншот JSON-инспекции контейнера</summary>

![Скриншот конфигурации](https://github.com/user-attachments/assets/c95ba7bf-463f-4a60-96ad-e8e1b2720682)

</details>

### 8. Удаление compose.yaml и очистка потерянных (orphan) контейнеров

**Ввод:**
```bash
rm compose.yaml
docker compose up -d
docker compose down --remove-orphans
```
**Вывод:**
```text
WARN[0000] /home/oleg/netology/docker/task5/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
WARN[0000] Found orphan containers ([task5-portainer-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
[+] up 1/1
 ⠿ Container task5-registry-1 Running
```

> [!WARNING]
> **Разбор ситуации:** Предупреждение сообщает о наличии потерянных (orphan) контейнеров. Это произошло потому, что файл конфигурации `compose.yaml` был удалён, и Docker Compose больше «не знает» про описанный там сервис `portainer`, хотя сам контейнер всё ещё запущен в системе. Для корректной очистки таких ресурсов и приведения окружения в порядок в дальнейшем применяется команда `docker compose down --remove-orphans`.

<details>
<summary>📸 Посмотреть скриншот с предупреждением Found orphan containers</summary>

![скриншот консоли](https://github.com/user-attachments/assets/bb14ac8a-bf3c-4973-8897-2e905c756a3f)

</details>

### 9. Успешная остановка проекта и удаление потерянных контейнеров

**Ввод:**
```bash
docker compose down --remove-orphans
```
**Вывод:**
```text
WARN /home/oleg/netology/docker/task5/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
[+] down 3/3
 ⠿ Container task5-registry-1  Removed
 ⠿ Container task5-portainer-1 Removed
 ⠿ Network task5_default       Removed
```

> [!NOTE]
> **Итог очистки:** Команда `down` с флагом `--remove-orphans` полностью зачистила рабочее окружение. Были удалены как текущие активные сервисы и общая сеть проекта, так и изолированный («осиротевший») контейнер Portainer. Инфраструктура хост-машины приведена в исходное чистое состояние. Работа полностью завершена.

<details>
<summary>📸 Посмотреть скриншот успешного выполнения docker compose down</summary>

![скриншот консоли](https://github.com/user-attachments/assets/cd5fdfbc-ff6d-4b58-b87a-38666108feef)

</details>


