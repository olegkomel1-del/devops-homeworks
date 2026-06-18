output "all_vms_info" {
  description = "Список словарей со всеми созданными ВМ из ресурсов count и for_each"

  value = concat(

    [
      for vm in yandex_compute_instance.web_vm : {
        name = vm.name
        id   = vm.id
        fqdn = vm.fqdn
      }
    ],

    [
      for vm in values(yandex_compute_instance.db_vm) : {
        name = vm.name
        id   = vm.id
        fqdn = vm.fqdn
      }
    ],

    [
      {
        name = yandex_compute_instance.storage_vm.name
        id   = yandex_compute_instance.storage_vm.id
        fqdn = yandex_compute_instance.storage_vm.fqdn
      }
    ]
  )
}
