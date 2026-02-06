#!/bin/bash
# Simple script to run the application locally with Docker

set -e

IMAGE_NAME="shop-datawarehouse"
PORT="${PORT:-8080}"
GCS_BUCKET_NAME="${GCS_BUCKET_NAME:-pfdta-shop-bucket}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-}"

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

echo ""
echo "Starting container on port $PORT..."
echo "GCS_BUCKET_NAME: $GCS_BUCKET_NAME"
echo "GCP_PROJECT_ID: $GCP_PROJECT_ID"
echo ""
echo "API will be available at: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Run container with logs displayed
docker run --rm \
    --name $IMAGE_NAME \
    -p $PORT:8080 \
    -e GCS_BUCKET_NAME=$GCS_BUCKET_NAME \
    -e GCP_PROJECT_ID=$GCP_PROJECT_ID \
    -e PORT=8080 \
    $IMAGE_NAME
