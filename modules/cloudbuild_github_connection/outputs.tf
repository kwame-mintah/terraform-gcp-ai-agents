output "github_connection_name" {
  description = <<-EOF
  The name of the GitHub cloudbuild connection.

EOF

  value = google_cloudbuildv2_connection.cloudbuild_github_project_connection.name
}