variable "gcp_project" {
    type = string
}

variable "sops_source_file" {
    type = string
}

variable "gcp_location" {
    type = string
}

variable "cloudbuild_github_connection_name" {
  type = string
}

variable "cloudbuild_iam_policy_members" {
  type = list(string)
  default = [ ]
}

variable "github_app_installtion_id" {
    type = number
}

variable "secret_manager_secret_id" {
  type = string
}