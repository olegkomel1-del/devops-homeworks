


## configmap-web.yaml
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

## deployment.yaml
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

<img width="937" height="337" alt="image" src="https://github.com/user-attachments/assets/48efd826-bd60-43a0-b129-dcfaf64dc5ea" />
