resource "yandex_compute_instance" "web_vm" {

  count = 2

  name        = "web-${count.index + 1}"
  platform_id = var.vms_resources.web.platform_id

  resources {
    cores         = var.vms_resources.web.cores
    memory        = var.vms_resources.web.memory
    core_fraction = var.vms_resources.web.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = false

  security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = merge(var.vms_metadata, {
    ssh-keys = local.ssh_key
  })

  depends_on = [yandex_compute_instance.db_vm]
}


