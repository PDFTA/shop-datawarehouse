# Terraform Infrastructure

This directory contains Terraform configuration for managing GCP resources for the shop-datawarehouse project.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads) >= 1.0
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. GCP Project with billing enabled
4. Appropriate GCP permissions (Storage Admin or Owner)


## GitHub Actions

The `.github/workflows/terraform.yml` workflow automates Terraform operations:

- **Pull Requests**: Runs `terraform plan` and posts results as a comment
- **Main Branch**: Automatically applies changes on push

### Required GitHub Secrets

Configure these secrets in your GitHub repository:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Your Workload Identity Provider resource name
- `GCP_SERVICE_ACCOUNT`: Service account email (typically `github-actions-sa@PROJECT.iam.gserviceaccount.com`)
- `GCP_PROJECT_ID`: Your GCP project ID

### Service Account Permissions

The `github-actions-sa` service account has extremely permissive permissions to deploy any infrastructure. This is intentional for a toy project, but should not be used in production.

- **roles/editor** - Create, modify, and delete most GCP resources
- **roles/iam.securityAdmin** - Manage service accounts, IAM policies, and roles
- **roles/serviceusage.serviceUsageAdmin** - Enable and disable APIs

These broad permissions allow Terraform to manage any infrastructure without requiring manual permission updates for each new resource type.

### Setting up Workload Identity Federation

**Note:** Service accounts and Workload Identity Federation are now managed by Terraform. The initial setup requires bootstrapping:

1. **First-time setup** - Manually create a service account with necessary permissions to run Terraform:
   ```bash
   # Create the service account
   gcloud iam service-accounts create github-actions-sa \
     --display-name="GitHub Actions Service Account" \
     --project="${PROJECT_ID}"

   # Grant necessary permissions
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/editor"

   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/iam.securityAdmin"

   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/serviceusage.serviceUsageAdmin"
   ```

2. **Let Terraform manage everything else** - Once the service account exists with permissions, Terraform will:
   - Create and manage the Workload Identity Pool
   - Create and manage the Workload Identity Provider
   - Set up the binding between GitHub and the service account
   - Manage all other infrastructure

