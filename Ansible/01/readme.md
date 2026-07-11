# Домашнее задание к занятию «Ansible: Работа с Playbook»

## Решение задания

Подготовил inventory-файл `prod.yml`, содержащий целевые хосты для развертывания инфраструктуры в Яндекс Облаке (под управлением ОС Ubuntu 24.04 LTS). Для безопасного подключения без хардкода секретов настроил сессию `ssh-agent` и добавил приватный ключ командой `ssh-add`.

Дописал playbook `site.yml`, добавив второй play для автоматизации скачивания, распаковки, установки и настройки лог-агента Vector. 
Конфигурация Vector деплоится через Jinja2-шаблон `vector.toml.j2` и использует безопасный sink-приемник типа `blackhole`, что исключает лавинообразное зацикливание вывода логов в системный журнал и переполнение дискового пространства ВМ.

Применил встроенный обработчик (handler) для автоматического перезапуска службы `vector.service` при изменении конфигурационных файлов.

### Шаг 1: Подготовил файл инвентаря inventory/prod.yml

```yaml
---
all:
  children:
    clickhouse:
      hosts:
        clickhouse-01:
          ansible_host: 111.88.242.19
    vector_servers:
      hosts:
        vector-01:
          ansible_host: 111.88.245.121
  vars:
    ansible_user: o_komel
```

### Шаг 2: Разработал шаблон конфигурации Vector templates/vector.toml.j2

```toml
# Configuration for Vector (Fixed Loop-Bomb)
data_dir = "/var/lib/vector"

[sources.in]
type = "file"
include = [ "/var/log/syslog", "/var/log/auth.log" ]
ignore_not_found = true

[sinks.out]
inputs = [ "in" ]
type = "blackhole"
```

### Шаг 3: Написал итоговый playbook site.yml

```yaml
---
- name: Install Clickhouse
  hosts: clickhouse
  vars:
    clickhouse_version: "23.3.8.21"
    clickhouse_packages:
      - clickhouse-common-static
      - clickhouse-client
      - clickhouse-server

  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted

  tasks:
    - name: Group Clickhouse installation tasks
      block:
        - name: Download Clickhouse DEB packages
          ansible.builtin.get_url:
            url: "https://clickhouse.com{{ item }}_{{ clickhouse_version }}_amd64.deb"
            dest: "/tmp/{{ item }}_{{ clickhouse_version }}_amd64.deb"
            mode: '0644'
          loop: "{{ clickhouse_packages }}"
      rescue:
        - name: Download Clickhouse DEB packages (fallback)
          ansible.builtin.get_url:
            url: "https://clickhouse.com{{ item }}_{{ clickhouse_version }}_all.deb"
            dest: "/tmp/{{ item }}_{{ clickhouse_version }}_all.deb"
            mode: '0644'
          loop: "{{ clickhouse_packages }}"

    - name: Install clickhouse packages on Ubuntu
      become: true
      ansible.builtin.apt:
        deb: "/tmp/{{ item }}_{{ clickhouse_version }}_amd64.deb"
      loop: "{{ clickhouse_packages }}"
      notify: Start clickhouse service

    - name: Flush handlers
      ansible.builtin.meta: flush_handlers

    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc != 82
      changed_when: create_db.rc == 0

- name: Install and configure Vector
  hosts: vector_servers
  become: true
  vars:
    vector_version: "0.40.0"
    vector_archive: "vector-0.40.0-x86_64-unknown-linux-musl.tar.gz"
    vector_download_url: "https://github.com{{ vector_archive }}"
    vector_install_dir: "/opt/vector"
    vector_bin_dir: "/usr/local/bin"
    vector_config_dir: "/etc/vector"

  handlers:
    - name: Restart vector service
      ansible.builtin.systemd:
        name: vector
        state: restarted

  tasks:
    - name: Ensure configuration directory exists
      ansible.builtin.file:
        path: "{{ vector_config_dir }}"
        state: directory
        mode: '0755'

    - name: Download Vector archive  # noqa command-instead-of-module
      ansible.builtin.command:
        cmd: "curl -L -o /tmp/{{ vector_archive }} {{ vector_download_url }}"
        creates: "/tmp/{{ vector_archive }}"

    - name: Extract Vector archive
      ansible.builtin.unarchive:
        src: "/tmp/{{ vector_archive }}"
        dest: "/tmp"
        remote_src: true

    - name: Ensure install directory exists
      ansible.builtin.file:
        path: "{{ vector_install_dir }}"
        state: directory
        mode: '0755'

    - name: Copy Vector binary to install directory
      ansible.builtin.copy:
        src: "/tmp/vector-x86_64-unknown-linux-musl/bin/vector"
        dest: "{{ vector_install_dir }}/vector"
        mode: '0755'
        remote_src: true

    - name: Create symlink to binary directory
      ansible.builtin.file:
        src: "{{ vector_install_dir }}/vector"
        dest: "{{ vector_bin_dir }}/vector"
        state: link

    - name: Ensure vector data directory exists
      ansible.builtin.file:
        path: "/var/lib/vector"
        state: directory
        mode: '0755'

    - name: Deploy Vector configuration from template
      ansible.builtin.template:
        src: templates/vector.toml.j2
        dest: "{{ vector_config_dir }}/vector.toml"
        mode: '0644'
      notify: Restart vector service

    - name: Create systemd service for Vector
      ansible.builtin.copy:
        dest: /etc/systemd/system/vector.service
        mode: '0644'
        content: |
          [Unit]
          Description=Vector Log Agent
          After=network.target

          [Service]
          ExecStart={{ vector_bin_dir }}/vector --config {{ vector_config_dir }}/vector.toml
          Restart=always
          User=root

          [Install]
          WantedBy=multi-user.target
      notify: Restart vector service

    - name: Ensure Vector service is started and enabled
      ansible.builtin.systemd:
        name: vector
        state: started
        enabled: true
        daemon_reload: true
```

