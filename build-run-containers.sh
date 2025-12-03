#!/bin/bash

# Juno Project - Build and Run Script
# This script builds and runs both backend and frontend containers with MongoDB

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker daemon."
        exit 1
    fi
}

# Load environment variables
load_env() {
    if [ -f ".env" ]; then
        print_status "Loading environment variables from .env file"
        export $(grep -v '^#' .env | xargs)
    else
        print_warning ".env file not found. Using default values."
        # Set default values if .env doesn't exist
        export MONGO_URI=${MONGO_URI:-"mongodb://mongo:27017/juno"}
        export SESSION_SECRET=${SESSION_SECRET:-"your-very-secure-session-secret-here"}
        export SESSION_EXPIRES_IN=${SESSION_EXPIRES_IN:-"1d"}
        export GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-""}
        export GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-""}
        export GOOGLE_CALLBACK_URL=${GOOGLE_CALLBACK_URL:-"http://localhost:8000/api/auth/google/callback"}
        export FRONTEND_ORIGIN=${FRONTEND_ORIGIN:-"http://localhost:3000"}
        export FRONTEND_GOOGLE_CALLBACK_URL=${FRONTEND_GOOGLE_CALLBACK_URL:-"http://localhost:3000/google/callback"}
    fi
}

# Build backend image
build_backend() {
    print_status "Building backend image..."
    cd backend
    
    # Check if Dockerfile exists
    if [ ! -f "Dockerfile" ]; then
        print_error "Dockerfile not found in backend directory. Creating it..."
        print_error "Please run the Docker setup script first."
        exit 1
    fi
    
    docker build -t juno-backend .
    print_success "Backend image built successfully!"
    cd ..
}

# Build frontend image
build_frontend() {
    print_status "Building frontend image..."
    cd client
    
    # Check if Dockerfile exists
    if [ ! -f "Dockerfile" ]; then
        print_error "Dockerfile not found in client directory. Creating it..."
        print_error "Please run the Docker setup script first."
        exit 1
    fi
    
    docker build -t juno-client .
    print_success "Frontend image built successfully!"
    cd ..
}

# Stop existing containers
stop_containers() {
    print_status "Stopping existing containers..."
    
    # Stop and remove containers if they exist
    docker stop juno-backend juno-client juno-mongo 2>/dev/null || true
    docker rm juno-backend juno-client juno-mongo 2>/dev/null || true
    
    print_success "Existing containers stopped and removed."
}

# Run the application
run_containers() {
    print_status "Starting Juno application containers..."
    
    # Run MongoDB container
    print_status "Starting MongoDB container..."
    docker run -d \
        --name juno-mongo \
        -p 27017:27017 \
        -e MONGO_INITDB_ROOT_USERNAME=admin \
        -e MONGO_INITDB_ROOT_PASSWORD=password \
        -v juno-mongo-data:/data/db \
        --health-cmd='echo "db.runCommand(\"ping\").ok" | mongosh localhost:27017/test --quiet' \
        --health-interval=10s \
        --health-timeout=3s \
        --health-retries=5 \
        mongo:7.0
    
    # Wait for MongoDB to be ready
    print_status "Waiting for MongoDB to be ready..."
    sleep 10
    
    # Run Backend container
    print_status "Starting Backend container..."
    docker run -d \
        --name juno-backend \
        -p 8000:8000 \
        --env-file .env \
        --env MONGO_URI=mongodb://juno-mongo:27017/juno \
        --env SESSION_SECRET=${SESSION_SECRET} \
        --env SESSION_EXPIRES_IN=${SESSION_EXPIRES_IN} \
        --env GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID} \
        --env GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET} \
        --env GOOGLE_CALLBACK_URL=${GOOGLE_CALLBACK_URL} \
        --env FRONTEND_ORIGIN=${FRONTEND_ORIGIN} \
        --env FRONTEND_GOOGLE_CALLBACK_URL=${FRONTEND_GOOGLE_CALLBACK_URL} \
        --link juno-mongo \
        juno-backend
    
    # Wait for backend to be ready
    print_status "Waiting for Backend to be ready..."
    sleep 15
    
    # Run Frontend container
    print_status "Starting Frontend container..."
    docker run -d \
        --name juno-client \
        -p 3000:80 \
        --env VITE_API_URL=http://localhost:8000 \
        juno-client
    
    print_success "All containers started successfully!"
}

# Check if containers are running
check_containers() {
    print_status "Checking container status..."
    
    if docker ps | grep juno-backend > /dev/null; then
        print_success "Backend container is running"
    else
        print_error "Backend container is not running"
    fi
    
    if docker ps | grep juno-client > /dev/null; then
        print_success "Frontend container is running"
    else
        print_error "Frontend container is not running"
    fi
    
    if docker ps | grep juno-mongo > /dev/null; then
        print_success "MongoDB container is running"
    else
        print_error "MongoDB container is not running"
    fi
}

# Show logs
show_logs() {
    print_status "Backend logs:"
    docker logs juno-backend
    
    print_status "Frontend logs:"
    docker logs juno-client
    
    print_status "MongoDB logs:"
    docker logs juno-mongo
}

# Main function
main() {
    case "${1:-build-run}" in
        build)
            print_status "Building containers only..."
            check_docker
            load_env
            build_backend
            build_frontend
            ;;
        run)
            print_status "Running containers only..."
            check_docker
            load_env
            stop_containers
            run_containers
            check_containers
            ;;
        build-run|*)
            print_status "Building and running containers..."
            check_docker
            load_env
            build_backend
            build_frontend
            stop_containers
            run_containers
            check_containers
            ;;
        logs)
            print_status "Showing container logs..."
            show_logs
            ;;
        stop)
            print_status "Stopping containers..."
            stop_containers
            ;;
        status)
            check_containers
            ;;
        clean)
            print_status "Cleaning up containers and volumes..."
            stop_containers
            docker volume rm juno-mongo-data 2>/dev/null || true
            print_success "Cleanup completed!"
            ;;
        *)
            echo "Usage: $0 [build|run|build-run|logs|stop|status|clean]"
            echo "  build-run: Build and run containers (default)"
            echo "  build: Build containers only"
            echo "  run: Run containers only"
            echo "  logs: Show container logs"
            echo "  stop: Stop all containers"
            echo "  status: Check container status"
            echo "  clean: Stop containers and remove volumes"
            exit 1
            ;;
    esac
    
    print_success "Script completed successfully!"
    
    if [ "$1" != "stop" ] && [ "$1" != "clean" ]; then
        print_status "Application is running:"
        print_status "  Frontend: http://localhost:3000"
        print_status "  Backend: http://localhost:8000"
        print_status "  MongoDB: localhost:27017"
    fi
}

# Run main function with all arguments
main "$@"