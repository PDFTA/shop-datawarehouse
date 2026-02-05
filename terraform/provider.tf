terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "pdfta-shop-datawarehouse-tf"

  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcs_location
}
