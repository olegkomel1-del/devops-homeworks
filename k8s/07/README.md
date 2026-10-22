# Домашнее задание к занятию «Helm»

## Задание 1. Подготовить Helm-чарт для приложения

Для упаковки приложения (nginx и multitool) в чарт создана следующая структура директорий:

```text
myapp/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment-nginx.yaml
    ├── deployment-multitool.yaml
    ├── service-nginx.yaml
    └── service-multitool.yaml
```

### Chart.yaml
```yaml
apiVersion: v2
name: myapp
description: A Helm chart for nginx + multitool application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

### values.yaml
```yaml
replicaCount: 1

nginx:
  image: nginx
  tag: "1.25"
  port: 80

multitool:
  image: wbitt/network-multitool
  tag: "latest"
  port: 8080
```

### templates/deployment-nginx.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-nginx
  labels:
    app: {{ .Release.Name }}-nginx
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}-nginx
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-nginx
    spec:
      containers:
        - name: nginx
          image: "{{ .Values.nginx.image }}:{{ .Values.nginx.tag }}"
          ports:
            - containerPort: {{ .Values.nginx.port }}
```

### templates/deployment-multitool.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-multitool
  labels:
    app: {{ .Release.Name }}-multitool
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}-multitool
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-multitool
    spec:
      containers:
        - name: multitool
          image: "{{ .Values.multitool.image }}:{{ .Values.multitool.tag }}"
          env:
            - name: HTTP_PORT
              value: "{{ .Values.multitool.port }}"
          ports:
            - containerPort: {{ .Values.multitool.port }}
```

### templates/service-nginx.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-nginx
spec:
  selector:
    app: {{ .Release.Name }}-nginx
  ports:
    - port: {{ .Values.nginx.port }}
      targetPort: {{ .Values.nginx.port }}
```

### templates/service-multitool.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-multitool
spec:
  selector:
    app: {{ .Release.Name }}-multitool
  ports:
    - port: {{ .Values.multitool.port }}
      targetPort: {{ .Values.multitool.port }}
```
## Задание 2. Запустить две версии в разных неймспейсах

### Скриншот результатов выполнения helm чартов

![helm](https://github.com/user-attachments/assets/b1cb3308-d0c4-4fce-ae5b-44395fcc1e81)
