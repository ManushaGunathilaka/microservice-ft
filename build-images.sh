#!/bin/bash
# ================================================
# Cloud Native BuildPacks Build Script for Linux/Mac
# ================================================
# This script builds all microservices using Cloud Native Buildpacks
# Requirements: pack CLI, Docker, Maven

set -e  # Exit on error

echo ""
echo "============================================"
echo "Building Microservices with Cloud Native BuildPacks"
echo "============================================"
echo ""

# Check if pack CLI is installed
if ! command -v pack &> /dev/null; then
    echo "[ERROR] pack CLI not found. Please install from https://buildpacks.io/docs/tools/pack/"
    exit 1
fi

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo "[ERROR] Docker is not running. Please start Docker."
    exit 1
fi

# Set buildpack builder
BUILDER="paketobuildpacks/builder-jammy-full:latest"
PULL_POLICY="if-not-present"

echo "[INFO] Using builder: $BUILDER"
echo "[INFO] Java version: 21"
echo ""

# Create logs directory
mkdir -p build-logs
LOG_FILE="build-logs/build-$(date +%Y%m%d-%H%M%S).log"

echo "[INFO] Build logs will be saved to: $LOG_FILE"
echo ""

# ================================================
# Function to build service
# ================================================
build_service() {
    local service_name=$1
    local service_path=$2
    local image_name=$3
    local count=$4
    local total=$5

    echo "[$count/$total] Building $service_name..."
    echo "============================================" >> "$LOG_FILE"
    echo "Building $service_name" >> "$LOG_FILE"
    echo "============================================" >> "$LOG_FILE"

    if pack build "$image_name:0.0.1-SNAPSHOT" \
        --path "$service_path" \
        --builder "$BUILDER" \
        --trust-builder \
        --pull-policy "$PULL_POLICY" \
        --env BP_JVM_VERSION=21 >> "$LOG_FILE" 2>&1; then
        echo "[OK] $service_name built successfully."
    else
        echo "[FAILED] $service_name build failed. See $LOG_FILE for details."
        exit 1
    fi
    echo ""
}

# ================================================
# Build all services
# ================================================
build_service "API Gateway" "./api-gateway" "api-gateway" 1 5
build_service "Product Service" "./product" "product-service" 2 5
build_service "Order Service" "./order" "order-service" 3 5
build_service "Inventory Service" "./Inventory" "inventory-service" 4 5
build_service "Notification Service" "./notification-service" "notification-service" 5 5

# ================================================
# Verify Images
# ================================================
echo "============================================"
echo "Verifying Built Images"
echo "============================================"
docker images | grep SNAPSHOT
echo ""

# ================================================
# Summary
# ================================================
echo ""
echo "============================================"
echo "BUILD COMPLETE!"
echo "============================================"
echo ""
echo "All microservices have been built successfully!"
echo ""
echo "Next steps:"
echo "1. Start services: docker-compose up -d"
echo "2. Check status: docker-compose ps"
echo "3. View logs: docker-compose logs -f"
echo ""
echo "Build logs saved to: $LOG_FILE"
echo ""
