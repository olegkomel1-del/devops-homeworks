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

### Генерация сертификата
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=myapp.example.com"
```

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

### service-tls.yaml
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

## Задание 3: Настройка RBAC

### Проверка CA кластера
```bash
sudo ls /var/snap/microk8s/current/certs/
```
Там должны быть ca.crt и ca.key.

### Генерация ключа и CSR
```bash
# Приватный ключ
openssl genrsa -out developer.key 2048

# CSR — запрос на сертификат 
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"

# Подписать CSR нашим CA 
sudo openssl x509 -req -in developer.csr \
  -CA /var/snap/microk8s/current/certs/ca.crt \
  -CAkey /var/snap/microk8s/current/certs/ca.key \
  -CAcreateserial -out developer.crt -days 365
```

---

### Скриншот команд генерации

![Скриншот команд генерации](https://github.com/user-attachments/assets/114dcac8-3e02-4562-8eeb-a8313be81d28)

---

### role-pod-reader.yaml
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
```

### rolebinding-developer.yaml
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-pod-reader
  namespace: default
subjects:
  - kind: User
    name: developer
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

### Проверка прав
![Скриншот проверки прав](https://github.com/user-attachments/assets/89eb9d1d-595d-44d1-b637-06e74761959d)
