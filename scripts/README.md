# Development Scripts

This directory contains helper scripts for local development and testing.

## Available Scripts

### `local-docker-test.sh`

Comprehensive script that builds, runs, and tests the Docker container locally.

**Usage:**
```bash
# Run full test (build, run, test, cleanup)
./scripts/local-docker-test.sh

# Skip build step (use existing image)
./scripts/local-docker-test.sh --skip-build

# Keep container running after tests
./scripts/local-docker-test.sh --keep-running

# Show container logs after tests
./scripts/local-docker-test.sh --logs

# Combine options
./scripts/local-docker-test.sh --skip-build --keep-running --logs
```

**Features:**
- ✅ Builds Docker image
- ✅ Starts container with proper environment variables
- ✅ Waits for container to be ready
- ✅ Tests all API endpoints
- ✅ Displays formatted results
- ✅ Automatic cleanup (unless --keep-running is used)

**Environment Variables:**
```bash
export GCS_BUCKET_NAME=pfdta-shop-bucket  # Optional, defaults to pfdta-shop-bucket
export GCP_PROJECT_ID=your-project-id     # Required for GCS access
```

### `run-local.sh`

Simple script to build and run the Docker container interactively.

**Usage:**
```bash
# Run with default settings
./scripts/run-local.sh

# Run on custom port
PORT=3000 ./scripts/run-local.sh

# Run with GCP credentials
GCP_PROJECT_ID=my-project ./scripts/run-local.sh
```

**Features:**
- Builds the Docker image
- Runs container with logs displayed in terminal
- Press Ctrl+C to stop
- Container is automatically removed on exit

## Testing the API

Once the container is running, you can test the endpoints:

```bash
# Health check
curl http://localhost:8080/health

# Get API info
curl http://localhost:8080/

# Query customers
curl "http://localhost:8080/customers?limit=10" | jq

# Get schema
curl http://localhost:8080/customers/schema | jq

# Get statistics
curl http://localhost:8080/customers/stats | jq

# Filter customers
curl "http://localhost:8080/customers?filter_column=status&filter_value=active&limit=5" | jq

# Select specific columns
curl "http://localhost:8080/customers?columns=customer_id,name&limit=5" | jq
```

## Troubleshooting

### Permission Denied

If you get a permission error, make the scripts executable:
```bash
chmod +x scripts/*.sh
```

### GCS Access Errors

If you get errors accessing GCS, ensure:
1. `GCP_PROJECT_ID` environment variable is set
2. You have authenticated with `gcloud auth application-default login`
3. Your account has permissions to read from the bucket

### Container Won't Start

Check Docker logs:
```bash
docker logs shop-datawarehouse-test
```

Or use the `--logs` flag with the test script:
```bash
./scripts/local-docker-test.sh --logs
```

## Development Workflow

**Quick iteration (without full tests):**
```bash
./scripts/run-local.sh
# Make changes to code
# Ctrl+C to stop
./scripts/run-local.sh  # Rebuilds and runs
```

**Full test before committing:**
```bash
./scripts/local-docker-test.sh
```

**Debug mode (keep container running):**
```bash
./scripts/local-docker-test.sh --keep-running --logs
# Container stays running, you can exec into it or test manually
docker exec -it shop-datawarehouse-test /bin/bash
```
