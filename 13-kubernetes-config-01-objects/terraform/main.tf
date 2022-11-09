provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone      = var.YC_ZONE
}

data "yandex_compute_image" "centos" {
  family = "centos-7"

  depends_on = [
    null_resource.folder
  ]
}

resource "yandex_vpc_network" "network-1" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  v4_cidr_blocks = ["10.1.0.0/24"]
  zone           = var.YC_ZONE
  network_id     = yandex_vpc_network.network-1.id
}

resource "yandex_compute_instance" "control-plane" {

  count = local.instance_count[terraform.workspace]
  name  = "${terraform.workspace}-cp-${count.index}"

  resources {
    cores  = local.vm_cores[terraform.workspace]
    memory = local.vm_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos.id
      type     = "network-hdd"
      size     = local.vm_disk[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file(var.user_data)}"
  }
}

resource "yandex_compute_instance" "worker" {

  count = local.instance_count_work[terraform.workspace]
  name  = "${terraform.workspace}-worker-${count.index}"

  resources {
    cores  = local.vm_cores_work[terraform.workspace]
    memory = local.vm_memory_work[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos.id
      type     = "network-hdd"
      size     = local.vm_disk_work[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file(var.user_data)}"
  }
}

locals {
  instance_count = {
    "prod"=3
    "stage"=1
  }
  vm_cores = {
    "prod"=4
    "stage"=2
  }
  vm_memory = {
    "prod"=4
    "stage"=2
  }
  vm_disk = {
    "prod"=50
    "stage"=50
  }

  instance_count_work = {
    "prod"=6
    "stage"=3
  }
  vm_cores_work = {
    "prod"=2
    "stage"=2
  }
  vm_memory_work = {
    "prod"=2
    "stage"=2
  }
  vm_disk_work = {
    "prod"=100
    "stage"=100
  }
}

