# GCS Bucket outputs
output "bucket_name" {
  description = "Name of the created GCS bucket"
  value       = google_storage_bucket.pdfta_shop_bucket.name
}

output "bucket_url" {
  description = "URL of the created GCS bucket"
  value       = google_storage_bucket.pdfta_shop_bucket.url
}

output "bucket_self_link" {
  description = "Self link of the created GCS bucket"
  value       = google_storage_bucket.pdfta_shop_bucket.self_link
}

# Cloud Run outputs
output "cloud_run_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.shop_datawarehouse.uri
}

output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.shop_datawarehouse.name
}

output "cloud_run_service_account" {
  description = "Service account email for Cloud Run"
  value       = google_service_account.cloud_run_sa.email
}

# GitHub Actions outputs
output "github_actions_service_account" {
  description = "Service account email for GitHub Actions"
  value       = google_service_account.github_actions_sa.email
}

# Artifact Registry outputs
output "artifact_registry_repository" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${google_artifact_registry_repository.docker_repo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

# Workload Identity outputs
output "workload_identity_provider" {
  description = "Workload Identity Provider for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github_actions_provider.name
}

output "workload_identity_pool" {
  description = "Workload Identity Pool for GitHub Actions"
  value       = google_iam_workload_identity_pool.github_actions_pool.name
}

