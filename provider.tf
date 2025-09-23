# Configure the GCP Provider
provider "google" {
  project        = var.gcp_project
  region         = var.gcp_region
  zone           = var.gcp_zone
  default_labels = var.gcp_default_labels
}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context_cluster = "gke_${data.google_project.project.project_id}_${var.gcp_region}_${google_container_cluster.gke.name}"
}
