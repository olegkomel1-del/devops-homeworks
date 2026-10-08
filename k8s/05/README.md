
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

### Создать Deployment приложения, состоящего из контейнеров busybox и multitool, использующего созданный ранее PVC

### pv-pvc.yaml
```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /tmp/k8s-local-pv
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - kms-test
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-storage
  volumeName: local-pv
```

<img width="991" height="597" alt="image" src="https://github.com/user-attachments/assets/d4ed39ea-f0a7-4e6d-bb0e-0476c98966c7" />

<img width="1171" height="714" alt="image" src="https://github.com/user-attachments/assets/61f4e18b-1466-4528-8345-01cf099a4b79" />

<img width="471" height="144" alt="image" src="https://github.com/user-attachments/assets/7ea06f89-4802-4f72-af09-9a568cd621e4" />


