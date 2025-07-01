# Data source to get project details
data "google_project" "project" {}

data "sops_file" "encrypted_secrets" {
  source_file = "secrets.enc.yaml"
}

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

# Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
  project   = var.gcp_project
  secret_id = "syntax-errors-ai-agent-secret"

  replication {
    auto {}
  }
  labels = {
    git_commit           = "797b3a11d2b4abaa06970937302428e5c686361b"
    git_file             = "main_tf"
    git_last_modified_at = "2025-06-24-15-16-31"
    git_last_modified_by = "laoluanimashaun"
    git_modifiers        = "laoluanimashaun"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
    yor_name             = "github_token_secret"
    yor_trace            = "d5a21a61-cf27-467d-9ebf-9ef645e2f788"
  }
}

# creates actual secrets
resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = data.sops_file.encrypted_secrets.data.github_personal_token
}

# creates data object for new iam policy
data "google_iam_policy" "cloudbuild_service_account_iam_policy" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-325862358211@gcp-sa-cloudbuild.iam.gserviceaccount.com"] # TODO Should service account be hardcoded
  }
}

# creates actual iam policy giving service account access to secret
resource "google_secret_manager_secret_iam_policy" "policy" {
  project     = google_secret_manager_secret.github_token_secret.project
  secret_id   = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.cloudbuild_service_account_iam_policy.policy_data
}

# creates connection from cloudbuild to github
resource "google_cloudbuildv2_connection" "cloudbuild_github_project_connection" {
  project  = var.gcp_project
  location = var.gcp_region
  name     = "ai-agent-github-connection"

  github_config {
    app_installation_id = 69466052
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [google_secret_manager_secret_iam_policy.policy]
}
