# Data source to get project details
data "google_project" "project" {}

resource "google_artifact_registry_repository" "ai_agent_docker_image_1" {
  format        = "DOCKER"
  repository_id = "ai-agent-docker-image-id-1"
  description   = "example docker repository"
  location      = var.gcp_region
  labels = {
    "environment" = var.environment
  }
}

# Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
    project = var.gcp_project
    secret_id = "syntax-errors-ai-agent-secret"

    replication {
        auto {}
    }
}

# creates actual secret s
resource "google_secret_manager_secret_version" "github_token_secret_version" {
    secret = google_secret_manager_secret.github_token_secret.id
    secret_data = "TEST_SECRET" # TODO How to safely inject secret
}

# creates data object for new iam policy
data "google_iam_policy" "serviceagent_secretAccessor" {
    binding {
        role = "roles/secretmanager.secretAccessor"
        members = ["serviceAccount:service-325862358211@gcp-sa-cloudbuild.iam.gserviceaccount.com"] # TODO Should service account be hardcoded
        #members = ["serviceAccount:laolu-terraform-development@syntax-errors.iam.gserviceaccount.com"] # TODO Should service account be hardcoded

    }
}

# creates actual iam policy giving service account access to secret
resource "google_secret_manager_secret_iam_policy" "policy" {
  project = google_secret_manager_secret.github_token_secret.project
  secret_id = google_secret_manager_secret.github_token_secret.secret_id
  policy_data = data.google_iam_policy.serviceagent_secretAccessor.policy_data
}

# creates connection from cloudbuild to github
// Create the GitHub connection
resource "google_cloudbuildv2_connection" "my_connection" {
    project = var.gcp_project
    location = var.gcp_region
    name = "ai-agent-test-connection"

    github_config {
        app_installation_id = 69466052
        authorizer_credential {
            oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
        }
    }
    depends_on = [google_secret_manager_secret_iam_policy.policy]
}