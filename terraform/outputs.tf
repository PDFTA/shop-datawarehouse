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
