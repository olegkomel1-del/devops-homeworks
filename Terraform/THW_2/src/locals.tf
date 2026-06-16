locals {
  project = "netology"
  env     = "develop"

  vm_web_name = "${local.project}-${local.env}-platform-web"
  vm_db_name  = "${local.project}-${local.env}-platform-db"
}
