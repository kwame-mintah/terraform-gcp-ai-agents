
data "google_artifact_registry_docker_image" "my_image" {
  location      = google_artifact_registry_repository.ai_agent_docker_image_1.location
  repository_id = google_artifact_registry_repository.ai_agent_docker_image_1.repository_id
  image_name    = "agent-image"
}

module "cluster" {
  source                            = "./modules/cluster"
  gcp_project                       = var.gcp_project
  gcp_region                        = var.gcp_region
}

data "google_client_config" "default" {}


provider "kubernetes" {
  host = "https://${module.cluster.gke_cluster.endpoint}"

  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    module.cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  )
}

data "sops_file" "hugging_face_secrets" {
  source_file = "./hugging-face-secret.enc.yaml"
}


# # https://cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster-using-terraform#review_the_terraform_files
# Deploy your container
resource "kubernetes_deployment_v1" "ai_agent" {
  metadata {
    name = "ai-agent-deployment"
    labels = {
      app = "ai-agent"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "ai-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "ai-agent"
        }
      }

      spec {
        container {
          name  = "ai-agent-container"
          image = data.google_artifact_registry_docker_image.my_image.self_link

          port {
            container_port = 8080
          }
          env {
            name = "HF_TOKEN"
            value_from {
              secret_key_ref {
                name = "hugging-face-token"
                key  = "HF_TOKEN"
              }
            }
          }

          env {
            name  = "USE_HUGGING_FACE_INTERFACE"
            value = true
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [spec[0].template[0].spec[0].container[0].image] # Terraform will create this cluster but never update or delete it
  }
}

resource "kubernetes_service_v1" "ai_agent" {
  metadata {
    name = "example-hello-app-loadbalancer"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.ai_agent.spec[0].selector[0].match_labels.app
    }

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.ai_agent.spec[0].template[0].spec[0].container[0].port[0].container_port
    }

    type = "LoadBalancer"
  }
}

# Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "hugging_face_secrets" {
  project   = var.gcp_project
  secret_id = "syntax-errors-ai-agent-secret-module-hf"

  replication {
    auto {}
  }
  labels = {
    git_commit           = "438a95e0ee681ebe85f86f3a98628f087eb272c2"
    git_file             = "main_tf"
    git_last_modified_at = "2025-09-17-08-52-34"
    git_last_modified_by = "laolu"
    git_modifiers        = "laolu"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
    yor_name             = "hugging_face_secrets"
    yor_trace            = "3a651cc9-e97b-48fa-a222-6a958f9ceebd"
  }
}


# creates actual secrets
resource "google_secret_manager_secret_version" "hugging_face_secret_version" {
  secret      = google_secret_manager_secret.hugging_face_secrets.id
  secret_data = data.sops_file.hugging_face_secrets.data.token
}

resource "kubernetes_secret_v1" "hugging_face_token" {
  metadata {
    name = "hugging-face-token"
  }

  data = {
    "HF_TOKEN" = google_secret_manager_secret_version.hugging_face_secret_version.secret_data
  }
}
