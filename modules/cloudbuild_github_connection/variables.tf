variable "gcp_project" {
  description = <<-EOF
  The ID of the project in which the resource belongs. If it is not provided,
  the provider project is used.

EOF

  type = string
}

variable "gcp_location" {
  description = <<-EOF
  The location for the resource.

EOF

  type = string
}

variable "cloudbuild_github_connection_name" {
  description = <<-EOF
  Immutable. The resource name of the connection.

EOF

  type = string
}

variable "cloudbuild_iam_policy_members" {
  description = <<-EOF
  An array of identities that will be granted the privilege for role(s).

EOF

  type    = list(string)
  default = []
}

variable "github_app_installation_id" {
  description = <<-EOF
  GitHub App installation id.

EOF

  type = number
}

variable "github_personal_access_token" {
  description = <<-EOF
  The access token of the personal access token in GitHub.

EOF

  type = string
}

variable "secret_manager_secret_id" {
  description = <<-EOF
  Labels that will be applied to all resources with a top level labels field or a labels
  field nested inside a top level metadata field.

EOF

  type = string
}