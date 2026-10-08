
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


### Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде

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

---

### Создать Deployment приложения, состоящего из контейнеров busybox и multitool, использующего созданный ранее PVC

### deployment-pv.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-exchange-pv
spec:
  replicas: 1
  selector:
    matchLabels:
      app: data-exchange-pv
  template:
    metadata:
      labels:
        app: data-exchange-pv
    spec:
      containers:
        - name: busybox
          image: busybox:latest
          command:
            - sh
            - -c
            - |
              while true; do
                echo "$(date) - hello from busybox (PV)" >> /shared/data.txt
                sleep 5
              done
          volumeMounts:
            - name: persistent-storage
              mountPath: /shared
        - name: multitool
          image: wbitt/network-multitool:latest
          command: ["sleep", "infinity"]
          volumeMounts:
            - name: persistent-storage
              mountPath: /shared
      volumes:
        - name: persistent-storage
          persistentVolumeClaim:
            claimName: local-pvc
```

---

### Продемонстрировать, что контейнер multitool может читать данные из файла в смонтированной директории, в который busybox записывает данные каждые 5 секунд

![Demo](https://github.com/user-attachments/assets/d4ed39ea-f0a7-4e6d-bb0e-0476c98966c7)

---

### Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.

![Удалить Deployment и PVC + demo](https://github.com/user-attachments/assets/61f4e18b-1466-4528-8345-01cf099a4b79)

Как видно из приложенного выше скриншота при удалении Deployment и PVC с файлом /tmp/k8s-local-pv/data.txt ничего не произошло. Это объясняется тем что при создании PV в теле спецификации в параметре "persistentVolumeReclaimPolicy" установлено значение "Retain", при такой конфигурации такое состояние файла ожидаемо. При этом PV перешёл в статус Released.

---

### Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV. Продемонстрировать, что произошло с файлом после удаления PV. Пояснить, почему.

![Удалить PV + demo](https://github.com/user-attachments/assets/7ea06f89-4802-4f72-af09-9a568cd621e4)

После удаления PV файл на ноде не пропал, потому что PV это объект K8S описывающий подключение к ресурсом ноды. При удалении PV удаляется только объект, а физические данные на диске ноды не затрагиваются.

## Задание 3. StorageClass

### Создать Deployment приложения, состоящего из контейнеров busybox и multitool, использующего созданный ранее PVC.

### sc-pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sc-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: microk8s-hostpath
```

---

### Создать SC и PVC для подключения папки на локальной ноде, которая будет использована в поде.

### Скриншот создания SC
![SC](https://github.com/user-attachments/assets/5c4b07e1-7d31-4c9e-8d4e-7b3412653c64)
### Скриншот создания PVC и проверка динамически созданного PV
![PVC](https://github.com/user-attachments/assets/4a7353f2-d29d-4427-8a20-5f61e63139c5)

---
### Продемонстрировать, что контейнер multitool может читать данные из файла в смонтированной директории, в который busybox записывает данные каждые 5 секунд

![demo](https://github.com/user-attachments/assets/de072c31-455c-4eb1-8f6f-f191551a25ee)
