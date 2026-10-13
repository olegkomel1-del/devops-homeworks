# Домашнее задание к занятию «Настройка приложений и управление доступом в Kubernetes»

## Задание 1: Работа с ConfigMaps

### configmap-web.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-web-config
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Custom Page via ConfigMap</title>
    </head>
    <body>
      <h1>Hello from ConfigMap!</h1>
      <p>This page is served by nginx from a ConfigMap volume.</p>
    </body>
    </html>
```

### deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-multitool-cm
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-multitool-cm
  template:
    metadata:
      labels:
        app: nginx-multitool-cm
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
          volumeMounts:
            - name: web-content
              mountPath: /usr/share/nginx/html
        - name: multitool
          image: wbitt/network-multitool:latest
          command: ["sleep", "infinity"]
      volumes:
        - name: web-content
          configMap:
            name: nginx-web-config
```
---

### Скриншот вывода curl  

![curl](https://github.com/user-attachments/assets/48efd826-bd60-43a0-b129-dcfaf64dc5ea)

---

## Задание 2: Настройка HTTPS с Secrets

### secret-tls.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-tls
type: kubernetes.io/tls
data:
  tls.crt: <base64 от tls.crt>
  tls.key: <base64 от tls.key>
```

### Получить base64:
```bash
cat tls.crt | base64 -w0
cat tls.key | base64 -w0
```

## service-tls.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-cm-svc
spec:
  selector:
    app: nginx-multitool-cm
  ports:
    - port: 80
      targetPort: 80
```

### ingress-tls.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress-tls
spec:
  ingressClassName: public
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-cm-svc
                port:
                  number: 80
```

---

### Скриншот вывода curl -k   

![curl -k](https://github.com/user-attachments/assets/d8b80b5d-543c-430f-85e0-5315028d9dd9)



