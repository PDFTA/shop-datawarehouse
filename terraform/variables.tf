variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcs_location" {
  description = "GCS bucket location"
  type        = string
  default     = "EU"
}


variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

# Cloud Run variables
variable "cloud_run_region" {
  description = "Region for Cloud Run service"
  type        = string
  default     = "europe-west2"
}

variable "cloud_run_image" {
  description = "Container image for Cloud Run service"
  type        = string
  default     = "" # Will be constructed from artifact registry
}


variable "cloud_run_allow_public_access" {
  description = "Allow public access to Cloud Run service"
  type        = bool
  default     = false
}

# GitHub repository for workload identity
variable "github_repository" {
  description = "GitHub repository name (owner/repo) for workload identity binding"
  type        = string
  default     = ""
}
