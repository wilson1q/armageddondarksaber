terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "gcp-class5"
  region = "us-east1"
  credentials = "gcp-class5-e86cecf167a3.json"
}

resource "google_compute_network" "vpc_network" {
  name                    = "darksaber-vpc"
  auto_create_subnetworks = true
  project                 = "gcp-class5"
}

resource "google_compute_firewall" "firewall" {
  name    = "allow-http-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

 resource "google_compute_instance" "default" {
  name         = "DS-instance"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.db_static.address
    }
  }

  metadata = {
    user-data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > /tmp/hello.txt
    EOF
  }
} 

resource "google_compute_address" "db_static" {
  name = "darksaber-static-ip"
}

output "ip" {
  value = google_compute_address.db_static.address
}
output "subnet" {
  value = google_compute_network.vpc_network.self_link
}
output "vpc" {
  value = google_compute_network.vpc_network.name
}
output "ip_vm" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip  
}