#---------------------------------------------------
# Kubernetes Deployments
#---------------------------------------------------

data "google_client_config" "default" {}
data "google_artifact_registry_docker_image" "chainlit_multi_agents_docker_image" {
  location      = google_artifact_registry_repository.ai_agent_docker_registry.location
  repository_id = google_artifact_registry_repository.ai_agent_docker_registry.repository_id
  image_name    = "python-chainlit-multi-agents-playground"
}

module "cluster" {
  source     = "./modules/cluster"
  gcp_region = var.gcp_region
}

provider "kubernetes" {
  host = "https://${module.cluster.gke_cluster.endpoint}"

  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    module.cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  )
}

# Deploy AI agent workload
# https://cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster-using-terraform#review_the_terraform_files
resource "kubernetes_deployment_v1" "ai_agent" {
  metadata {
    name = "${var.environment}-ai-agent-deployment"
    labels = {
      app = "${var.environment}-ai-agent"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "${var.environment}-ai-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.environment}-ai-agent"
        }
      }

      spec {
        container {
          name  = "${var.environment}-ai-agent-container"
          image = data.google_artifact_registry_docker_image.chainlit_multi_agents_docker_image.self_link

          port {
            container_port = 8000
          }


          env {
            name = "GOOGLE_GEMINI_API_KEY"
            value_from {
              secret_key_ref {
                name = "gemini-api-key"
                key  = "GEMINI_API_KEY"
              }
            }
          }

          env {
            name  = "GOOGLE_GEMINI_LLM_MODEL"
            value = "gemini-2.5-flash"
          }

          env {
            name  = "LLM_INFERENCE_PROVIDER"
            value = "gemini"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [spec[0].template[0].spec[0].container[0].image] # Ignored as initial docker image will change with future deployment(s)
  }
}

resource "kubernetes_service_v1" "ai_agent" {
  metadata {
    name = "${var.environment}-ai-agent-loadbalancer"
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

resource "kubernetes_secret_v1" "gemini_api_key" {
  metadata {
    name = "gemini-api-key"
  }

  data = {
    "GEMINI_API_KEY" = google_secret_manager_secret_version.gemini_api_key_secret_version.secret_data
  }
}

resource "kubernetes_secret_v1" "hugging_face_token" {
  metadata {
    name = "hugging-face-token"
  }

  data = {
    "HF_TOKEN" = google_secret_manager_secret_version.hugging_face_secret_version.secret_data
  }
}