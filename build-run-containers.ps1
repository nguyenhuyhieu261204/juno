# Juno Project - Build and Run Script (PowerShell)
# This script builds and runs both backend and frontend containers with MongoDB

# Set error handling
$ErrorActionPreference = "Stop"

# Colors for output
$InfoColor = "Blue"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"

# Print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $InfoColor
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $SuccessColor
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $WarningColor
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $ErrorColor
}

# Check if Docker is installed and running
function Check-Docker {
    try {
        $dockerVersion = docker --version 2>$null
        if (-not $dockerVersion) {
            Write-Error-Message "Docker is not installed. Please install Docker first."
            exit 1
        }
        
        # Test if Docker daemon is running
        docker ps 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Message "Docker is not running. Please start Docker daemon."
            exit 1
        }
    }
    catch {
        Write-Error-Message "Docker is not accessible: $_"
        exit 1
    }
}

# Load environment variables
function Load-Env {
    $envPath = Join-Path $PSScriptRoot ".env"
    if (Test-Path $envPath) {
        Write-Status "Loading environment variables from .env file"
        Get-Content $envPath | ForEach-Object {
            if ($_ -match "^([^=]+)=(.*)") {
                $name = $matches[1]
                $value = $matches[2]
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
    else {
        Write-Warning-Message ".env file not found. Using default values."
        # Set default values if .env doesn't exist
        if (-not $env:MONGO_URI) { $env:MONGO_URI = "mongodb://mongo:27017/juno" }
        if (-not $env:SESSION_SECRET) { $env:SESSION_SECRET = "your-very-secure-session-secret-here" }
        if (-not $env:SESSION_EXPIRES_IN) { $env:SESSION_EXPIRES_IN = "1d" }
        if (-not $env:GOOGLE_CLIENT_ID) { $env:GOOGLE_CLIENT_ID = "" }
        if (-not $env:GOOGLE_CLIENT_SECRET) { $env:GOOGLE_CLIENT_SECRET = "" }
        if (-not $env:GOOGLE_CALLBACK_URL) { $env:GOOGLE_CALLBACK_URL = "http://localhost:8000/api/auth/google/callback" }
        if (-not $env:FRONTEND_ORIGIN) { $env:FRONTEND_ORIGIN = "http://localhost:3000" }
        if (-not $env:FRONTEND_GOOGLE_CALLBACK_URL) { $env:FRONTEND_GOOGLE_CALLBACK_URL = "http://localhost:3000/google/callback" }
    }
}

# Build backend image
function Build-Backend {
    Write-Status "Building backend image..."
    $backendPath = Join-Path $PSScriptRoot "backend"
    Push-Location $backendPath
    
    # Check if Dockerfile exists
    if (-not (Test-Path "Dockerfile")) {
        Write-Error-Message "Dockerfile not found in backend directory. Please run the Docker setup script first."
        Pop-Location
        exit 1
    }
    
    docker build -t juno-backend .
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Failed to build backend image"
        Pop-Location
        exit 1
    }
    
    Write-Success "Backend image built successfully!"
    Pop-Location
}

# Build frontend image
function Build-Frontend {
    Write-Status "Building frontend image..."
    $clientPath = Join-Path $PSScriptRoot "client"
    Push-Location $clientPath
    
    # Check if Dockerfile exists
    if (-not (Test-Path "Dockerfile")) {
        Write-Error-Message "Dockerfile not found in client directory. Please run the Docker setup script first."
        Pop-Location
        exit 1
    }
    
    docker build -t juno-client .
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Failed to build frontend image"
        Pop-Location
        exit 1
    }
    
    Write-Success "Frontend image built successfully!"
    Pop-Location
}

# Stop existing containers
function Stop-Containers {
    Write-Status "Stopping existing containers..."
    
    # Stop and remove containers if they exist
    @("juno-backend", "juno-client", "juno-mongo") | ForEach-Object {
        $containerName = $_
        $containerExists = docker ps -a --filter "name=$containerName" --format "{{.Names}}" 2>$null
        if ($containerExists) {
            Write-Status "Stopping container: $containerName"
            docker stop $containerName 2>$null | Out-Null
            docker rm $containerName 2>$null | Out-Null
        }
    }
    
    Write-Success "Existing containers stopped and removed."
}

# Run the application
function Run-Containers {
    Write-Status "Starting Juno application containers..."
    
    # Run MongoDB container
    Write-Status "Starting MongoDB container..."
    $mongoRunning = docker ps --filter "name=juno-mongo" --format "{{.Names}}"
    if ($mongoRunning -ne "juno-mongo") {
        docker run -d `
            --name juno-mongo `
            -p 27017:27017 `
            -e MONGO_INITDB_ROOT_USERNAME=admin `
            -e MONGO_INITDB_ROOT_PASSWORD=password `
            -v juno-mongo-data:/data/db `
            --health-cmd='echo "db.runCommand(\"ping\").ok" | mongosh localhost:27017/test --quiet' `
            --health-interval=10s `
            --health-timeout=3s `
            --health-retries=5 `
            mongo:7.0
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Message "Failed to start MongoDB container"
            exit 1
        }
    }
    
    # Wait for MongoDB to be ready
    Write-Status "Waiting for MongoDB to be ready..."
    Start-Sleep -Seconds 10
    
    # Run Backend container
    Write-Status "Starting Backend container..."
    $backendRunning = docker ps --filter "name=juno-backend" --format "{{.Names}}"
    if ($backendRunning -ne "juno-backend") {
        docker run -d `
            --name juno-backend `
            -p 8000:8000 `
            -e MONGO_URI="mongodb://juno-mongo:27017/juno" `
            -e SESSION_SECRET="$env:SESSION_SECRET" `
            -e SESSION_EXPIRES_IN="$env:SESSION_EXPIRES_IN" `
            -e GOOGLE_CLIENT_ID="$env:GOOGLE_CLIENT_ID" `
            -e GOOGLE_CLIENT_SECRET="$env:GOOGLE_CLIENT_SECRET" `
            -e GOOGLE_CALLBACK_URL="$env:GOOGLE_CALLBACK_URL" `
            -e FRONTEND_ORIGIN="$env:FRONTEND_ORIGIN" `
            -e FRONTEND_GOOGLE_CALLBACK_URL="$env:FRONTEND_GOOGLE_CALLBACK_URL" `
            --link juno-mongo `
            juno-backend
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Message "Failed to start Backend container"
            exit 1
        }
    }
    
    # Wait for backend to be ready
    Write-Status "Waiting for Backend to be ready..."
    Start-Sleep -Seconds 15
    
    # Run Frontend container
    Write-Status "Starting Frontend container..."
    $frontendRunning = docker ps --filter "name=juno-client" --format "{{.Names}}"
    if ($frontendRunning -ne "juno-client") {
        docker run -d `
            --name juno-client `
            -p 3000:80 `
            -e VITE_API_URL="http://localhost:8000" `
            juno-client
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Message "Failed to start Frontend container"
            exit 1
        }
    }
    
    Write-Success "All containers started successfully!"
}

