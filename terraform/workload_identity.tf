# Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github_actions_pool" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"

  depends_on = [
    google_project_service.iam_api,
    google_project_service.iam_credentials_api,
    google_project_service.sts_api
  ]
}

# Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github_actions_provider" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository_owner_id != ''"
}
