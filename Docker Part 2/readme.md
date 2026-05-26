<details>
  
<summary>
  
# Задание 0.1 (Удаление)

</summary>    

## 1. Проверка версии Docker Compose перед удалением  

### Ввод:
```bash
docker-compose --version
``` 
### Вывод:
```text
Docker Compose version v5.1.1
```

## 2. Проверка версии Docker перед удалением

### Ввод:
```bash
docker --version
``` 
### Вывод:
```text
Docker version 29.3.1, build c2be9cc
```

## 3. Удаление snap-пакета Docker  

### Ввод:
```bash
sudo snap remove docker
``` 
### Вывод:
```text
docker removed (snap data snapshot saved)
```

## 4. Просмотр сохраненных снимков данных (snapshots)

### Ввод:
```bash
snap saved
``` 
### Вывод:
```text
Set  Snap    Age    Version  Rev   Size   Notes
1    docker  1m47s  29.3.1   3505  368MB  auto
```

## 5. Удаление сохраненного снимка под номером 1

### Ввод:
```bash
sudo snap forget 1
``` 
### Вывод:
```text
Snapshot #1 forgotten.
```

## 6. Повторная проверка снимков данных

### Ввод:
```bash
snap saved
``` 
### Вывод:
```text
No snapshots found.
```

## 7. Очистка остаточных директорий и конфигураций

### Ввод:
```bash
rm -rf ~/snap/docker
sudo rm -rf /var/snap/docker
sudo rm -rf /var/lib/docker
```

(Команды выполняются без вывода в терминал)

## 8. Проверка удаления Docker

### Ввод:
```bash
docker --version
``` 
### Вывод:
```text
-bash: /snap/bin/docker: No such file or directory
```

## 9. Проверка удаления Docker Compose

### Ввод:
```bash
docker-compose --version
``` 
### Вывод:
```text
-bash: /snap/bin/docker-compose: No such file or directory
```

## 10. Скриншот удаление Docker, Docker Compose

![Скриншот удаление Docker, Docker Compose](https://github.com/user-attachments/assets/c1e67e86-93db-4b97-ad19-17397c61a94c)

</details>

<details>
  
<summary>
  
# Задание 0.2 (Установка)

</summary>    

## 1. Установка необходимых системных утилит

### Ввод:
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
``` 
### Вывод:
```text
Получено 322 MB за 1мин 6с (4 894 kB/s)
Чтение списков пакетов… Готово

Уже установлен пакет curl самой новой версии (8.5.0-2ubuntu10.9).
Уже установлен пакет gnupg самой новой версии (2.4.4-2ubuntu17.4).
```

## 2. Проверка файла ключа

### Ввод:
```bash
 gpg --show-keys /etc/apt/keyrings/docker.gpg
``` 
### Вывод:
```text
gpg: directory '/home/oleg/.gnupg' created
gpg: keybox '/home/oleg/.gnupg/pubring.kbx' created
gpg: can't open '/etc/apt/keyrings/docker.gpg': No such file or directory
```

## 3. Проверка папки для ключей и самого старого ключа (Его удаление)

### Ввод:
```bash
ls -l /etc/apt/keyrings/
sudo rm -f /etc/apt/keyrings/docker.gpg
ls -l /etc/apt/keyrings/
``` 
### Вывод:
```text
-rw-r--r-- 1 root root 0 мая 26 12:12 docker.gpg
total 0
```
<details>


