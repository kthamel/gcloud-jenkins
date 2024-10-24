resource "google_compute_network" "devo-vpc" {
  name                    = "devo-vpc"
  project                 = "kthamel-gcloud"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_subnetwork" "devo-vpc-subnet" {
  name          = "devo-vpc-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-west1"
  network       = google_compute_network.devo-vpc.self_link
  project       = google_compute_network.devo-vpc.project

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

resource "google_compute_firewall" "devo-vpc" {
  name     = "kthamel-vpc-dev-firewall-all"
  network  = google_compute_network.devo-vpc.self_link
  project  = google_compute_network.devo-vpc.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "jenkins-instance" {
  name         = "jenkins-instance"
  project      = "kthamel-gcloud"
  machine_type = "e2-micro"
  zone         = "us-west1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
  }
  labels = {
    name    = "devo-jenkins-gcp-instance"
    project = "kthamel-gcloud"
  }
}

output "self_link_value" {
  value = google_compute_instance.jenkins-instance.self_link
}
