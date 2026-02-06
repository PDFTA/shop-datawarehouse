# Enable required GCP APIs
resource "google_project_service" "cloud_run_api" {
  project = var.gcp_project_id
  service = "run.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  project = var.gcp_project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "iam_api" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"

  disable_on_destroy = false
}