# Check if containers are running
function Check-Containers {
    Write-Status "Checking container status..."
    
    $backendStatus = docker ps --filter "name=juno-backend" --format "{{.Names}}"
    if ($backendStatus -eq "juno-backend") {
        Write-Success "Backend container is running"
    } else {
        Write-Error-Message "Backend container is not running"
    }
    
    $frontendStatus = docker ps --filter "name=juno-client" --format "{{.Names}}"
    if ($frontendStatus -eq "juno-client") {
        Write-Success "Frontend container is running"
    } else {
        Write-Error-Message "Frontend container is not running"
    }
    
    $mongoStatus = docker ps --filter "name=juno-mongo" --format "{{.Names}}"
    if ($mongoStatus -eq "juno-mongo") {
        Write-Success "MongoDB container is running"
    } else {
        Write-Error-Message "MongoDB container is not running"
    }
}

# Show logs
function Show-Logs {
    Write-Status "Backend logs:"
    docker logs juno-backend 2>$null
    
    Write-Status "Frontend logs:"
    docker logs juno-client 2>$null
    
    Write-Status "MongoDB logs:"
    docker logs juno-mongo 2>$null
}

# Clean up function
function Clean- up {
    Write-Status "Cleaning up containers and volumes..."
    Stop-Containers
    
    # Remove volume if it exists
    $volumeExists = docker volume ls --filter "name=juno-mongo-data" --format "{{.Name}}" 2>$null
    if ($volumeExists -eq "juno-mongo-data") {
        docker volume rm juno-mongo-data 2>$null | Out-Null
    }
    
    Write-Success "Cleanup completed!"
}

# Main function
function Main {
    param([string]$Command = "build-run")
    
    switch ($Command) {
        "build" {
            Write-Status "Building containers only..."
            Check-Docker
            Load-Env
            Build-Backend
            Build-Frontend
        }
        "run" {
            Write-Status "Running containers only..."
            Check-Docker
            Load-Env
            Stop-Containers
            Run-Containers
            Check-Containers
        }
        "build-run" {
            Write-Status "Building and running containers..."
            Check-Docker
            Load-Env
            Build-Backend
            Build-Frontend
            Stop-Containers
            Run-Containers
            Check-Containers
        }
        "logs" {
            Write-Status "Showing container logs..."
            Show-Logs
        }
        "stop" {
            Write-Status "Stopping containers..."
            Stop-Containers
        }
        "status" {
            Check-Containers
        }
        "clean" {
            Clean-Up
        }
        default {
            Write-Host "Usage: $PSCommandPath [build|run|build-run|logs|stop|status|clean]" -ForegroundColor $InfoColor
            Write-Host "  build-run: Build and run containers (default)" -ForegroundColor $InfoColor
            Write-Host "  build: Build containers only" -ForegroundColor $InfoColor
            Write-Host "  run: Run containers only" -ForegroundColor $InfoColor
            Write-Host "  logs: Show container logs" -ForegroundColor $InfoColor
            Write-Host "  stop: Stop all containers" -ForegroundColor $InfoColor
            Write-Host "  status: Check container status" -ForegroundColor $InfoColor
            Write-Host "  clean: Stop containers and remove volumes" -ForegroundColor $InfoColor
            exit 1
        }
    }
    
    Write-Success "Script completed successfully!"
    
    if ($Command -ne "stop" -and $Command -ne "clean") {
        Write-Status "Application is running:"
        Write-Status "  Frontend: http://localhost:3000"
        Write-Status "  Backend: http://localhost:8000"
        Write-Status "  MongoDB: localhost:27017"
    }
}

# Run main function with argument
Main $args[0]