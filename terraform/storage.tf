resource "google_storage_bucket" "pdfta_shop_bucket" {
  name     = "pfdta-shop-bucket"
  location = var.gcs_location
  project  = var.gcp_project_id

  # Uniform bucket-level access
  uniform_bucket_level_access = true

  # Versioning
  versioning {
    enabled = var.enable_versioning
  }

  # Lifecycle rules
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  # Force destroy for easier cleanup (set to false in production)
  force_destroy = var.force_destroy

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "shop-datawarehouse"
  }
}
