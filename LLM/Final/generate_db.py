import json
import requests

raw_templates = [
    {
        "id": "route_001",
        "title": "Проблемы с Wi-Fi подключением",
        "category": "БЛВС",
        "keywords": "wifi, вай-фай, беспроводная сеть, не подключается, нет интернета, ошибка сети, мобильное устройство",
        "business_service_id": "Беспроводная локально-вычислительная сеть",
        "assigned_group_id": "Группа системного администрирования"
    },
    {
        "id": "route_002",
        "title": "Проблемы с сетевым подключением",
        "category": "ЛВС",
        "keywords": "не подключается, нет интернета, ошибка сети, сетевая розетка, сеть, ПК",
        "business_service_id": "Локально-вычислительная сеть",
        "assigned_group_id": "Группа системного администрирования"
    },
    {
        "id": "po_001",
        "title": "Проблемы с программным обеспечением",
        "category": "Сервис отправки сообщений/ПО",
        "keywords": "не работает почта, почтовый клиент, outlook, не открывается, не архивируется, переполнена",
        "business_service_id": "Сервис отправки сообщений/ПО",
        "assigned_group_id": "Группа технического обеспечения"
    },
    {
        "id": "po_002",
        "title": "Проблемы с доступом в сервис отправки сообщений",
        "category": "Сервис отправки сообщений/Сервер",
        "keywords": "не работает почта, outlook, нет подключения, требует ввести логин/пароль, не приходят письма",
        "business_service_id": "Сервис отправки сообщений/Сервер",
        "assigned_group_id": "Группа системного администрирования"
    },
    {
        "id": "lp_001",
        "title": "Создание учетной записи для вновь принятого сотрудника/1С",
        "category": "Учетная запись/1С",
        "keywords": "Учетная запись 1с, @mydomen.com, 1С управление предприятием, 1С ERP, доступ",
        "business_service_id": "Учетная запись/1С",
        "assigned_group_id": "Группа администрирования 1С"
    },
    {
        "id": "lp_002",
        "title": "Создание учетной записи для вновь принятого сотрудника/Домен",
        "category": "Учетная запись/Домен",
        "keywords": "Учетная запись, табельный номер, должность, телефон, отдел, почтовый ящик",
        "business_service_id": "Учетная запись/Домен",
        "assigned_group_id": "Группа системного администрирования"
    }
]

def get_embedding(text: str) -> list[float]:
    response = requests.post(
        "http://localhost:11434/api/embeddings",
        json={"model": "bge-m3-custom", "prompt": text}
    )
    response.raise_for_status()
    return response.json()["embedding"]

print("🚀 Генерация векторов через bge-m3 (может занять минуту)...")

for item in raw_templates:
    print(f"⏳ Векторизация: {item['id']}...")
    # Векторизуем именно keywords (согласно нашей архитектуре)
    item["embedding"] = get_embedding(item["keywords"])

with open("knowledge_base.json", "w", encoding="utf-8") as f:
    json.dump(raw_templates, f, ensure_ascii=False, indent=2)

print("\n✅ База знаний успешно сохранена в knowledge_base.json")
print(f"📊 Количество шаблонов: {len(raw_templates)}")
