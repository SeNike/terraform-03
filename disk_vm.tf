# Создание 3 виртуальных дисков размером 1 Гб

resource "yandex_compute_disk" "storage_disk" {
  count = 3

  name  = "storage-disk-${count.index + 1}"
  size  = 1  # Размер диска в Гб
  type  = "network-hdd"  # Тип диска
  zone  = var.default_zone
}

# Создание ВМ с именем "storage"
resource "yandex_compute_instance" "storage" {
  name = "storage"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat       = true
  }
  # Подключение дополнительных дисков с помощью dynamic и for_each
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disk[*]

    content {
      disk_id = secondary_disk.value.id
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}