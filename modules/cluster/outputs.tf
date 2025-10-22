output "gke_cluster" {
  description = <<-EOF
  All the attributes related to the created cluster.

EOF

  value = google_container_cluster.gke
}