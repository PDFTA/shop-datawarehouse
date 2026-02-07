# Enable required GCP APIs
# These APIs must be enabled before other resources can be created

# Cloud Run - Required for deploying the application
resource "google_project_service" "cloud_run_api" {
  project = var.gcp_project_id
  service = "run.googleapis.com"

  disable_on_destroy = false
}

# Artifact Registry - Required for storing Docker images
resource "google_project_service" "artifact_registry_api" {
  project = var.gcp_project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

# IAM - Required for managing service accounts and permissions
resource "google_project_service" "iam_api" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

# IAM Credentials - Required for Workload Identity Federation
resource "google_project_service" "iam_credentials_api" {
  project = var.gcp_project_id
  service = "iamcredentials.googleapis.com"

  disable_on_destroy = false
}

# Cloud Resource Manager - Required for project-level IAM bindings
resource "google_project_service" "cloud_resource_manager_api" {
  project = var.gcp_project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy = false
}

# Security Token Service - Required for Workload Identity Federation
resource "google_project_service" "sts_api" {
  project = var.gcp_project_id
  service = "sts.googleapis.com"

  disable_on_destroy = false
}
