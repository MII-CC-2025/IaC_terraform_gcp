data "google_compute_image" "vm_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

output "server_image" {
  value = data.google_compute_image.vm_image.name
}


resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_machine
  boot_disk {
    initialize_params {
      image = data.google_compute_image.vm_image.name #"ubuntu-2204-jammy-v20240319" #"ubuntu-2204-jammy-v20240228"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    ssh-keys =  "ec2-user:${file("~/.ssh/id_rsa.pub")}" 
  }

}
