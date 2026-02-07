# Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github_actions_pool" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

# Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github_actions_provider" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "Workload Identity Pool Provider for GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  # Optional: Add repository condition to restrict access
  attribute_condition = var.github_repository != "" ? "attribute.repository==\"${var.github_repository}\"" : null
}

# Bind the GitHub Actions service account to the workload identity pool
resource "google_service_account_iam_member" "github_actions_workload_identity_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions_pool.name}/attribute.repository/${var.github_repository}"

  depends_on = [google_iam_workload_identity_pool_provider.github_actions_provider]
}
