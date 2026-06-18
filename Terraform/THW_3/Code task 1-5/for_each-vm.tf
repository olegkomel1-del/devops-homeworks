resource "yandex_compute_instance" "db_vm" {
    for_each = { for vm in var.each_vm : vm.vm_name => vm }

    name        = each.key
  platform_id = var.vms_resources.web.platform_id

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size         = each.value.disk_volume
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
