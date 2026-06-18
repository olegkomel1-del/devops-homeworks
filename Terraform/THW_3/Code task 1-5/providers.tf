terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.12.0"
}

provider "yandex" {
  # token     = var.token
#  cloud_id                 = sensitive("")
#  folder_id                = sensitive("")
  zone                     = var.default_zone
  service_account_key_file = file("~/ter-homeworks/02/src/.key.json")
}
