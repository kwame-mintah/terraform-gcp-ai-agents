data "sops_file" "encrypted_secrets" {
  source_file = var.sops_source_file
}

# Create a secret containing the personal access token and grant permissions to the Service Agent
resource "google_secret_manager_secret" "github_token_secret" {
  project   = var.gcp_project
  secret_id = var.secret_manager_secret_id

  replication {
    auto {}
  }
  labels = {
    yor_name  = "github_token_secret"
    yor_trace = "2fc94af2-0c94-499f-9d2b-f07b18a1c4c3"
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
    members = var.cloudbuild_iam_policy_members
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
  location = var.gcp_location
  name     = var.cloudbuild_github_connection_name

  github_config {
    app_installation_id = var.github_app_installtion_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token_secret_version.id
    }
  }
  depends_on = [google_secret_manager_secret_iam_policy.policy]
}