#---------------------------------------------------
# Cloud Build Triggers
#---------------------------------------------------

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

# Chainlit repo
resource "google_cloudbuildv2_repository" "chainlit_repo" {
  name              = "python-chainlit-multi-agents-playground"
  location          = "europe-west1"
  parent_connection = module.cloudbuild_github_connection.github_connection_name
  remote_uri        = "https://github.com/kwame-mintah/python-chainlit-multi-agents-playground.git"
}

resource "google_cloudbuild_trigger" "chainlit_repo_main_trigger" {
  name        = "chainlit-main-branch-trigger"
  description = "Trigger to run on new pushes to main branch"
  location    = "europe-west1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.chainlit_repo.id
    push {
      branch       = "^main$"
      invert_regex = false
    }
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "chainlit_repo_pull_request_trigger" {
  name        = "chainlit-pull-request-trigger"
  description = "Pull request trigger to only run if /gcbrun is commented"
  location    = "europe-west1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.chainlit_repo.id
    pull_request {
      branch          = "^main$"
      invert_regex    = false
      comment_control = "COMMENTS_ENABLED"
    }
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
}
