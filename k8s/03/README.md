# Домашнее задание к занятию «Запуск приложений в K8S»

## 1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool.

>### Deployment.yaml
>```yaml
>apiVersion: apps/v1
>kind: Deployment
>metadata:
>  name: nginx-multitool
>spec:
>  replicas: 1
>  selector:
>    matchLabels:
>      app: nginx-multitool
>  template:
>    metadata:
>      labels:
>        app: nginx-multitool
>    spec:
>      containers:
>        - name: nginx
>          image: nginx:latest
>          ports:
>            - containerPort: 80
>        - name: multitool
>          image: wbitt/network-multitool:latest
>          command: ["sleep", "infinity"]
>```

Для того чтобы избежать ошибки при которой, оба приложения занимают 80 порт, добавляем для network-multitool команду ["sleep", "infinity"]. Таким образом 80 порт остается за nginx.

>### Скриншот выполнения команд для создания приложения nginx-multitool  
>
>![Скриншот выполнения команд для создания приложения nginx-multitool](https://github.com/user-attachments/assets/a4226d59-1b4f-4a0c-83c0-f1eacd0ddb08)
