# Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.cloud_run_region
  project       = var.gcp_project_id
  repository_id = "shop-datawarehouse"
  description   = "Docker repository for shop-datawarehouse"
  format        = "DOCKER"
}
