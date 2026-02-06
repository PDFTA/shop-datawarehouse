# Terraform Infrastructure

This directory contains Terraform configuration for managing GCP resources for the shop-datawarehouse project.

## Resources

- **GCS Bucket**: `pfdta-shop-bucket` - Google Cloud Storage bucket for data warehousing

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads) >= 1.0
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. GCP Project with billing enabled
4. Appropriate GCP permissions (Storage Admin or Owner)

## Setup

Local setup is only for development. All terraform configuration changes should occur using the github actions.

## GitHub Actions

The `.github/workflows/terraform.yml` workflow automates Terraform operations:

- **Pull Requests**: Runs `terraform plan` and posts results as a comment
- **Main Branch**: Automatically applies changes on push

### Required GitHub Secrets

Configure these secrets in your GitHub repository:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Your Workload Identity Provider resource name
- `GCP_SERVICE_ACCOUNT`: Service account email with necessary permissions
- `GCP_PROJECT_ID`: Your GCP project ID

### Setting up Workload Identity Federation

1. Create a Workload Identity Pool:
   ```bash
   gcloud iam workload-identity-pools create "github-pool" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --display-name="GitHub Actions Pool"
   ```

2. Create a Workload Identity Provider:
   ```bash
   gcloud iam workload-identity-pools providers create-oidc "github-provider" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --workload-identity-pool="github-pool" \
     --display-name="GitHub Provider" \
     --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
     --issuer-uri="https://token.actions.githubusercontent.com"
   ```

3. Create a service account and grant permissions:
   ```bash
   gcloud iam service-accounts create terraform-github \
     --display-name="Terraform GitHub Actions"

   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member="serviceAccount:terraform-github@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   ```

4. Allow the service account to be impersonated:
   ```bash
   gcloud iam service-accounts add-iam-policy-binding \
     "terraform-github@${PROJECT_ID}.iam.gserviceaccount.com" \
     --project="${PROJECT_ID}" \
     --role="roles/iam.workloadIdentityUser" \
     --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
   ```

## Bucket Configuration

The GCS bucket includes:

- **Uniform bucket-level access**: Simplifies permission management
- **Versioning**: Keeps history of object versions
- **Lifecycle policy**: Automatically deletes objects after 90 days
- **Labels**: Tags for environment and management tracking

## State Management

Currently using local state. For production, consider configuring remote state in GCS:

1. Create a separate bucket for Terraform state
2. Uncomment the backend configuration in `provider.tf`
3. Run `terraform init -migrate-state`
