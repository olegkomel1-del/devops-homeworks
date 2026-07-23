# Отчёт по домашнему заданию: «Создание собственных модулей»

**Студент:** Олег  
**Версия коллекции / Git tag:** 1.0.0

---

### Шаг 1–4. Создание и локальное тестирование Python-модуля

**Команда запуска:**
python3 my_own_module.py /tmp/test_module.txt "Test content"

**Описание:**
Проверка базовой работоспособности модуля через прямой вызов интерпретатором Python.

> ![Локальный запуск модуля через Python](https://github.com/user-attachments/assets/318767c0-5211-4e44-994f-f2b32fa7ca80)


---

### Шаг 5–6. Написание и проверка идемпотентности плейбука (playbook.yml)

**Команда запуска:**
ansible-playbook -i "localhost," playbook.yml

**Описание:**
Первичный запуск плейбука создает файл (статус changed=1), повторный запуск подтверждает идемпотентность (статус changed=0).

> ![Повторный запуск playbook.yml с changed=0](https://github.com/user-attachments/assets/53fafef0-3918-4a7a-87ae-1289cd7839ba)


---

### Шаг 7–10. Инициализация коллекции и создание роли

**Команды создания структуры:**
1. ansible-galaxy collection init my_own_namespace.yandex_cloud_elk
2. mkdir -p ansible_collections/my_own_namespace/yandex_cloud_elk/plugins/modules
3. cp my_own_module.py ansible_collections/my_own_namespace/yandex_cloud_elk/plugins/modules/
4. cd ansible_collections/my_own_namespace/yandex_cloud_elk/roles
5. ansible-galaxy role init my_role

**Описание:**
Сформирована структура коллекции my_own_namespace.yandex_cloud_elk. В роли my_role настроены значения по умолчанию (defaults/main.yml) и таска с вызовом модуля через FQCN (tasks/main.yml).

---

### Шаг 11–12. Проверка работы роли из коллекции (site.yml)

**Команда запуска:**
ANSIBLE_COLLECTIONS_PATH=. ansible-playbook -i "localhost," site.yml

**Описание:**
Проверка вызова роли коллекции через плейбук site.yml. Повторный запуск демонстрирует корректную работу и идемпотентность.

> ![Повторный запуск site.yml](https://github.com/user-attachments/assets/1855d7cc-c081-4c05-b35c-0f97dca962f7)


---

### Шаг 13–16. Фиксация изменений в Git и создание тега

**Команды публикации:**
git add Ansible/06/Ansible/ansible_collections/
git add Ansible/06/Ansible/library/
git add Ansible/06/Ansible/my_own_module.py
git add Ansible/06/Ansible/playbook.yml
git add Ansible/06/Ansible/site.yml
git tag 1.0.0
git commit -m "feat: add custom ansible module, playbooks, and collection role"
git push origin master --tags

**Описание:**
Изменения закоммичены в основной репозиторий, проставлен тег версии 1.0.0, и данные отправлены на GitHub.
