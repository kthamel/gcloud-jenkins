resource "google_container_cluster" "gke-cluster" {
  name = "gke-cluster"
  location                 = "us-west1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  project                  = "kthamel-gcloud"
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.vpc-subnet.id
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
}

resource "google_container_node_pool" "gke-cluster-system-nodes" {
  name       = "gke-cluster-system-nodes"
  project    = "kthamel-gcloud"
  cluster    = google_container_cluster.gke-cluster.id
  node_count = 1

  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }

  node_config {
    preemptible  = true
    #machine_type = "e2-medium"
    machine_type = "t2d-standard-1"
    disk_size_gb = 20
    labels = {
      name = "system-node"
    }
  }
}

resource "google_container_node_pool" "gke-cluster-worker-nodes" {
  name       = "gke-cluster-worker-nodes"
  project    = "kthamel-gcloud"
  cluster    = google_container_cluster.gke-cluster.id
  node_count = 1

  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }

  node_config {
    preemptible  = true
    #machine_type = "e2-medium"
    machine_type = "t2d-standard-1"
    disk_size_gb = 20
    labels = {
      name = "worker-node"
    }
  }
}