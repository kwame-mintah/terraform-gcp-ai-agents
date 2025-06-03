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

resource "google_cloudbuildv2_connection" "my-connection" {
  location = var.gcp_region
  name = "ai-agent-test-connection"

  github_config {
    app_installation_id = 69466052

    authorizer_credential {
      oauth_token_secret_version = "projects/325862358211/secrets/ai-agent-syntax-errors-github-oauthtoken-c808f1/versions/1"
    }
  }
}