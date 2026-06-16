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
    db = {
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
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJzy3cMfDtlh0xsedser/jIqn7ulu7EvYsHAYqsvzPG o_komel@kms-test"
  }
}

# === ПЕРЕМЕННЫЕ ДЛЯ ПЕРВОЙ ВМ (WEB) ===
#variable "vm_web_image_family" {
#  type    = string
#  default = "ubuntu-2004-lts"
#}
#
#variable "vm_web_name" {
#  type    = string
#  default = "netology-develop-platform-web"
#}
#
#variable "vm_web_platform_id" {
#  type    = string
#  default = "standard-v3"
#}
#
#
#variable "vm_web_cores" {
#  type    = number
#  default = 2
#}
#
#variable "vm_web_memory" {
#  type    = number
#  default = 2
#}
#
#variable "vm_web_core_fraction" {
#  type    = number
#  default = 20
#}

# === ПЕРЕМЕННЫЕ ДЛЯ ВТОРОЙ ВМ (DB) ===
variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "Target zone for DB instance"
}
#
#variable "vm_db_name" {
#  type    = string
#  default = "netology-develop-platform-db"
#}
#
#variable "vm_db_platform_id" {
#  type    = string
#  default = "standard-v3"
#}
#
#variable "vm_db_cores" {
#  type    = number
#  default = 2
#}
#
#variable "vm_db_memory" {
#  type    = number
#  default = 2
#}
#
#variable "vm_db_core_fraction" {
#  type    = number
#  default = 20
#}
#
