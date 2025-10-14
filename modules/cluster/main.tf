data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = var.gcp_region
}

# Minimal Autopilot GKE Cluster
resource "google_container_cluster" "gke" {
  name             = "ai-agent-cluster"
  location         = var.gcp_region
  enable_autopilot = true

  network    = data.google_compute_network.default.id
  subnetwork = data.google_compute_subnetwork.default.id

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}