#---------------------------------------------------
# Secrets
#---------------------------------------------------

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "./secrets.enc.yaml"
}

# Hugging face secret(s)
resource "google_secret_manager_secret" "hugging_face_secrets" {
  project   = var.gcp_project
  secret_id = "${var.environment}-hugging-face-api-token"

  replication {
    auto {}
  }
  labels = {
    git_commit           = "b01b3566cd3f152d0549df88e26847296f6b3dfb"
    git_file             = "secrets_tf"
    git_last_modified_at = "2025-10-22-18-37-50"
    git_last_modified_by = "kwame_mintah"
    git_modifiers        = "kwame_mintah__laolu"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
    yor_name             = "hugging_face_secrets"
    yor_trace            = "3a651cc9-e97b-48fa-a222-6a958f9ceebd"
  }
}

resource "google_secret_manager_secret_version" "hugging_face_secret_version" {
  secret      = google_secret_manager_secret.hugging_face_secrets.id
  secret_data = yamldecode(data.sops_file.secrets.raw).models.hugging_face_api_token
}


# Gemini secret(s)
resource "google_secret_manager_secret" "gemini_secrets" {
  project   = var.gcp_project
  secret_id = "${var.environment}-gemini-api-token"

  replication {
    auto {}
  }
  labels = {
    git_commit           = "b01b3566cd3f152d0549df88e26847296f6b3dfb"
    git_file             = "secrets_tf"
    git_last_modified_at = "2025-10-22-18-37-50"
    git_last_modified_by = "kwame_mintah"
    git_modifiers        = "kwame_mintah__laolu"
    git_org              = "kwame-mintah"
    git_repo             = "terraform-gcp-ai-agents"
    yor_name             = "gemini_secrets"
    yor_trace            = "3a651cc9-e97b-48fa-a222-6a958f9ceebd"
  }
}

# creates actual secrets
resource "google_secret_manager_secret_version" "gemini_api_key_secret_version" {
  secret      = google_secret_manager_secret.gemini_secrets.id
  secret_data = yamldecode(data.sops_file.secrets.raw).models.gemini_api_token
}
