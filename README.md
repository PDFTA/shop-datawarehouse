# Shop Data Warehouse

A Cloud Run application for querying parquet files from Google Cloud Storage using Polars.

## Features

- **Fast Parquet Queries**: Uses Polars for high-performance data queries
- **REST API**: FastAPI-based endpoints for easy integration
- **Serverless**: Runs on Cloud Run with automatic scaling
- **Infrastructure as Code**: Fully managed with Terraform
- **Automated Deployment**: CI/CD with GitHub Actions

## Quick Start

### Prerequisites

- Python 3.13
- uv package manager
- Docker (for local container testing)
- GCP account with billing enabled
- Terraform

### Local Development

1. Install dependencies:
   ```bash
   uv sync
   ```

2. Set environment variables:
   ```bash
   export GCS_BUCKET_NAME=pfdta-shop-bucket
   export GCP_PROJECT_ID=your-project-id
   ```

3. Run the application:
   ```bash
   uv run python -m uvicorn src.main:app --reload --port 8080
   ```

4. Access the API at http://localhost:8080

### API Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `GET /customers` - Query Customer List parquet file
- `GET /customers/schema` - Get Customer List schema
- `GET /customers/stats` - Get Customer List statistics

### Example Queries

```bash
# Get first 10 customers
curl "http://localhost:8080/customers?limit=10"

# Get specific columns
curl "http://localhost:8080/customers?columns=customer_id,name&limit=5"

# Filter results
curl "http://localhost:8080/customers?filter_column=status&filter_value=active"
```

## Deployment

### Infrastructure Setup

1. Configure GCP authentication and GitHub secrets (see `terraform/README.md`)

2. Deploy infrastructure:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

### Application Deployment

Push changes to the `main` branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy application"
git push origin main
```

The GitHub Actions workflow will:
1. Build the Docker image
2. Push to Artifact Registry
3. Deploy to Cloud Run
4. Run health checks

## Project Structure

```
shop-datawarehouse/
├── src/
│   └── main.py           # FastAPI application
├── terraform/            # Infrastructure as Code
│   ├── main.tf          # GCS bucket
│   ├── cloud_run.tf     # Cloud Run service
│   └── ...
├── .github/workflows/   # CI/CD pipelines
├── Dockerfile           # Container definition
└── pyproject.toml       # Python dependencies
```

## Architecture

```
┌─────────────────┐
│  GitHub Actions │
│   (CI/CD)       │
└────────┬────────┘
         │ Deploy
         ▼
┌─────────────────┐      ┌──────────────────┐
│   Cloud Run     │      │  Artifact        │
│   (FastAPI +    │◄─────│  Registry        │
│    Polars)      │      │  (Docker Images) │
└────────┬────────┘      └──────────────────┘
         │ Read
         ▼
┌─────────────────┐
│  Cloud Storage  │
│  (Parquet Files)│
└─────────────────┘
```

## Configuration

### Environment Variables

- `GCS_BUCKET_NAME`: Name of the GCS bucket (default: `pfdta-shop-bucket`)
- `GCP_PROJECT_ID`: GCP project ID
- `PORT`: Server port (default: `8080`)

### GitHub Secrets Required

- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Workload Identity Provider
- `GCP_SERVICE_ACCOUNT`: Service account email
- `GCP_PROJECT_ID`: GCP project ID

## Development

### Local Docker Testing

Use the provided scripts for easy local testing:

```bash
# Full automated test (build, run, test, cleanup)
./scripts/local-docker-test.sh

# Run interactively with logs
./scripts/run-local.sh

# Run tests and keep container running for debugging
./scripts/local-docker-test.sh --keep-running --logs
```

See `scripts/README.md` for more options and details.

### Running Tests

```bash
uv run pytest
```

### Manual Docker Build

```bash
docker build -t shop-datawarehouse .
docker run -p 8080:8080 \
  -e GCS_BUCKET_NAME=pfdta-shop-bucket \
  -e GCP_PROJECT_ID=your-project \
  shop-datawarehouse
```

## License

MIT
