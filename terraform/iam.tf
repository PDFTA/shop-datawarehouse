# ==============================================================================
# Cloud Run Service Account IAM Bindings
# ==============================================================================
# These permissions allow the Cloud Run application to access resources

# Grant Cloud Run SA read access to GCS bucket for querying parquet files
resource "google_storage_bucket_iam_member" "cloud_run_bucket_access" {
  bucket = google_storage_bucket.pdfta_shop_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# ==============================================================================
# GitHub Actions Service Account IAM Bindings
# ==============================================================================
# These permissions allow GitHub Actions to manage all infrastructure via Terraform
# IMPORTANT: These are extremely permissive to allow deploying any infrastructure

# Grant Editor role - Can create, modify, and delete most GCP resources
resource "google_project_iam_member" "github_actions_editor" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant IAM Security Admin - Can manage service accounts, IAM policies, and roles
resource "google_project_iam_member" "github_actions_iam_admin" {
  project = var.gcp_project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Service Usage Admin - Can enable and disable APIs
resource "google_project_iam_member" "github_actions_service_usage_admin" {
  project = var.gcp_project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant Artifact Registry Writer - Push Docker images
# Note: Editor role does NOT include Artifact Registry permissions, so we need this explicitly
resource "google_artifact_registry_repository_iam_member" "github_actions_ar_writer" {
  location   = google_artifact_registry_repository.docker_repo.location
  project    = var.gcp_project_id
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# ==============================================================================
# Public Access IAM Bindings
# ==============================================================================
# Optional: Allow public access to Cloud Run service

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count = var.cloud_run_allow_public_access ? 1 : 0

  name     = google_cloud_run_v2_service.shop_datawarehouse.name
  location = google_cloud_run_v2_service.shop_datawarehouse.location
  project  = var.gcp_project_id
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}
