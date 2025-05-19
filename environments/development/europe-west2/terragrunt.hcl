# Terragrunt will copy the Terraform files from the locations specified into this directory
terraform {
  source = "../../.."
}

locals {
  environment = "dev"
}

include {
  path = find_in_parent_folders()
}

# These are inputs that need to be passed for the terragrunt configuration
inputs = {
  env_prefix = "${local.environment}"
}
