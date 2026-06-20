output "all_vms_info" {
  description = "Список словарей со всеми созданными ВМ из ресурсов count, for_each и одиночной ВМ storage"

  value = concat(
    # 1. Веб-серверы (из count)
    [
      for vm in yandex_compute_instance.web_vm : {
        name       = vm.name
        id         = vm.id
        fqdn       = vm.fqdn
        local_ip   = vm.network_interface.0.ip_address
        external_ip = vm.network_interface.0.nat_ip_address
      }
    ],

    # 2. Базы данных (из for_each)
    [
      for vm in values(yandex_compute_instance.db_vm) : {
        name       = vm.name
        id         = vm.id
        fqdn       = vm.fqdn
        local_ip   = vm.network_interface.0.ip_address
        external_ip = vm.network_interface.0.nat_ip_address
      }
    ],

    # 3. Одиночная машина storage
    [
      {
        name       = yandex_compute_instance.storage_vm.name
        id         = yandex_compute_instance.storage_vm.id
        fqdn       = yandex_compute_instance.storage_vm.fqdn
        local_ip   = yandex_compute_instance.storage_vm.network_interface.0.ip_address
        external_ip = yandex_compute_instance.storage_vm.network_interface.0.nat_ip_address
      }
    ]
  )
}
