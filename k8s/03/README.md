
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

## 2. Увеличить количество реплик работающего приложения до 2.  +
## 3. Продемонстрировать количество подов до и после масштабирования.

>### Скриншот выполнения команд для увеличения реплик приложения nginx-multitool до 2х.
>
>![Скриншот выполнения команд для увеличения реплик приложения nginx-multitool до 2х](https://github.com/user-attachments/assets/f66c8597-d72b-4287-829a-ca17232ea307)

## 4. Создать Service, который обеспечит доступ до реплик приложений

>## service.yaml
>```yaml
>apiVersion: v1
>kind: Service
>metadata:
>  name: nginx-multitool-svc
>spec:
>  selector:
>    app: nginx-multitool
>  ports:
>    - name: nginx-port
>      port: 80
>      targetPort: 80
> ```

>### Скриншот выполнения команд для создания service
>
>![Скриншот выполнения команд для создания service](https://github.com/user-attachments/assets/36a4b617-4418-4e14-a834-c1f2e8ab2d8d)

