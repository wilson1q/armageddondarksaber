resource "google_compute_network" "darksaber-vpc-4" {
  name                    = "darksaber-vpc-4"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_asia_southeast1" {
  name          = "subnet-asia-southeast1"
  ip_cidr_range = "192.168.0.0/24"
  region        = "asia-southeast1"
  network       = google_compute_network.darksaber-vpc-4.self_link
}

resource "google_compute_instance" "asia-darksaber" {
  name         = "asia-darksaber"
  machine_type = "e2-micro"
  zone         = "asia-southeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.darksaber-vpc-4.self_link
    subnetwork = google_compute_subnetwork.subnet_asia_southeast1.self_link

    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_vpn_gateway" "gateway1" {
  name    = "europe-gateway1"
  network = google_compute_network.darksaber-vpc-2.self_link
  region  = "europe-west2"
}

resource "google_compute_vpn_gateway" "gateway2" {
  name    = "asia-gateway2"
  network = google_compute_network.darksaber-vpc-4.self_link
  region  = "asia-southeast1"
}

resource "google_compute_forwarding_rule" "esp_forwarding_rule1" {
  name        = "europe-forwarding-rule"
  region      = "europe-west2"
  ip_protocol = "ESP"
  ip_address  = google_compute_vpn_tunnel.tunnel1.id
  target      = google_compute_vpn_gateway.gateway1.self_link
}

resource "google_compute_forwarding_rule" "esp_forwarding_rule2" {
  name        = "asia-forwarding-rule"
  region      = "asia-southeast1"
  ip_protocol = "ESP"
  ip_address  = google_compute_vpn_tunnel.tunnel2.id
  target      = google_compute_vpn_gateway.gateway2.self_link
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name              = "europe-tunnel1"
  region            = "europe-west2"
  target_vpn_gateway = google_compute_vpn_gateway.gateway1.id
  shared_secret     = "darksaber-123456"
  peer_ip           = "34.89.17.182"
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name              = "asia-tunnel2"
  region            = "asia-southeast1"
  target_vpn_gateway = google_compute_vpn_gateway.gateway2.id
  shared_secret     = "darksaber-123456"
  peer_ip           = "34.89.17.182"
}

resource "google_compute_router" "router1" {
  name    = "europe-router1"
  network = google_compute_network.darksaber-vpc-2.self_link
  region  = "europe-west2"
}

resource "google_compute_router" "router2" {
  name    = "asia-router2"
  network = google_compute_network.darksaber-vpc-4.self_link
  region  = "asia-southeast1"
}

resource "google_compute_router_peer" "peer1" {
  name                      = "europe-peer1"
  router                    = google_compute_router.router1.name
  region                    = "europe-west2"
  peer_ip_address           = "34.89.17.182"
  peer_asn                  = "64512"
  advertised_route_priority = 100
  interface                 = "interface1"
}

resource "google_compute_router_peer" "peer2" {
  name                      = "asia-peer2"
  router                    = google_compute_router.router2.name
  region                    = "asia-southeast1"
  peer_ip_address           = "34.89.17.182"
  peer_asn                  = "64512"
  advertised_route_priority = 100
  interface                 = "interface2"
}