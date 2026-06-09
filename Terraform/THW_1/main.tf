variable "yc_token" { type = string }
variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }

terraform {
  required_providers {
    yandex = {
      source = "registry.terraform.io/yandex-cloud/yandex"
    }
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
    }
  }
  required_version = "~>1.8.0"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

provider "docker" {
  host = "ssh://o_komel@111.88.240.140:22"
}

resource "random_password" "mysql_root_password" {
  length  = 16
  special = false
}

resource "random_password" "mysql_user_password" {
  length  = 16
  special = false
}

resource "docker_image" "mysql" {
  name = "mysql:8"
}

resource "docker_container" "mysql" {
  image = docker_image.mysql.image_id
  name  = "example_${random_password.mysql_root_password.result}"

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_user_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}

