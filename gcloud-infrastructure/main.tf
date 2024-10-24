resource "google_compute_network" "vpc" {
  name                    = "vpc"
  project                 = "kthamel-gcloud"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_subnetwork" "vpc-subnet" {
  name          = "vpc-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-west1"
  network       = google_compute_network.vpc.self_link
  project       = google_compute_network.vpc.project

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

resource "google_compute_firewall" "vpc" {
  name     = "kthamel-vpc-dev-firewall-all"
  network  = google_compute_network.vpc.self_link
  project  = google_compute_network.vpc.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["89.154.174.89/32"] 
}
