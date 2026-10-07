


# Сетевое взаимодействие в K8S

---

## Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

### Deployment.yaml

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

<img width="580" height="206" alt="image" src="https://github.com/user-attachments/assets/e995c073-9a5d-4c03-9d2f-13187fcb82c5" />


<img width="660" height="166" alt="image" src="https://github.com/user-attachments/assets/721e7dac-a0be-43ab-8d41-aacbc369c244" />


<img width="1098" height="596" alt="image" src="https://github.com/user-attachments/assets/9c95b34c-3fa7-4103-bc6f-3baf1f354a18" />


<img width="1059" height="600" alt="image" src="https://github.com/user-attachments/assets/74d5684c-01fc-44ec-bde6-6907ffe69ece" />
