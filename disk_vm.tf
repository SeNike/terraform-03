# Создание 3 виртуальных дисков размером 1 Гб

resource "yandex_compute_disk" "storage_disk" {
  count = var.hdd_quantity

  name  = "storage-disk-${count.index + 1}"
  size  = var.hdd_vol_size  # Размер диска в Гб
  type  = var.storage_disk_type # Тип диска
  zone  = var.default_zone
}

# Создание ВМ с именем "storage"
resource "yandex_compute_instance" "storage" {
  name = "storage"
  platform_id = var.storage_platform
  allow_stopping_for_update = true

  resources {
    cores  = var.storage_resources[0].cores
    memory = var.storage_resources[0].memory
    core_fraction = var.storage_resources[0].core_fraction
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