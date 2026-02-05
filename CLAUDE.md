# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**shop-datawarehouse** is a Python 3.13 project managed with uv (Python package manager). The project manages GCP infrastructure using Terraform and includes a Google Cloud Storage bucket for data warehousing.

## Development Setup

This project uses uv for dependency management. Python 3.13 is required.

### Common Commands

```bash
# Install dependencies
uv sync

# Run Python scripts
uv run python <script.py>

# Add dependencies
uv add <package-name>

# Add development dependencies
uv add --dev <package-name>
```

## Infrastructure Management

This project uses Terraform to manage GCP resources.

### Terraform Commands

```bash
# Initialize Terraform
cd terraform
terraform init

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# Plan infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Required Secrets for GitHub Actions

The GitHub Actions workflow requires the following secrets to be configured:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Workload Identity Provider for GCP authentication
- `GCP_SERVICE_ACCOUNT`: Service account email for Terraform operations
- `GCP_PROJECT_ID`: GCP Project ID where resources will be created

### GCS Bucket

The Terraform configuration creates a GCS bucket named `pfdta-shop-bucket` with:
- Uniform bucket-level access enabled
- Versioning enabled by default
- 90-day lifecycle rule for automatic cleanup
- Labels for environment tracking

## Project Structure

- `terraform/`: Infrastructure as Code using Terraform
  - `main.tf`: GCS bucket resource definition
  - `provider.tf`: Terraform and GCP provider configuration
  - `variables.tf`: Variable definitions
  - `outputs.tf`: Output values
  - `terraform.tfvars.example`: Example variables file
- `.github/workflows/`: CI/CD workflows
  - `terraform.yml`: Automated Terraform plan and apply workflow

## Notes

- Python version is pinned to 3.13 (see `.python-version`)
- The project uses uv's `pyproject.toml` for configuration
- No dependencies are currently defined
