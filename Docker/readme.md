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
### 5. Полный скриншот из консоли:
![Скриншот по второй задачи](https://github.com/user-attachments/assets/98da4add-11ba-47b7-a40f-3ffcf8d37053)

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

👉 *## Задача 3

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
^C2026/05/16 03:09:28 [notice] 1#1: signal 2 (SIGINT) received, exiting
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

👉 *![Uploading image.png…]()
*

</details>


