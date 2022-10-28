provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone      = var.YC_ZONE
}

data "yandex_compute_image" "centos" {
  family = "centos-8"

  # depends_on = [
  #   null_resource.folder
  # ]
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
      size     = local.vm_disk[terraform.workspace] #"50"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "cloud-user${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file(var.user_data)}"
  }
}

resource "yandex_compute_instance" "worker-foreach" {

  name  = "${terraform.workspace}-worker-${each.key}"
  for_each = local.vm_foreach[terraform.workspace]

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos.id
      type     = "network-hdd"
      size     = each.value.disk #"100"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "cloud-user${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file(var.user_data)}"
  }

  lifecycle {
    create_before_destroy = true
  }

}

locals {
  instance_count = {
    "prod"=2
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

  vm_foreach = {
    prod = {
      "1" = { cores = "2", memory = "2", disk = "100" },
      "2" = { cores = "2", memory = "2", disk = "100" },
      "3" = { cores = "2", memory = "2", disk = "100" },
      "4" = { cores = "2", memory = "2", disk = "100" }
    }
	  stage = {
      "1" = { cores = "1", memory = "1", disk = "100" },
      "2" = { cores = "1", memory = "1", disk = "100" },
      "3" = { cores = "1", memory = "1", disk = "100" }
    }
  }
}

