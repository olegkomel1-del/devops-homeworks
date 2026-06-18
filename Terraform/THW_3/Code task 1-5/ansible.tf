resource "local_file" "hosts_cfg" {
  filename = "${path.module}/hosts.cfg"

    content = templatefile("${path.module}/hosts.tpl", {

    webservers = yandex_compute_instance.web_vm

    databases  = values(yandex_compute_instance.db_vm)

    storage    = [yandex_compute_instance.storage_vm]
  })
}
