#---------------------------------------------------
# Cloud Build GitHub Connection
#---------------------------------------------------

data "google_iam_policy" "cloudbuild_service_account_iam_policy" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = var.cloudbuild_iam_policy_members
  }
}

# Create a secret containing the personal access token and grant permissions to the Service Account
resource "google_secret_manager_secret" "github_token_secret" {
  project   = var.gcp_project
  secret_id = var.secret_manager_secret_id

  replication {
    auto {}
  }
  labels = {
    yor_name             = "github_token_secret"
    yor_trace            = "2fc94af2-0c94-499f-9d2b-f07b18a1c4c3"
    git_commit           = "a317e6e9327687ce7d6fe30dde2aeb82003bc00a"
    git_file             = "modules__cloudbuild_github_connection__main_tf"
    git_last_modified_at = "2025-08-19-14-20-10"
    git_last_modified_by = "laolu"
    git_modifiers        = "laolu"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = var.github_personal_access_token
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
  location = var.gcp_location
  name     = var.cloudbuild_github_connection_name

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [google_secret_manager_secret_iam_policy.policy]
}