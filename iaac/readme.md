

Из-за ограничений вложенной виртуализации вместо virtual-box использую doker.  
  
Ставлю докер  
sudo apt-get update  
sudo apt-get install -y docker.io  
sudo usermod -aG docker $USER  

  <img width="478" height="32" alt="image" src="https://github.com/user-attachments/assets/09992620-082b-4a94-9bda-b902e52a9efc" />  



    Установка Vagrant:  
    GPG-ключ HashiCorp:
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-
archive-keyring.gpg   

    Добавляю репозиторий в систему:  
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list  
  
    Обновляю списки пакетов и устанавливаю Vagrant:  
    sudo apt update  
    sudo apt install vagrant  


    


<img width="453" height="70" alt="image" src="https://github.com/user-attachments/assets/b3f6578f-b2f0-413a-b914-12ee2018bda5" />  




<img width="669" height="68" alt="image" src="https://github.com/user-attachments/assets/5db530d6-12ee-464f-87bd-7358a41c9956" />

