terraform {
  required_version = ">= 1.5.7, <= 1.9.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.6.0"
    }
  }
}
