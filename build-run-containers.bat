@echo off
REM Juno Project - Build and Run Script (Batch)
REM This script builds and runs both backend and frontend containers with MongoDB

chcp 65001 > nul

REM Colors for output
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

REM Print colored output using PowerShell
call :print_status "Starting Juno Project build and run script..."

REM Check if Docker is installed and running
docker --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not installed. Please install Docker first."
    exit /b 1
)

docker ps >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not running. Please start Docker daemon."
    exit /b 1
)

REM Load environment variables from .env if exists
if exist ".env" (
    call :print_status "Loading environment variables from .env file"
    for /f "usebackq eol=# delims=" %%i in (".env") do (
        call set "%%i"
    )
) else (
    call :print_warning ".env file not found. Using default values."
    set "MONGO_URI=mongodb://mongo:27017/juno"
    set "SESSION_SECRET=your-very-secure-session-secret-here"
    set "SESSION_EXPIRES_IN=1d"
    set "GOOGLE_CLIENT_ID="
    set "GOOGLE_CLIENT_SECRET="
    set "GOOGLE_CALLBACK_URL=http://localhost:8000/api/auth/google/callback"
    set "FRONTEND_ORIGIN=http://localhost:3000"
    set "FRONTEND_GOOGLE_CALLBACK_URL=http://localhost:3000/google/callback"
)

REM Set default command to build-run if no argument provided
if "%~1"=="" set "CMD=build-run" else set "CMD=%~1"

REM Process command
if /i "%CMD%"=="build" (
    call :build_backend
    call :build_frontend
) else if /i "%CMD%"=="run" (
    call :stop_containers
    call :run_containers
    call :check_containers
) else if /i "%CMD%"=="build-run" (
    call :build_backend
    call :build_frontend
    call :stop_containers
    call :run_containers
    call :check_containers
) else if /i "%CMD%"=="logs" (
    call :show_logs
) else if /i "%CMD%"=="stop" (
    call :stop_containers
) else if /i "%CMD%"=="status" (
    call :check_containers
) else if /i "%CMD%"=="clean" (
    call :stop_containers
    call :print_status "Removing MongoDB volume..."
    docker volume rm juno-mongo-data 2>nul
    call :print_success "Cleanup completed!"
) else (
    echo Usage: %~nx0 [build^|run^|build-run^|logs^|stop^|status^|clean]
    echo   build-run: Build and run containers (default)
    echo   build: Build containers only
    echo   run: Run containers only
    echo   logs: Show container logs
    echo   stop: Stop all containers
    echo   status: Check container status
    echo   clean: Stop containers and remove volumes
    exit /b 1
)

if /i not "%CMD%"=="stop" if /i not "%CMD%"=="clean" (
    call :print_success "Script completed successfully!"
    call :print_status "Application is running:"
    call :print_status "  Frontend: http://localhost:3000"
    call :print_status "  Backend: http://localhost:8000"
    call :print_status "  MongoDB: localhost:27017"
)

goto :eof

REM Functions
:print_status
powershell -Command "Write-Host '%~1' -ForegroundColor Blue"
goto :eof

:print_success
powershell -Command "Write-Host '%~1' -ForegroundColor Green"
goto :eof

:print_warning
powershell -Command "Write-Host '%~1' -ForegroundColor Yellow"
goto :eof

:print_error
powershell -Command "Write-Host '%~1' -ForegroundColor Red"
goto :eof

:build_backend
call :print_status "Building backend image..."
pushd backend
if not exist "Dockerfile" (
    call :print_error "Dockerfile not found in backend directory. Please run the Docker setup script first."
    popd
    exit /b 1
)
docker build -t juno-backend .
if errorlevel 1 (
    call :print_error "Failed to build backend image"
    popd
    exit /b 1
)
call :print_success "Backend image built successfully!"
popd
goto :eof

