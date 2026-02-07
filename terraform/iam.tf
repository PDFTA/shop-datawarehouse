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
# These permissions allow GitHub Actions to build and deploy the application

# Grant GitHub Actions SA write access to Artifact Registry for pushing images
resource "google_artifact_registry_repository_iam_member" "github_actions_ar_writer" {
  location   = google_artifact_registry_repository.docker_repo.location
  project    = var.gcp_project_id
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant GitHub Actions SA permission to deploy Cloud Run services
resource "google_project_iam_member" "github_actions_cloud_run_developer" {
  project = var.gcp_project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Grant GitHub Actions SA permission to act as service accounts (required for Cloud Run deployment)
resource "google_project_iam_member" "github_actions_sa_user" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
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
  member   = "allUsers"
}
