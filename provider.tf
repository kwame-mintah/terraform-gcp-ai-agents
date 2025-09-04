# Configure the GCP Provider
provider "google" {
  project        = var.gcp_project
  region         = var.gcp_region
  zone           = var.gcp_zone
  default_labels = var.gcp_default_labels
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#in-cluster-config
# TODO configure

//data "google_client_config" "default" {}
