# Service account for GitHub Actions CI/CD pipeline
resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions CI/CD pipeline"
  project      = var.gcp_project_id

  depends_on = [
    google_project_service.iam_api
  ]
}

# Service account for Cloud Run application runtime
resource "google_service_account" "cloud_run_sa" {
  account_id   = "shop-datawarehouse-sa"
  display_name = "Shop Data Warehouse Cloud Run Service Account"
  description  = "Service account for Cloud Run application runtime"
  project      = var.gcp_project_id

  depends_on = [
    google_project_service.iam_api
  ]
}
