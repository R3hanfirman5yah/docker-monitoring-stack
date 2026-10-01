#!/bin/bash

# Docker Monitoring Stack Stop Script

set -e

echo "========================================"
echo "Stopping Docker Monitoring Stack"
echo "========================================"
echo ""

docker compose down

echo ""
echo "Stack stopped successfully!"
echo ""
echo "To remove all data volumes as well, run:"
echo "  docker compose down -v"
echo ""
