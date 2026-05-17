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





