resource "local_file" "hosts_cfg" {
  filename = "${path.module}/hosts.cfg"

    content = templatefile("${path.module}/bad_hosts.tpl", {

    webservers = yandex_compute_instance.web_vm

    databases  = values(yandex_compute_instance.db_vm)

    storage    = [yandex_compute_instance.storage_vm]
  })
}
resource "null_resource" "web_hosts_provision" {

  depends_on = [local_file.hosts_cfg]

   triggers = {
    policy_tf = join(",", [for v in yandex_compute_instance.web_vm : v.network_interface[0].ip_address])
  }

  provisioner "local-exec" {

    command = "sleep 30 && ansible-playbook -i ${local_file.hosts_cfg.filename} ${path.module}/test.yml"
    on_failure = continue
  }
}

