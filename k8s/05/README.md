
# Домашнее задание к занятию «Хранение в K8s»

## Задание 1. Volume: обмен данными между контейнерами в поде

### containers-data-exchange.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-exchange
spec:
  replicas: 1
  selector:
    matchLabels:
      app: data-exchange
  template:
    metadata:
      labels:
        app: data-exchange
    spec:
      containers:
        - name: busybox
          image: busybox:latest
          command:
            - sh
            - -c
            - |
              while true; do
                echo "$(date) - hello from busybox" >> /shared/data.txt
                sleep 5
              done
          volumeMounts:
            - name: shared-data
              mountPath: /shared
        - name: multitool
          image: wbitt/network-multitool:latest
          command: ["sleep", "infinity"]
          volumeMounts:
            - name: shared-data
              mountPath: /shared
      volumes:
        - name: shared-data
          emptyDir: {}
```

### Скриншот - создание/применение манифеста Deployment
![Deployment](https://github.com/user-attachments/assets/8a16164f-049a-4970-9d11-575f5af84539)

---

### Скриншот - описание пода с контейнерами (kubectl describe pods data-exchange)
![kubectl describe pods data-exchange](https://github.com/user-attachments/assets/a57e19c5-c0d3-462c-b21f-506cfe19e301)

---

### Скриншот - вывод команды чтения файла
![вывод](https://github.com/user-attachments/assets/824dce76-b0b2-418a-907c-48e5d6f01ad5)

## Задание 2. PV, PVC
