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

Для того чтобы избежать ошибки конкуренции приложений за 80 порт добавляем для приложения network-multitool команду ["sleep", "infinity"]
