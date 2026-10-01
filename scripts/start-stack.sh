#!/bin/bash

# Docker Monitoring Stack Startup Script

set -e

echo "========================================"
echo "Starting Docker Monitoring Stack"
echo "========================================"
echo ""

# Check if Docker is running
echo "[1/3] Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running!"
    echo "Please start Docker with: sudo systemctl start docker"
    exit 1
fi

# Create necessary directories
echo "[2/3] Creating configuration directories..."
mkdir -p config/prometheus
mkdir -p config/loki
mkdir -p config/promtail
mkdir -p config/grafana/provisioning/datasources
mkdir -p config/grafana/provisioning/dashboards

# Start Docker Compose
echo "[3/3] Starting containers..."
docker compose up -d

echo ""
echo "========================================"
echo "Stack started successfully!"
echo "========================================"
echo ""
echo "Access the services at:"
echo "  • Portainer:   http://localhost:9000"
echo "  • Grafana:     http://localhost:3000 (admin / admin123)"
echo "  • Prometheus:  http://localhost:9090"
echo "  • Loki:        http://localhost:3100"
echo ""
echo "View logs with:"
echo "  docker compose logs -f"
echo ""
