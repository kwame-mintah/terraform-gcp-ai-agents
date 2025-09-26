# Data source to get project details
data "google_project" "project" {}

data "sops_file" "encrypted_secrets" {
  source_file = "secrets.enc.yaml"
}

# Creates artifact register to store docker images
resource "google_artifact_registry_repository" "ai_agent_docker_image_1" {
  format        = "DOCKER"
  repository_id = "ai-agent-docker-image-id-1"
  description   = "Docker registry for AI agent application"
  location      = var.gcp_region
  labels = {
    "environment"        = var.environment
    git_commit           = "c6e78a9a04a7158aeca11d11edca7b9420a74593"
    git_file             = "main_tf"
    git_last_modified_at = "2025-07-01-14-16-20"
    git_last_modified_by = "37197235kwame-mintah"
    git_modifiers        = "37197235kwame-mintah__laoluanimashaun"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
    yor_name             = "ai_agent_docker_image_1"
    yor_trace            = "e98a609e-1970-45b9-a2e9-05be327afa2e"
  }
}

module "cloudbuild_github_connection" {
  source                            = "./modules/cloudbuild_github_connection"
  gcp_project                       = var.gcp_project
  gcp_location                      = "europe-west1"
  cloudbuild_github_connection_name = "ai-agent-github-connection"
  cloudbuild_iam_policy_members     = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  github_app_installtion_id         = 69466052
  secret_manager_secret_id          = "syntax-errors-ai-agent-secret-module"
  sops_source_file                  = "./secrets.enc.yaml"
}

# creates data object for new iam policy
data "google_iam_policy" "cloudbuild_service_account_iam_policy" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}


resource "google_cloudbuildv2_repository" "hugging_face_smolagents_playground_repo" {
  name              = "hugging-face-smolagents-playground"
  location          = "europe-west1"
  parent_connection = module.cloudbuild_github_connection.github_connection_name
  remote_uri        = "https://github.com/kwame-mintah/hugging-face-smolagents-playground.git"
}

resource "google_cloudbuild_trigger" "hugging_face_smolagents_playground_repo_main_trigger" {
  name        = "hugging-face-smolagents-main-branch-trigger"
  description = "Trigger to run on new pushes to main branch"
  location    = "europe-west1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.hugging_face_smolagents_playground_repo.id
    push {
      branch       = "^main$"
      invert_regex = false
    }
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "hugging_face_smolagents_playground_repo_pull_request_trigger" {
  name        = "hugging-face-smolagents-pull-request-trigger"
  description = "Pull request trigger to only run if /gcbrun is commented"
  location    = "europe-west1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.hugging_face_smolagents_playground_repo.id
    pull_request {
      branch          = "^main$"
      invert_regex    = false
      comment_control = "COMMENTS_ENABLED"
    }
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
}


# Create cloud build service account
resource "google_service_account" "cloudbuild_service_account" {
  display_name = "${data.google_project.project.name} CloudBuild service account"
  account_id   = "cloudbuild-service-account"
  description  = "The service account needed for cloud build runs."
}

# Allow cloud build service account to assume another role
resource "google_project_iam_member" "cloudbuild_act_as_role" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# Allow cloud build service account to write logs during builds
resource "google_project_iam_member" "cloudbuild_logs_writer_role" {
  project = data.google_project.project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# Allow cloud build service account upload to artifact registry 
resource "google_project_iam_member" "cloudbuild_upload_artifacts_role" {
  project = data.google_project.project.project_id
  role    = "roles/artifactregistry.createOnPushWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# // GKE Cluster
data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = var.gcp_region
}

data "google_artifact_registry_docker_image" "my_image" {
  location      = google_artifact_registry_repository.ai_agent_docker_image_1.location
  repository_id = google_artifact_registry_repository.ai_agent_docker_image_1.repository_id
  image_name    = "agent-image"
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

data "google_client_config" "default" {}

provider "kubernetes" {
  host = "https://${google_container_cluster.gke.endpoint}"

  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke.master_auth[0].cluster_ca_certificate
  )
}

data "sops_file" "hugging_face_secrets" {
  source_file = "./hugging-face-secret.enc.yaml"
}

resource "kubernetes_secret_v1" "hugging_face_token" {
  metadata {
    name = "hugging-face-token"
  }

  data = {
    "HF_TOKEN" = google_secret_manager_secret_version.hugging_face_secret_version.secret_data
  }
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
          image = data.google_artifact_registry_docker_image.hello_app.self_link
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
      target_port = kubernetes_deployment_v1.ai_agent.spec[0].template[0].spec[0].container[0].port[0].name
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

data "google_artifact_registry_docker_image" "hello_app" {
  location      = "europe-west2"
  repository_id = "hello-repo"
  image_name    = "hello-app"
}


//gcloud container clusters get-credentials ai-agent-cluster --region europe-west2 --project syntax-errors