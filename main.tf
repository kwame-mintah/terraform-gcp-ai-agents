# Data source to get project details
data "google_project" "project" {}

# Creates artifact register to store docker images
resource "google_artifact_registry_repository" "ai_agent_docker_registry" {
  format        = "DOCKER"
  repository_id = "${var.environment}-ai-agent-docker-images"
  description   = "Docker registry for AI agent application"
  location      = var.gcp_region
  labels = {
    "environment"        = var.environment
    git_commit           = "a317e6e9327687ce7d6fe30dde2aeb82003bc00a"
    git_file             = "main_tf"
    git_last_modified_at = "2025-10-22-18-37-50"
    git_last_modified_by = "kwame_mintah"
    git_modifiers        = "37197235kwame-mintah__kwame_mintah__laoluanimashaun"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
    yor_name             = "ai_agent_docker_registry"
    yor_trace            = "e98a609e-1970-45b9-a2e9-05be327afa2e"
  }
}

module "cloudbuild_github_connection" {
  source                            = "./modules/cloudbuild_github_connection"
  gcp_project                       = var.gcp_project
  gcp_location                      = "europe-west1"
  cloudbuild_github_connection_name = "${var.environment}-ai-agent-github-connection"
  cloudbuild_iam_policy_members     = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  github_app_installation_id        = 69466052
  secret_manager_secret_id          = "${var.environment}-github-connection-secrets"
  github_personal_access_token      = yamldecode(data.sops_file.secrets.raw).github.github_personal_token
}

