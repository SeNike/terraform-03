resource "yandex_compute_instance" "web" {
  count = var.web_inst_quantity
  name = "web-${count.index + 1}"
  platform_id = var.web_platform
  
  resources {
    cores         = var.web_resources[0].cores
    memory        = var.web_resources[0].memory
    core_fraction = var.web_resources[0].core_fraction
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.web_nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${file("~/.ssh/yckey.pub")}"
  }

  depends_on = [yandex_compute_instance.db]

}

