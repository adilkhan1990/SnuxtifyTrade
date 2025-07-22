# FnF Trading System Setup Script for Windows PowerShell

param(
    [Parameter(Position=0)]
    [ValidateSet("development", "dev", "production", "prod", "stop", "reset", "logs")]
    [string]$Mode = "development"
)

# Colors for output
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

Write-Host "🚀 FnF Trading System Setup" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed. Please install Docker Desktop first."
    exit 1
}

# Check if Docker Compose is available
try {
    docker compose version | Out-Null
    Write-Success "Docker and Docker Compose are available"
} catch {
    Write-Error "Docker Compose V2 is not available. Please update Docker Desktop."
    exit 1
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Warning "No .env file found. Creating from .env.example"
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Success "Created .env file from template"
    } else {
        Write-Error ".env.example file not found"
        exit 1
    }
} else {
    Write-Success ".env file exists"
}

# Function to run setup
function Start-Setup {
    param([string]$SetupMode)
    
    Write-Host ""
    Write-Host "Setting up FnF Trading System in $SetupMode mode..." -ForegroundColor Yellow
    Write-Host ""
    
    if ($SetupMode -eq "production") {
        Write-Warning "Production mode selected"
        Write-Warning "Make sure to update .env with production values!"
        docker compose -f docker-compose.yml -f docker-compose.prod.yml down -v
        docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
    } else {
        docker compose down -v
        docker compose up --build -d
    }
    
    Write-Host ""
    Write-Success "Waiting for services to start..."
    
    # Wait for services to be healthy
    $maxAttempts = 60
    $attempt = 0
    
    do {
        $unhealthyServices = docker compose ps | Select-String "unhealthy"
        if ($unhealthyServices) {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
            $attempt++
        } else {
            break
        }
    } while ($attempt -lt $maxAttempts)
    
    Write-Host ""
    
    # Check final status
    $unhealthyServices = docker compose ps | Select-String "unhealthy"
    if ($unhealthyServices) {
        Write-Error "Some services failed to start properly"
        Write-Warning "Check logs with: docker compose logs"
        exit 1
    }
    
    Write-Success "All services are running!"
    
    Write-Host ""
    Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access your application:" -ForegroundColor Cyan
    Write-Host "  Frontend:     http://localhost:3000"
    Write-Host "  Backend API:  http://localhost:8000"
    Write-Host "  API Docs:     http://localhost:8000/docs"
    Write-Host "  NGINX Proxy:  http://localhost"
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  View logs:    docker compose logs -f"
    Write-Host "  Stop:         docker compose down"
    Write-Host "  Rebuild:      docker compose up --build"
    Write-Host "  Reset:        docker compose down -v; docker compose up --build"
    Write-Host ""
}

# Handle different modes
switch ($Mode) {
    { $_ -in "production", "prod" } {
        Start-Setup "production"
        break
    }
    { $_ -in "development", "dev" } {
        Start-Setup "development"
        break
    }
    "stop" {
        Write-Host "Stopping all services..." -ForegroundColor Yellow
        docker compose down
        Write-Success "Services stopped"
        break
    }
    "reset" {
        Write-Host "Resetting all services and data..." -ForegroundColor Yellow
        docker compose down -v
        docker system prune -f
        Write-Success "Reset complete"
        break
    }
    "logs" {
        docker compose logs -f
        break
    }
    default {
        Write-Host "Usage: .\setup.ps1 [development|production|stop|reset|logs]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Cyan
        Write-Host "  development  Setup in development mode (default)"
        Write-Host "  production   Setup in production mode"
        Write-Host "  stop         Stop all services"
        Write-Host "  reset        Reset all services and data"
        Write-Host "  logs         Show logs"
        break
    }
}
