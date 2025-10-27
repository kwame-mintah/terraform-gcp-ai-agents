terraform {
  required_version = ">= 1.5.7, <= 1.9.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.6.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
}
