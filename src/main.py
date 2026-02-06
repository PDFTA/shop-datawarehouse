"""
Cloud Run application for querying parquet files from GCS using Polars.
"""

import os
from typing import Optional

import polars as pl
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import JSONResponse
from google.cloud import storage

app = FastAPI(
    title="Shop Data Warehouse API",
    description="Query parquet files from GCS using Polars",
    version="0.1.0",
)

# Configuration
BUCKET_NAME = os.getenv("GCS_BUCKET_NAME", "pfdta-shop-bucket")
PROJECT_ID = os.getenv("GCP_PROJECT_ID")


def scan_parquet_from_gcs(file_path: str) -> pl.LazyFrame:
    """
    Scan a parquet file from GCS using Polars lazy evaluation.

    This uses scan_parquet for lazy evaluation, which only loads data when needed
    and allows Polars to optimize the query plan before execution.

    Args:
        file_path: Path to the parquet file in the bucket (e.g., "Customer List.parquet")

    Returns:
        Polars LazyFrame
    """
    gcs_uri = f"gs://{BUCKET_NAME}/{file_path}"

    try:
        # Scan from GCS using lazy evaluation
        lf = pl.scan_parquet(gcs_uri, storage_options={"project": PROJECT_ID})
        return lf
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error scanning parquet file from GCS: {str(e)}"
        )


@app.get("/")
def root():
    """Root endpoint with API information."""
    return {
        "name": "Shop Data Warehouse API",
        "version": "0.1.0",
        "endpoints": {
            "health": "/health",
            "customers": "/customers",
            "customer_schema": "/customers/schema",
        }
    }


@app.get("/health")
def health_check():
    """Health check endpoint for Cloud Run."""
    return {"status": "healthy", "bucket": BUCKET_NAME}


@app.get("/customers/schema")
def get_customer_schema():
    """Get the schema of the Customer List parquet file."""
    try:
        lf = scan_parquet_from_gcs("Customer List.parquet")
        # Collect schema info without loading all data
        schema_dict = lf.collect_schema()
        row_count = lf.select(pl.len()).collect().item()

        schema = {col: str(dtype) for col, dtype in schema_dict.items()}
        return {
            "schema": schema,
            "row_count": row_count,
            "columns": list(schema_dict.keys()),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/customers")
def query_customers(
    limit: Optional[int] = Query(100, ge=1, le=10000, description="Number of rows to return"),
    offset: Optional[int] = Query(0, ge=0, description="Number of rows to skip"),
    columns: Optional[str] = Query(None, description="Comma-separated list of columns to return"),
    filter_column: Optional[str] = Query(None, description="Column name to filter on"),
    filter_value: Optional[str] = Query(None, description="Value to filter for (exact match)"),
):
    """
    Query the Customer List parquet file.

    Parameters:
    - limit: Maximum number of rows to return (default: 100, max: 10000)
    - offset: Number of rows to skip (default: 0)
    - columns: Comma-separated column names to return (optional, returns all if not specified)
    - filter_column: Column name to filter on (optional)
    - filter_value: Value to filter for (optional, requires filter_column)

    Example:
        /customers?limit=10&columns=customer_id,name&filter_column=status&filter_value=active
    """
    try:
        # Scan the parquet file lazily
        lf = scan_parquet_from_gcs("Customer List.parquet")

        # Get schema for validation
        schema = lf.collect_schema()
        available_columns = list(schema.keys())

        # Apply column selection if specified
        if columns:
            requested_cols = [col.strip() for col in columns.split(",")]
            # Validate columns exist
            invalid_cols = [col for col in requested_cols if col not in available_columns]
            if invalid_cols:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid columns: {invalid_cols}. Available columns: {available_columns}"
                )
            lf = lf.select(requested_cols)

        # Apply filter if specified
        if filter_column and filter_value:
            if filter_column not in available_columns:
                raise HTTPException(
                    status_code=400,
                    detail=f"Filter column '{filter_column}' not found. Available columns: {available_columns}"
                )
            lf = lf.filter(pl.col(filter_column) == filter_value)

        # Apply offset and limit
        lf = lf.slice(offset, limit)

        # Collect results - this is where the query executes
        df = lf.collect()

        # Convert to JSON-serializable format
        result = df.to_dicts()

        return JSONResponse(content={
            "data": result,
            "count": len(result),
            "offset": offset,
            "limit": limit,
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error querying customers: {str(e)}")


@app.get("/customers/stats")
def get_customer_stats():
    """Get basic statistics about the Customer List."""
    try:
        lf = scan_parquet_from_gcs("Customer List.parquet")

        # Get schema info
        schema = lf.collect_schema()
        columns = list(schema.keys())

        # Get row count efficiently
        row_count = lf.select(pl.len()).collect().item()

        # Get basic stats
        stats = {
            "total_rows": row_count,
            "total_columns": len(columns),
            "columns": columns,
        }

        # Build aggregation for numeric columns
        numeric_cols = [col for col, dtype in schema.items()
                       if dtype in [pl.Int64, pl.Int32, pl.Float64, pl.Float32, pl.Int8, pl.Int16, pl.UInt8, pl.UInt16, pl.UInt32, pl.UInt64]]

        if numeric_cols:
            # Build lazy aggregations for all numeric columns at once
            agg_exprs = []
            for col in numeric_cols:
                agg_exprs.extend([
                    pl.col(col).min().alias(f"{col}_min"),
                    pl.col(col).max().alias(f"{col}_max"),
                    pl.col(col).mean().alias(f"{col}_mean"),
                ])

            # Execute aggregation once
            agg_results = lf.select(agg_exprs).collect()

            # Parse results
            numeric_stats = {}
            for col in numeric_cols:
                numeric_stats[col] = {
                    "min": float(agg_results[f"{col}_min"][0]) if agg_results[f"{col}_min"][0] is not None else None,
                    "max": float(agg_results[f"{col}_max"][0]) if agg_results[f"{col}_max"][0] is not None else None,
                    "mean": float(agg_results[f"{col}_mean"][0]) if agg_results[f"{col}_mean"][0] is not None else None,
                }

            stats["numeric_columns"] = numeric_stats

        return stats

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
