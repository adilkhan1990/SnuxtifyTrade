#!/bin/bash

# FnF Trading System Setup Script

set -e

echo "🚀 FnF Trading System Setup"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose V2 is not available. Please update Docker Desktop."
    exit 1
fi

print_status "Docker and Docker Compose are available"

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning "No .env file found. Creating from .env.example"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_status "Created .env file from template"
    else
        print_error ".env.example file not found"
        exit 1
    fi
else
    print_status ".env file exists"
fi

# Function to run setup
setup() {
    local mode=$1
    
    echo ""
    echo "Setting up FnF Trading System in ${mode} mode..."
    echo ""
    
    if [ "$mode" = "production" ]; then
        print_warning "Production mode selected"
        print_warning "Make sure to update .env with production values!"
        docker compose -f docker-compose.yml -f docker-compose.prod.yml down -v
        docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
    else
        docker compose down -v
        docker compose up --build -d
    fi
    
    echo ""
    print_status "Waiting for services to start..."
    
    # Wait for services to be healthy
    max_attempts=60
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker compose ps | grep -q "unhealthy"; then
            echo -n "."
            sleep 2
            attempt=$((attempt + 1))
        else
            break
        fi
    done
    
    echo ""
    
    # Check final status
    if docker compose ps | grep -q "unhealthy"; then
        print_error "Some services failed to start properly"
        print_warning "Check logs with: docker compose logs"
        exit 1
    fi
    
    print_status "All services are running!"
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Access your application:"
    echo "  Frontend:     http://localhost:3000"
    echo "  Backend API:  http://localhost:8000"
    echo "  API Docs:     http://localhost:8000/docs"
    echo "  NGINX Proxy:  http://localhost"
    echo ""
    echo "Useful commands:"
    echo "  View logs:    docker compose logs -f"
    echo "  Stop:         docker compose down"
    echo "  Rebuild:      docker compose up --build"
    echo "  Reset:        docker compose down -v && docker compose up --build"
    echo ""
}

# Parse command line arguments
case "${1:-development}" in
    "production"|"prod")
        setup "production"
        ;;
    "development"|"dev"|"")
        setup "development"
        ;;
    "stop")
        echo "Stopping all services..."
        docker compose down
        print_status "Services stopped"
        ;;
    "reset")
        echo "Resetting all services and data..."
        docker compose down -v
        docker system prune -f
        print_status "Reset complete"
        ;;
    "logs")
        docker compose logs -f
        ;;
    *)
        echo "Usage: $0 [development|production|stop|reset|logs]"
        echo ""
        echo "Commands:"
        echo "  development  Setup in development mode (default)"
        echo "  production   Setup in production mode"
        echo "  stop         Stop all services"
        echo "  reset        Reset all services and data"
        echo "  logs         Show logs"
        exit 1
        ;;
esac
