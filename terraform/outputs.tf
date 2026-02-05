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
