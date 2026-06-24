terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.12.0"
}

provider "yandex" {

  service_account_key_file = file("${path.module}/.key.json")
  zone                     = var.default_zone
}
