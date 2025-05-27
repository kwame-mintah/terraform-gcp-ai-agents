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
