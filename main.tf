terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = var.gcp_credentials
  project     = var.gcp_project
  region      = var.gcp_region
}



resource "google_compute_instance" "non_gpu" {
  count        = var.gpu_use == true ? 0 : 1
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }


  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
  
  // install python on target gcp VM for Ansible
  connection {
    user = "ubuntu"
    type = "ssh"

    private_key = "${file("~/.ssh/your_private_key.pem")}"
    timeout     = "2m"
  }

}


resource "google_compute_instance" "gpu" {
  count        = var.gpu_use == true ? 1 : 0
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
  
  // install python on target gcp VM for Ansible
  connection {
    user = "ubuntu"
    type = "ssh"

    private_key = "${file("~/.ssh/your_private_key.pem")}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python",
    ]
  }



 dynamic "guest_accelerator" {
    for_each = {for k,v in var.gpu_config : k=>v}
    content {
      type      = guest_accelerator.value["gpu_type"]
      count     = guest_accelerator.value["gpu_count"]

    }
  }
  //metadata_startup_script = "echo hi > /test.txt"
}
