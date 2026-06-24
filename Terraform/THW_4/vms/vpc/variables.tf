variable "env_name" {
  type        = string
  description = "Название окружения (используется как префикс для имени сети)"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "Список подсетей со своими зонами и CIDR блоками"
}


