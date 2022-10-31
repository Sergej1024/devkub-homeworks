data "template_file" "inventory" {
  template = file("${path.module}/templates/inventory.tpl")

  vars = {
    master_node = join("\n", formatlist("%s ansible_host=%s ansible_user=ubuntu", yandex_compute_instance.control-plane.*.name, yandex_compute_instance.control-plane.*.network_interface.0.nat_ip_address))
    works_node   = join("\n", formatlist("%s ansible_host=%s ansible_user=ubuntu", yandex_compute_instance.worker.*.name, yandex_compute_instance.worker.*.network_interface.0.nat_ip_address))
    list_master               = join("\n",yandex_compute_instance.control-plane.*.name)
    list_works                 = join("\n", yandex_compute_instance.worker.*.name)
  }

  depends_on = [
    yandex_compute_instance.control-plane,
    yandex_compute_instance.worker
  ]
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ./kubespray/inventory/mycluster/inventory.ini"
  }

  triggers = {
    template = data.template_file.inventory.rendered
  }
}