# Service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "shop-datawarehouse-sa"
  display_name = "Shop Data Warehouse Cloud Run Service Account"
  project      = var.gcp_project_id
}

# Grant the service account access to read from the GCS bucket
resource "google_storage_bucket_iam_member" "cloud_run_bucket_access" {
  bucket = google_storage_bucket.pdfta_shop_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Cloud Run service
resource "google_cloud_run_v2_service" "shop_datawarehouse" {
  name     = "shop-datawarehouse"
  location = var.cloud_run_region
  project  = var.gcp_project_id

  template {
    service_account = google_service_account.cloud_run_sa.email

    containers {
      image = var.cloud_run_image

      ports {
        container_port = 8080
      }

      env {
        name  = "GCS_BUCKET_NAME"
        value = google_storage_bucket.pdfta_shop_bucket.name
      }

      env {
        name  = "GCP_PROJECT_ID"
        value = var.gcp_project_id
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      startup_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 0
        timeout_seconds       = 1
        period_seconds        = 3
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 0
        timeout_seconds       = 1
        period_seconds        = 10
        failure_threshold     = 3
      }
    }

    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_storage_bucket_iam_member.cloud_run_bucket_access
  ]
}

# IAM policy to allow public access (optional - comment out for private access)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count = var.cloud_run_allow_public_access ? 1 : 0

  name     = google_cloud_run_v2_service.shop_datawarehouse.name
  location = google_cloud_run_v2_service.shop_datawarehouse.location
  project  = var.gcp_project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
