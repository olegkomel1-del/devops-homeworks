# Домашнее задание к занятию 14 «Средство визуализации Grafana»

## 1. Самостоятельно разверните grafana, где в роли источника данных будет выступать prometheus, а сборщиком данных будет node-exporter.

### Data sourese
![Data sourse](https://github.com/user-attachments/assets/8682adcf-d8f7-4cc6-8d6a-402e7fec133d)

## 2. Создание Dashboard

### Dashboard
![Dashboard](https://github.com/user-attachments/assets/702511ed-68fe-4500-b9ce-6fb1d1d63b17)

### Утилизация CPU

>promql-запрос
>```text
>100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
>```

### Load Average 1/5/15

>promql-запрос
>```text
>node_load1
>node_load5
>node_load15
>```

### Свободная оперативная память

>promql-запрос
>```text
>node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
>```

### Свободное место на файловой системе

>promql-запрос
>```text
>node_filesystem_avail_bytes{mountpoint="/"} / 1024 / 1024 / 1024
>```

## 3. Создать Alerts

### Alerts

![Alerts](https://github.com/user-attachments/assets/fca7229f-ad38-4627-9f6e-c2b30a29addc)

### Test alert message

![Test alert message](https://github.com/user-attachments/assets/3296adab-2716-458b-b14d-855183a69407)

## 4. Сохранить JSON MODEL

### JSON MODEL

