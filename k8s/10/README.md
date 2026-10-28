# Домашнее задание к занятию «Как работает сеть в K8s»

## 1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.

### apps.yaml
```yaml

apiVersion: v1
kind: Namespace
metadata:
  name: app

apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool:latest
          env:
            - name: HTTP_PORT
              value: "8080"

apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: app
spec:
  selector:
    app: frontend
  ports:
    - port: 8080
      targetPort: 8080

apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool:latest
          env:
            - name: HTTP_PORT
              value: "8080"

apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: app
spec:
  selector:
    app: backend
  ports:
    - port: 8080
      targetPort: 8080

apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cache
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool:latest
          env:
            - name: HTTP_PORT
              value: "8080"

apiVersion: v1
kind: Service
metadata:
  name: cache-svc
  namespace: app
spec:
  selector:
    app: cache
  ports:
    - port: 8080
      targetPort: 8080
```

## 2. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.

### policies.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: app
spec:
  podSelector: {} 
  policyTypes:
  - Ingress

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: backend 
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend 

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-cache
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: cache 
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend 
```

## Демонстрация прохождения трафика

![Demo](https://github.com/user-attachments/assets/c2473878-4980-43ad-a9ca-69339468aef5)
