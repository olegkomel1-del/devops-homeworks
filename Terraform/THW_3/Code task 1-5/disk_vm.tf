resource "yandex_compute_disk" "storage_disks" {
  count = 3
  name = "storage-disk-${count.index + 1}"
  zone = var.default_zone
  size = 1
}


resource "yandex_compute_instance" "storage_vm" {
  name        = "storage"
  platform_id = var.vms_resources.web.platform_id

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }


  dynamic "secondary_disk" {

    for_each = yandex_compute_disk.storage_disks

    content {

      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = merge(var.vms_metadata, {
    ssh-keys = local.ssh_key
  })
}
