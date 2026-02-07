# Cloud Run service
resource "google_cloud_run_v2_service" "shop_datawarehouse" {
  name               = "shop-datawarehouse"
  location           = var.cloud_run_region
  project            = var.gcp_project_id
  deletion_protection = false

  template {
    service_account = google_service_account.cloud_run_sa.email

    containers {
      image = var.cloud_run_image != "" ? var.cloud_run_image : "${google_artifact_registry_repository.docker_repo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/api:latest"

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
      min_instance_count = 0
      max_instance_count = 1
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
