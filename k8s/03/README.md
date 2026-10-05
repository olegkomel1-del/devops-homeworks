
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

>### service.yaml
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

>### Скриншот выполнения команды kubectl get endpoints nginx-multitool-svc
>
>![kubectl get endpoints nginx-multitool-svc](https://github.com/user-attachments/assets/5ac8e826-0747-41b5-9369-d2e4bd93dac1)

## 5. Создать отдельный Pod с приложением multitool и убедиться с помощью curl, что из пода есть доступ до приложений

>### test-pod.yaml
>```yaml
>apiVersion: v1
>kind: Pod
>metadata:
>  name: multitool-client
>spec:
>  containers:
>    - name: multitool
>      image: wbitt/network-multitool:latest
>      command: ["sleep", "infinity"]
>```

### Проверка доступа к сервису из пода

>### kubectl exec -it multitool-client -- curl http://nginx-multitool-svc
>
>![kubectl exec -it multitool-client -- curl http://nginx-multitool-svc](https://github.com/user-attachments/assets/ae306339-c248-4890-8ddd-eb403a4ff1de)

## Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

>### nginx-init.yaml
>```yaml
>apiVersion: apps/v1
>kind: Deployment
>metadata:
>  name: nginx-with-init
>spec:
>  replicas: 1
>  selector:
>    matchLabels:
>      app: nginx-with-init
>  template:
>    metadata:
>      labels:
>        app: nginx-with-init
>    spec:
>      initContainers:
>        - name: wait-for-service
>          image: busybox:latest
>          command:
>            - sh
>            - -c
>            - |
>              echo "Waiting for nginx-init-svc..."
>              until nslookup nginx-init-svc.default.svc.cluster.local; do
>                echo "Service not found, retrying..."
>                sleep 2
>              done
>              echo "Service is up!"
>      containers:
>        - name: nginx
>          image: nginx:latest
>          ports:
>            - containerPort: 80
>```

>### Состояние пода ДО создания Service
>
>![Состояние пода ДО создания Service](https://github.com/user-attachments/assets/2bce00f7-4b12-4d5a-9c34-6427faad91e8)

## Создание сервиса Service

>### nginx-init-svc.yaml
>```yaml
>apiVersion: v1
>kind: Service
>metadata:
>  name: nginx-init-svc
>spec:
>  selector:
>    app: nginx-with-init
>  ports:
>    - port: 80
>      targetPort: 80
>  type: ClusterIP
>```


<img width="691" height="206" alt="image" src="https://github.com/user-attachments/assets/d8c48420-81df-4dec-b5be-70553358c855" />
