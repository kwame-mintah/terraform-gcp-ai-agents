output "gcp_project_number" {
  description = <<-EOF
    The numeric identifier of the project.

EOF

  value = data.google_project.project.number
}