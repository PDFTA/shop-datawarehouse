#!/bin/bash
set -e

# Configuration
IMAGE_NAME="shop-datawarehouse"
CONTAINER_NAME="shop-datawarehouse-test"
PORT=8080
GCS_BUCKET_NAME="${GCS_BUCKET_NAME:-pfdta-shop-bucket}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${GREEN}=== $1 ===${NC}\n"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

cleanup() {
    print_header "Cleaning up"
    if docker ps -a | grep -q $CONTAINER_NAME; then
        echo "Stopping and removing container..."
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        print_success "Container removed"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking prerequisites"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker is installed"

    if [ -z "$GCP_PROJECT_ID" ]; then
        print_warning "GCP_PROJECT_ID not set. Some features may not work."
        echo "Set it with: export GCP_PROJECT_ID=your-project-id"
    else
        print_success "GCP_PROJECT_ID: $GCP_PROJECT_ID"
    fi

    echo "Using GCS bucket: $GCS_BUCKET_NAME"
}

# Build Docker image
build_image() {
    print_header "Building Docker image"

    echo "Building $IMAGE_NAME..."
    docker build -t $IMAGE_NAME .

    print_success "Image built successfully"
    docker images | grep $IMAGE_NAME
}

# Run container
run_container() {
    print_header "Running container"

    # Cleanup any existing container
    cleanup

    echo "Starting container on port $PORT..."

    # Run container with environment variables
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:8080 \
        -e GCS_BUCKET_NAME=$GCS_BUCKET_NAME \
        -e GCP_PROJECT_ID=$GCP_PROJECT_ID \
        -e PORT=8080 \
        $IMAGE_NAME

    print_success "Container started"

    # Wait for container to be ready
    echo "Waiting for container to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:$PORT/health > /dev/null 2>&1; then
            print_success "Container is ready"
            return 0
        fi
        echo -n "."
        sleep 1
    done

    print_error "Container did not become ready in time"
    echo "Container logs:"
    docker logs $CONTAINER_NAME
    return 1
}

# Test endpoints
test_endpoints() {
    print_header "Testing API endpoints"

    BASE_URL="http://localhost:$PORT"

    # Test root endpoint
    echo "Testing GET /"
    response=$(curl -s -w "\n%{http_code}" $BASE_URL/)
    http_code=$(echo "$response" | tail -n 1)
    if [ "$http_code" = "200" ]; then
        print_success "Root endpoint: OK"
        echo "$response" | head -n -1 | jq '.' 2>/dev/null || echo "$response" | head -n -1
    else
        print_error "Root endpoint failed (HTTP $http_code)"
    fi

    # Test health endpoint
    echo -e "\nTesting GET /health"
    response=$(curl -s -w "\n%{http_code}" $BASE_URL/health)
    http_code=$(echo "$response" | tail -n 1)
    if [ "$http_code" = "200" ]; then
        print_success "Health endpoint: OK"
        echo "$response" | head -n -1 | jq '.' 2>/dev/null || echo "$response" | head -n -1
    else
        print_error "Health endpoint failed (HTTP $http_code)"
    fi

    # Test customers schema endpoint
    echo -e "\nTesting GET /customers/schema"
    response=$(curl -s -w "\n%{http_code}" $BASE_URL/customers/schema)
    http_code=$(echo "$response" | tail -n 1)
    if [ "$http_code" = "200" ]; then
        print_success "Customers schema endpoint: OK"
        echo "$response" | head -n -1 | jq '.' 2>/dev/null || echo "$response" | head -n -1
    else
        print_warning "Customers schema endpoint returned HTTP $http_code (may need GCP credentials)"
        echo "$response" | head -n -1
    fi

    # Test customers endpoint
    echo -e "\nTesting GET /customers?limit=5"
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL/customers?limit=5")
    http_code=$(echo "$response" | tail -n 1)
    if [ "$http_code" = "200" ]; then
        print_success "Customers endpoint: OK"
        echo "$response" | head -n -1 | jq '.' 2>/dev/null || echo "$response" | head -n -1
    else
        print_warning "Customers endpoint returned HTTP $http_code (may need GCP credentials)"
        echo "$response" | head -n -1
    fi

    # Test customers stats endpoint
    echo -e "\nTesting GET /customers/stats"
    response=$(curl -s -w "\n%{http_code}" $BASE_URL/customers/stats)
    http_code=$(echo "$response" | tail -n 1)
    if [ "$http_code" = "200" ]; then
        print_success "Customers stats endpoint: OK"
        echo "$response" | head -n -1 | jq '.' 2>/dev/null || echo "$response" | head -n -1
    else
        print_warning "Customers stats endpoint returned HTTP $http_code (may need GCP credentials)"
        echo "$response" | head -n -1
    fi
}

# Show container logs
show_logs() {
    print_header "Container logs"
    docker logs $CONTAINER_NAME
}

# Main execution
main() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║  Shop Data Warehouse Docker Test Script  ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"

    # Parse arguments
    SKIP_BUILD=false
    KEEP_RUNNING=false
    SHOW_LOGS=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --keep-running)
                KEEP_RUNNING=true
                shift
                ;;
            --logs)
                SHOW_LOGS=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --skip-build     Skip the Docker build step"
                echo "  --keep-running   Keep container running after tests"
                echo "  --logs           Show container logs after tests"
                echo "  --help           Show this help message"
                echo ""
                echo "Environment variables:"
                echo "  GCS_BUCKET_NAME  GCS bucket name (default: pfdta-shop-bucket)"
                echo "  GCP_PROJECT_ID   GCP project ID (required for GCS access)"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Trap to ensure cleanup on exit
    if [ "$KEEP_RUNNING" = false ]; then
        trap cleanup EXIT
    fi

    check_prerequisites

    if [ "$SKIP_BUILD" = false ]; then
        build_image
    else
        print_warning "Skipping build step"
    fi

    run_container

    test_endpoints

    if [ "$SHOW_LOGS" = true ]; then
        show_logs
    fi

    if [ "$KEEP_RUNNING" = true ]; then
        print_header "Container is running"
        echo "Container: $CONTAINER_NAME"
        echo "Port: $PORT"
        echo "API URL: http://localhost:$PORT"
        echo ""
        echo "To view logs: docker logs -f $CONTAINER_NAME"
        echo "To stop: docker stop $CONTAINER_NAME"
        echo "To remove: docker rm $CONTAINER_NAME"
    else
        print_header "Tests complete"
        echo "Container will be stopped and removed"
    fi
}

main "$@"
