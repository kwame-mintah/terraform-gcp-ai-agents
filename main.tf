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

# // GKE Cluster terr
# data "google_compute_network" "default" {
#   name = "default"
# }

# data "google_compute_subnetwork" "default" {
#   name   = "default"
#   region = var.gcp_region
# }

# resource "google_container_cluster" "default" {
#   name = "example-autopilot-cluster"

#   location                 = var.gcp_region
#   enable_autopilot         = true
#   #enable_l4_ilb_subsetting = true

#   network    = data.google_compute_network.default.id
#   subnetwork = data.google_compute_subnetwork.default.id

#   #ip_allocation_policy {
#   #  stack_type                    = "IPV4_IPV6"
#   #  services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
#   #  cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
#   #}

#   # Set `deletion_protection` to `true` will ensure that one cannot
#   # accidentally delete this instance by use of Terraform.
#   deletion_protection = false
# }

# # https://cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster-using-terraform#review_the_terraform_files
# resource "kubernetes_deployment_v1" "default" {
#   metadata {
#     name = "ai-agent-deployment"
#   }

#   spec {
#     selector {
#       match_labels = {
#         app = "ai-agent"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "ai-agent"
#         }
#       }

#       spec {
#         container {
#           image = "europe-west2-docker.pkg.dev/syntax-errors/ai-agent-docker-image-id-1/agent-image@sha256:aaf8f10fdad51f6ad14c09e1970f05fc5af998b7ea5c606abf0dbb69387f5c9a"
#           name  = "ai-agent-container"
#           port {
#             container_port = 8080
#             name           = "ai-agent-svc"
#           }
#         }

#       }
#     }
#   }
# }

# resource "kubernetes_service_v1" "default" {
#   metadata {
#     name = "ai-agent-loadbalancer"
#     annotations = {
#       "networking.gke.io/load-balancer-type" = "Internal" # Remove to create an external loadbalancer
#     }
#   }

#   spec {
#     selector = {
#       app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
#     }

#     port {
#       port        = 80
#       target_port = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].name
#     }

#     type = "LoadBalancer"
#   }

#   depends_on = [time_sleep.wait_service_cleanup]
# }

# # Provide time for Service cleanup
# resource "time_sleep" "wait_service_cleanup" {
#   depends_on = [google_container_cluster.default]

#   destroy_duration = "180s"
# }
