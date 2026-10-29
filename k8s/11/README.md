# Домашнее задание к занятию Troubleshooting

## 1. Установить приложение, выявить проблему и описать

### Скриншот проблемы
![Скриншот проблемы](https://github.com/user-attachments/assets/70e9e4c4-fa9c-4303-8713-97e0d19fefa2)

>Выявлено две проблемы:
>
>1. В Deployment используется устаревший (не существующий образ) "radial/busyboxplus:curl"
>
>2. В Deployment - web-consumer описан namespace - web, а в Deployment и Service - auth-db описан namespace - data. При этом приложение - web-consumer в запросе Curl обращается к приложению - auth-db по короткому имени "auth-db". Поэтому из-за разных namespace, приложение auth-db недоступно для web-consumer

## 2. Исправить проблему и описать

### task-fixed.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-consumer
  namespace: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-consumer
  template:
    metadata:
      labels:
        app: web-consumer
    spec:
      containers:
      - command:
        - sh
        - -c
        - while true; do curl auth-db.data.svc.cluster.local; sleep 5; done
        image: curlimages/curl:latest
        name: busybox
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-db
  namespace: data
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auth-db
  template:
    metadata:
      labels:
        app: auth-db
    spec:
      containers:
      - image: nginx:1.19.1
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: auth-db
  namespace: data
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: auth-db
```

>Решение:
>
>1. Заменить битый образ на рабочий -  "curlimages/curl:latest"
>
>2. В обращении к приложению "auth-db" использовать полное имя "auth-db.data.svc.cluster.local"

### Скриншот демонстрации успешного выполнения
![demo](https://github.com/user-attachments/assets/95c7d0ad-3d85-427d-ad5d-32b944d26540)
