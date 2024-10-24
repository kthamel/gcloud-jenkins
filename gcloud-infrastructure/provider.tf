terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.41.0"
    }
  }
}

provider "google" {
  project = "kthamel-gcloud"
  region  = "us-west1"
  zone    = "us-west1-b"
}
