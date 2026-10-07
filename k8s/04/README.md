


# Сетевое взаимодействие в K8S

## Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

>### Deployment.yaml
>```yaml
>apiVersion: apps/v1
>kind: Deployment
>metadata:
>  name: nginx-multitool
>spec:
>  replicas: 3
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
>          env:
>            - name: HTTP_PORT
>              value: "8080"
>          ports:
>            - containerPort: 8080
>```

>### Скриншот создание/применение манифеста Deployment
>
>![Deployment.yaml](https://github.com/user-attachments/assets/e995c073-9a5d-4c03-9d2f-13187fcb82c5)

---

>### Service.yaml
>```yaml
>apiVersion: v1
>kind: Service
>metadata:
> name: nginx-multitool-svc
>spec:
> selector:
>   app: nginx-multitool
> ports:
>   - name: nginx-port
>     port: 9001
>     targetPort: 80
>   - name: multitool-port
>     port: 9002
>     targetPort: 8080
> type: ClusterIP
>```

>### Скриншот создание/применение манифеста Service
>
>![Service](https://github.com/user-attachments/assets/721e7dac-a0be-43ab-8d41-aacbc369c244)

---

>### test-pod.yaml
>```yaml
>apiVersion: v1
>kind: Pod
>metadata:
> name: multitool-client
>spec:
> containers:
>   - name: multitool
>     image: wbitt/network-multitool:latest
>     command: ["sleep", "infinity"]
>```

>### Скриншот создание/применение манифеста Pod + Проверка доступа по доменному имени сервиса
>
>![Pod](https://github.com/user-attachments/assets/9c95b34c-3fa7-4103-bc6f-3baf1f354a18)

---

>### nginx-nodeport.yaml
>```yaml
>apiVersion: v1
>kind: Service
>metadata:
> name: nginx-nodeport-svc
>spec:
> selector:
>   app: nginx-multitool
> ports:
>   - name: nginx-port
>     port: 80
>     targetPort: 80
>     nodePort: 30080
> type: NodePort
>```

>### Скриншот создание/применение манифеста Service (NodePort) + Проверка доступа снаружи кластера
>
>![Service (NodePort)](https://github.com/user-attachments/assets/74d5684c-01fc-44ec-bde6-6907ffe69ece)
