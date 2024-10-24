data "google_client_openid_userinfo" "me" {}

resource "google_compute_network" "vpc-dev" {
  name                    = "vpc-dev"
  project                 = "kthamel-gcloud"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_subnetwork" "vpc-dev-subnet-public" {
  name          = "vpc-dev-subnet-public"
  ip_cidr_range = "172.16.0.0/16"
  region        = "us-west1"
  network       = google_compute_network.vpc-dev.self_link
  project       = google_compute_network.vpc-dev.project
}

resource "google_compute_firewall" "vpc-dev-firewall-all" {
  name     = "vpc-dev-firewall-all"
  network  = google_compute_network.vpc-dev.name
  project  = google_compute_network.vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["89.154.174.89/32"] // Have to change into /32 public ip
}

resource "google_compute_firewall" "vpc-dev-firewall-icmp" {
  name     = "vpc-dev-firewall-icmp"
  network  = google_compute_network.vpc-dev.name
  project  = google_compute_network.vpc-dev.project
  priority = 101

  allow {
    protocol = "icmp"
  }

  source_ranges = ["89.154.174.89/32"]
}

resource "tls_private_key" "kthamel-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "kthamel-ssh-pem" {
  content         = tls_private_key.kthamel-ssh.private_key_pem
  filename        = "kthamel-key"
  file_permission = "0600"
}

resource "google_compute_instance" "kthamel-instance-dev" {
  name         = "jenkins-dev"
  project      = "kthamel-gcloud"
  machine_type = "e2-standard-2"
  zone         = "us-west1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc-dev-subnet-public.self_link
    access_config {}
  }

  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.kthamel-ssh.public_key_openssh}"
  }

  labels = {
    name    = "jenkins-instance-dev"
    project = "kthamel-gcloud"
  }
}