### Шаг 4: Проверка кода статическим линтером ansible-lint

Установил инструмент валидации в виртуальное окружение. Запустил проверку синтаксиса и форматирования. Плейбук успешно прошел проверку по максимальному профилю соответствия стандартам `production`:

```bash
ansible-lint site.yml
```

> **Вывод ansible-lint**:  
>   
> ![Скриншот прохождения линтера](https://github.com/user-attachments/assets/2c085ea5-5d7d-4b76-bc10-1ec230e25cea)


### Шаг 5: Тестовое выполнение playbook с флагом --check

Выполнил предварительное тестирование сценария развертывания без фактического изменения целевых систем:

```bash
ansible-playbook -i inventory/prod.yml site.yml --check
```

> **Вывод тестового прогона**:  
>   
> ![Скриншот прогона check](https://github.com/user-attachments/assets/4b9c2f88-ac12-4bc0-906c-b469ce59006e)

### Шаг 6: Боевой запуск playbook с флагом --diff

Запустил применение конфигурации на целевых хостах. С помощью флага `--diff` проверил корректность всех вносимых на файловую систему изменений (создание директорий, генерация systemd-юнитов и деплой Jinja2 шаблона):

```bash
ansible-playbook -i inventory/prod.yml site.yml --diff
```

> **Вывод боевого прогона с diff**:  
>   
> ![Скриншот боевого прогона с diff](https://github.com/user-attachments/assets/81cec9b1-ceb7-44f0-8a56-d574e675c903)


### Шаг 7: Повторный запуск для проверки идемпотентности

Запустил playbook повторно в режиме отображения различий, чтобы убедиться, что повторные прогоны не вносят деструктивных изменений в стабильное состояние инфраструктуры. Счётчики `changed` для всех хостов вернули `0`:

```bash
ansible-playbook -i inventory/prod.yml site.yml --diff
```

> **Вывод повторного прогона (идемпотентность)**:  
>   
> ![Скриншот повторного прогона](https://github.com/user-attachments/assets/2a577fc0-13a3-4c73-bb28-2f91a2a03927)



