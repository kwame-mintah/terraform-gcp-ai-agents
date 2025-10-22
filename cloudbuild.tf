#---------------------------------------------------
# Cloud Build (CI/CD)
#---------------------------------------------------

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
