variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "each_vm" {
  type = list(object({
    vm_name       = string
    cpu           = number
    ram           = number
    disk_volume   = number
    core_fraction = number
  }))
  default = [
    {
      vm_name       = "main"
      cpu           = 4
      ram           = 4
      disk_volume   = 20
      core_fraction = 20
    },
    {
      vm_name       = "replica"
      cpu           = 2
      ram           = 2
      disk_volume   = 15
      core_fraction = 20
    }
  ]
}
variable "vms_resources" {
  type = map(object({
    image_family  = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
      image_family  = "ubuntu-2004-lts"
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "vms_metadata" {
  type = map(string)
  default = {
    serial-port-enable = "1"
  }
}

locals {
  ssh_key = "ubuntu:${file("/home/o_komel/.ssh/id_ed25519.pub")}"
}
data "yandex_compute_image" "ubuntu" {
  family = var.vms_resources.web.image_family
}
locals {
  vpc = {
    network_id = "enp7i560tb28nageq0cc"
    subnet_ids = [
      "e9b0le401619ngf4h68n",
      "e2lbar6u8b2ftd7f5hia",
      "b0ca48coorjjq93u36pl",
      "fl8ner8rjsio6rcpcf0h",
    ]
    subnet_zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-c",
      "ru-central1-d",
    ]
  }
}