:build_frontend
call :print_status "Building frontend image..."
pushd client
if not exist "Dockerfile" (
    call :print_error "Dockerfile not found in client directory. Please run the Docker setup script first."
    popd
    exit /b 1
)
docker build -t juno-client .
if errorlevel 1 (
    call :print_error "Failed to build frontend image"
    popd
    exit /b 1
)
call :print_success "Frontend image built successfully!"
popd
goto :eof

:stop_containers
call :print_status "Stopping existing containers..."
docker stop juno-backend juno-client juno-mongo 2>nul
docker rm juno-backend juno-client juno-mongo 2>nul
call :print_success "Existing containers stopped and removed."
goto :eof

:run_containers
call :print_status "Starting Juno application containers..."

call :print_status "Starting MongoDB container..."
docker run -d ^
    --name juno-mongo ^
    -p 27017:27017 ^
    -e MONGO_INITDB_ROOT_USERNAME=admin ^
    -e MONGO_INITDB_ROOT_PASSWORD=password ^
    -v juno-mongo-data:/data/db ^
    --health-cmd="echo \"db.runCommand('ping').ok\" | mongosh localhost:27017/test --quiet" ^
    --health-interval=10s ^
    --health-timeout=3s ^
    --health-retries=5 ^
    mongo:7.0

call :print_status "Waiting for MongoDB to be ready..."
timeout /t 10 /nobreak >nul

call :print_status "Starting Backend container..."
docker run -d ^
    --name juno-backend ^
    -p 8000:8000 ^
    -e MONGO_URI=mongodb://juno-mongo:27017/juno ^
    -e SESSION_SECRET=%SESSION_SECRET% ^
    -e SESSION_EXPIRES_IN=%SESSION_EXPIRES_IN% ^
    -e GOOGLE_CLIENT_ID=%GOOGLE_CLIENT_ID% ^
    -e GOOGLE_CLIENT_SECRET=%GOOGLE_CLIENT_SECRET% ^
    -e GOOGLE_CALLBACK_URL=%GOOGLE_CALLBACK_URL% ^
    -e FRONTEND_ORIGIN=%FRONTEND_ORIGIN% ^
    -e FRONTEND_GOOGLE_CALLBACK_URL=%FRONTEND_GOOGLE_CALLBACK_URL% ^
    --link juno-mongo ^
    juno-backend

call :print_status "Waiting for Backend to be ready..."
timeout /t 15 /nobreak >nul

call :print_status "Starting Frontend container..."
docker run -d ^
    --name juno-client ^
    -p 3000:80 ^
    -e VITE_API_URL=http://localhost:8000 ^
    juno-client

call :print_success "All containers started successfully!"
goto :eof

:check_containers
call :print_status "Checking container status..."

set backend_running=
for /f "usebackq" %%i in (`docker ps --filter "name=juno-backend" --format "{{.Names}}" 2^>nul`) do set "backend_running=%%i"
if "%backend_running%"=="juno-backend" (
    call :print_success "Backend container is running"
) else (
    call :print_error "Backend container is not running"
)

set frontend_running=
for /f "usebackq" %%i in (`docker ps --filter "name=juno-client" --format "{{.Names}}" 2^>nul`) do set "frontend_running=%%i"
if "%frontend_running%"=="juno-client" (
    call :print_success "Frontend container is running"
) else (
    call :print_error "Frontend container is not running"
)

set mongo_running=
for /f "usebackq" %%i in (`docker ps --filter "name=juno-mongo" --format "{{.Names}}" 2^>nul`) do set "mongo_running=%%i"
if "%mongo_running%"=="juno-mongo" (
    call :print_success "MongoDB container is running"
) else (
    call :print_error "MongoDB container is not running"
)

goto :eof

:show_logs
call :print_status "Backend logs:"
docker logs juno-backend 2>nul

call :print_status "Frontend logs:"
docker logs juno-client 2>nul

call :print_status "MongoDB logs:"
docker logs juno-mongo 2>nul

goto :eof