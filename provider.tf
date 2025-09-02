# Configure the GCP Provider
provider "google" {
  project        = var.gcp_project
  region         = var.gcp_region
  zone           = var.gcp_zone
  default_labels = var.gcp_default_labels
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#in-cluster-config
# TODO configure

data "google_client_config" "default" {}

provider "kubernetes" {
  # host = "https://${google_container_cluster.gke.endpoint}"
  # token                  = data.google_client_config.default.access_token
  # cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  # config_path    = "~/.kube/config"
  # config_context = "my-context"
}
