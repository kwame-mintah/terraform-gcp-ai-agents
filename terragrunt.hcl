# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform/OpenTofu that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  project_name   = "terraform-gcp-template"
  gcp_project_id = read_terragrunt_config("environment.hcl").locals.project_id
  gcp_region     = read_terragrunt_config("environment.hcl").locals.region
  gcp_zone       = read_terragrunt_config("environment.hcl").locals.zone
  # Could use `find_in_parent_folders()` if file was in the parent directory.
  environment      = read_terragrunt_config("environment.hcl")
  environment_name = local.environment.locals.environment_name
}

# Generate the GCP Provider configuration
# When using this terragrunt config, terragrunt will generate the file "provider.tf" with the google provider block before
# calling to terraform. Note that this will overwrite the `provider.tf` file if it already exists.

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project        = "${local.gcp_project_id}"
  region         = "${local.gcp_region}"
  zone           = "${local.gcp_zone}"
  add_terraform_attribution_label               = true
  terraform_attribution_label_addition_strategy = "PROACTIVE"
}
EOF
}


# Generate the Remote GCP Bucket for store the state file.

remote_state {
  backend = "gcs"
  config = {
    project  = local.gcp_project_id
    location = local.gcp_region
    bucket   = "tfstate-${local.project_name}-${local.gcp_region}-${local.environment_name}"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"

    gcs_bucket_labels = {
      "project_name" = "${local.project_name}"
    }
  }
  generate = {
    path      = "backend_override.tf"
    if_exists = "overwrite_terragrunt"
  }
}


#-------------------------------------------------------------------------------------------
# GLOBAL INPUTS
# These inputs apply to all terragrunt configurations in this subfolder. 
# There will be automatically merged into the child `terragrunt.hcl` using `include {}` block.
#-------------------------------------------------------------------------------------------

inputs = {
  gcp_region   = "${local.gcp_region}"
  gcp_project  = "${local.gcp_project_id}"
  gcp_zone     = "${local.gcp_zone}"
  project_name = "${local.project_name}"
}