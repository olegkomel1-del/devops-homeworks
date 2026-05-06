

Из-за ограничений вложенной виртуализации вместо virtual-box использую doker.  
  
Ставлю докер  
sudo apt-get update  
sudo apt-get install -y docker.io  
sudo usermod -aG docker $USER  

  <img width="478" height="32" alt="image" src="https://github.com/user-attachments/assets/09992620-082b-4a94-9bda-b902e52a9efc" />  



  Установка Vagrant:  
  GPG-ключ HashiCorp:
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg   

  Добавляю репозиторий в систему:  
    
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list  
  
  Обновляю списки пакетов и устанавливаю Vagrant:  
    sudo apt update  
    sudo apt install vagrant  


    Из зеркала
Установите дистрибутив Packer для вашей платформы из зеркала:

Скачайте дистрибутив Packer из зеркала и распакуйте в директорию packer:

mkdir packer
wget https://hashicorp-releases.yandexcloud.net/packer/1.11.2/packer_1.11.2_linux_amd64.zip -P ~/packer
unzip ~/packer/packer_1.11.2_linux_amd64.zip -d ~/packer

В примере указана версия 1.11.2, актуальную версию Packer см. в зеркале.

Добавьте Packer в переменную PATH:

Добавьте в файл .profile строку:

export PATH="$PATH:/home/<имя_пользователя>/packer"

Сохраните изменения.

Перезапустите оболочку:

exec -l $SHELL

Убедитесь, что Packer установлен:

packer --version

Результат:

Packer v1.11.2












С сайта HashiCorp
Скачайте и установите дистрибутив Packer по инструкции на официальном сайте.

Настройте плагин Yandex Compute Builder
Чтобы настроить плагин:

Создайте файл config.pkr.hcl со следующим содержанием:

packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

Установите плагин:

packer init <путь_к_файлу_config.pkr.hcl>

Результат:

Installed plugin github.com/hashicorp/yandex v1.1.2 in ...


<img width="453" height="70" alt="image" src="https://github.com/user-attachments/assets/b3f6578f-b2f0-413a-b914-12ee2018bda5" />  




<img width="669" height="68" alt="image" src="https://github.com/user-attachments/assets/5db530d6-12ee-464f-87bd-7358a41c9956" />

