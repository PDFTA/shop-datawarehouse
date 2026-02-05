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
