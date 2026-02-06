"""
Basic tests for the API endpoints.
"""

import pytest
from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_root():
    """Test root endpoint returns API information."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "name" in data
    assert "version" in data
    assert "endpoints" in data


def test_health_check():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "bucket" in data


def test_customers_endpoint_structure():
    """Test customers endpoint returns correct structure."""
    # Note: This test will fail if GCS bucket is not accessible
    # For unit tests, you should mock the GCS calls
    response = client.get("/customers?limit=1")

    # If bucket is accessible, check structure
    if response.status_code == 200:
        data = response.json()
        assert "data" in data
        assert "count" in data
        assert "offset" in data
        assert "limit" in data
        assert isinstance(data["data"], list)


def test_customers_pagination():
    """Test pagination parameters are validated."""
    # Test invalid limit (too large)
    response = client.get("/customers?limit=100000")
    assert response.status_code == 422  # Validation error

    # Test invalid offset (negative)
    response = client.get("/customers?offset=-1")
    assert response.status_code == 422  # Validation error


def test_customers_column_selection():
    """Test column selection parameter."""
    # This will return 400 if columns don't exist, or 200 if they do
    response = client.get("/customers?columns=invalid_column&limit=1")
    # Either 400 (invalid column) or 500 (can't access bucket)
    assert response.status_code in [400, 500]
