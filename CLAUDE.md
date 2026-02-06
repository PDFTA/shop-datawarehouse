# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**shop-datawarehouse** is a Python 3.13 project that provides a FastAPI-based REST API for querying parquet files stored in Google Cloud Storage using Polars. The application runs on Cloud Run and infrastructure is managed with Terraform.

### Key Technologies

- **Python 3.13** with uv package manager
- **Polars** for fast parquet file querying
- **FastAPI** for REST API
- **Google Cloud Run** for serverless deployment
- **Google Cloud Storage** for data storage
- **Terraform** for infrastructure as code

## Development Setup

This project uses uv for dependency management. Python 3.13 is required.

### Common Commands

```bash
# Install dependencies
uv sync

# Run the API locally
uv run python -m uvicorn src.main:app --reload --port 8080

# Run with environment variables
GCS_BUCKET_NAME=pfdta-shop-bucket GCP_PROJECT_ID=your-project uv run python -m uvicorn src.main:app --reload

# Add dependencies
uv add <package-name>

# Add development dependencies
uv add --dev <package-name>

# Run tests
uv run pytest

# Local Docker testing (automated)
./scripts/local-docker-test.sh               # Full test: build, run, test, cleanup
./scripts/local-docker-test.sh --keep-running  # Keep container running after tests
./scripts/run-local.sh                        # Simple run with logs

# Manual Docker commands
docker build -t shop-datawarehouse .
docker run -p 8080:8080 \
  -e GCS_BUCKET_NAME=pfdta-shop-bucket \
  -e GCP_PROJECT_ID=your-project \
  shop-datawarehouse
```

### Development Scripts

The `scripts/` directory contains helper scripts for local development:

- **local-docker-test.sh**: Comprehensive testing script that builds, runs, tests all endpoints, and cleans up. Supports `--skip-build`, `--keep-running`, and `--logs` flags.
- **run-local.sh**: Simple script to build and run the container interactively with logs displayed.

See `scripts/README.md` for detailed usage.

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

## Cloud Run API

The application provides a REST API for querying parquet files from GCS:

### API Endpoints

- `GET /` - API information and available endpoints
- `GET /health` - Health check endpoint
- `GET /customers` - Query Customer List parquet file
  - Query parameters:
    - `limit`: Number of rows to return (default: 100, max: 10000)
    - `offset`: Number of rows to skip (default: 0)
    - `columns`: Comma-separated list of columns to return
    - `filter_column`: Column name to filter on
    - `filter_value`: Value to filter for (exact match)
- `GET /customers/schema` - Get schema of Customer List
- `GET /customers/stats` - Get statistics about Customer List

### Example API Usage

```bash
# Get first 10 customers
curl "https://your-service.run.app/customers?limit=10"

# Get specific columns
curl "https://your-service.run.app/customers?columns=customer_id,name&limit=5"

# Filter and paginate
curl "https://your-service.run.app/customers?filter_column=status&filter_value=active&offset=10&limit=20"

# Get schema information
curl "https://your-service.run.app/customers/schema"

# Get statistics
curl "https://your-service.run.app/customers/stats"
```

## Deployment

The application is automatically deployed to Cloud Run when changes are pushed to the `main` branch.

### GitHub Actions Workflows

1. **terraform.yml** - Manages infrastructure (GCS bucket, Cloud Run service, IAM)
   - Runs on changes to `terraform/**`
   - Plans on PRs, applies on main branch

2. **deploy-cloud-run.yml** - Builds and deploys the application
   - Runs on changes to `src/**`, `Dockerfile`, or `pyproject.toml`
   - Builds Docker image and pushes to Artifact Registry
   - Deploys to Cloud Run with automatic rollback on failure

## Project Structure

- `src/`: Application source code
  - `main.py`: FastAPI application with Polars queries
- `terraform/`: Infrastructure as Code
  - `main.tf`: GCS bucket configuration
  - `cloud_run.tf`: Cloud Run service and IAM
  - `apis.tf`: Required GCP APIs
  - `provider.tf`: Terraform and provider configuration
  - `variables.tf`: Variable definitions
  - `outputs.tf`: Output values
- `.github/workflows/`: CI/CD workflows
  - `terraform.yml`: Infrastructure management
  - `deploy-cloud-run.yml`: Application deployment
- `Dockerfile`: Container image definition
- `pyproject.toml`: Python dependencies and project metadata

## Architecture

1. **Data Storage**: Parquet files are stored in GCS bucket `pfdta-shop-bucket`
2. **Application**: FastAPI app runs on Cloud Run, uses Polars to query parquet files
3. **Authentication**: Cloud Run service account has read-only access to GCS bucket
4. **Scaling**: Cloud Run scales from 0 to 10 instances based on traffic
5. **Deployment**: Automated via GitHub Actions with Docker container images stored in Artifact Registry

## Infrastructure Resources

- **GCS Bucket**: `pfdta-shop-bucket` (europe-west2)
- **Cloud Run Service**: `shop-datawarehouse` (europe-west2)
- **Service Account**: `shop-datawarehouse-sa` with Storage Object Viewer role
- **Artifact Registry**: `shop-datawarehouse` repository for Docker images
