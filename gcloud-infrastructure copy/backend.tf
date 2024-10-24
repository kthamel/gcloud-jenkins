terraform {
  backend "gcs" {
    bucket = "be-gcloud-micro"
    prefix = "terraform-state"
  }
}
