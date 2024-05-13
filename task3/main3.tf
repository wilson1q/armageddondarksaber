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
  project     = "gcp-class5"
  region      = "europe-west2"
  credentials = "gcp-class5-e86cecf167a3.json"
}

resource "google_compute_network" "darksaber-vpc-2" {
  name                    = "darksaber-vpc-2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_europe_west2" {
  name          = "subnet-europe-west2"
  ip_cidr_range = "10.172.0.0/24"
  region        = "europe-west2"
  network       = google_compute_network.darksaber-vpc-2.self_link

  private_ip_google_access = true
}

# This section is for Americas

resource "google_compute_network" "darksaber-vpc-3" {
  name                    = "darksaber-vpc-3"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_southamerica_west1" {
  name          = "subnet-southamerica-west1"
  ip_cidr_range = "172.16.11.0/24"
  region        = "southamerica-west1"
  network       = google_compute_network.darksaber-vpc-3.self_link
}

resource "google_compute_subnetwork" "subnet_us_east1" {
  name          = "subnet-us-east1"
  ip_cidr_range = "172.16.12.0/24"
  region        = "us-east1"
  network       = google_compute_network.darksaber-vpc-3.self_link
}

# This section is for Firewall

resource "google_compute_firewall" "europe-firewall" {
  name    = "europe-firewall"
  network = google_compute_network.darksaber-vpc-2.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.172.0.0/24"]
}
resource "google_compute_firewall" "firewall_http" {
  name    = "firewall-http"
  network = google_compute_network.darksaber-vpc-3.self_link

  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }

  source_ranges = ["172.16.11.0/24","172.16.12.0/24"]
}

resource "google_compute_firewall" "firewall_rdp" {
  name    = "firewall-rdp"
  network = google_compute_network.darksaber-vpc-2.self_link

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = [google_compute_subnetwork.subnet_asia_southeast1.ip_cidr_range]
  /*target_tags = [ "target-tags" ]*/
}

resource "google_compute_address" "static" {
  name   = "static-ip"
  region = "europe-west2"
}

# This Section is for VM Instance

resource "google_compute_instance" "default" {
  name         = "darksaber-instance"
  machine_type = "e2-micro"
  zone         = "europe-west2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.darksaber-vpc-2.self_link
    subnetwork = google_compute_subnetwork.subnet_europe_west2.self_link

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  /*provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]
  }*/

  metadata = {
      user-data = <<-EOF
        #!/bin/bash
        echo "Hello, World!" > /tmp/hello.txt
      EOF
    }
  }

 