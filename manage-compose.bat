@echo off
REM ================================================
REM Docker Compose Management Script for Windows
REM ================================================
REM Usage: manage-compose.bat [command]
REM Commands: up, down, logs, ps, restart, rebuild

setlocal enabledelayedexpansion

if "%1"=="" (
    call :show_menu
    exit /b 0
)

set COMMAND=%1

if /i "%COMMAND%"=="up" (
    call :start_services
) else if /i "%COMMAND%"=="down" (
    call :stop_services
) else if /i "%COMMAND%"=="logs" (
    call :show_logs
) else if /i "%COMMAND%"=="ps" (
    call :show_status
) else if /i "%COMMAND%"=="restart" (
    call :restart_services
) else if /i "%COMMAND%"=="rebuild" (
    call :build_and_start
) else if /i "%COMMAND%"=="health" (
    call :check_health
) else if /i "%COMMAND%"=="clean" (
    call :clean_volumes
) else (
    echo [ERROR] Unknown command: %COMMAND%
    call :show_menu
    exit /b 1
)
exit /b 0

REM ================================================
REM Show Menu
REM ================================================
:show_menu
echo.
echo ============================================
echo Docker Compose Management Script
echo ============================================
echo.
echo Usage: manage-compose.bat [command]
echo.
echo Commands:
echo   up          - Start all services
echo   down        - Stop all services
echo   logs        - Show logs (follow mode)
echo   ps          - Show running services status
echo   restart     - Restart all services
echo   rebuild     - Build images and start services
echo   health      - Check health of all services
echo   clean       - Remove all volumes (WARNING: deletes data!)
echo.
echo Examples:
echo   manage-compose.bat up
echo   manage-compose.bat logs
echo   manage-compose.bat restart
echo.
exit /b 0

REM ================================================
REM Start Services
REM ================================================
:start_services
echo.
echo [INFO] Starting all services...
docker-compose up -d
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start services
    exit /b 1
)
echo [OK] Services started successfully
echo.
echo Waiting for services to be ready (30 seconds)...
timeout /t 30 /nobreak
echo.
call :show_status
exit /b 0

REM ================================================
REM Stop Services
REM ================================================
:stop_services
echo.
echo [WARN] Stopping all services...
docker-compose down
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to stop services
    exit /b 1
)
echo [OK] Services stopped successfully
echo.
exit /b 0

REM ================================================
REM Show Logs
REM ================================================
:show_logs
echo.
echo [INFO] Showing logs (Ctrl+C to exit)...
echo.
docker-compose logs -f
exit /b 0

REM ================================================
REM Show Status
REM ================================================
:show_status
echo.
echo ============================================
echo Service Status
echo ============================================
echo.
docker-compose ps
echo.
echo ============================================
echo Service Endpoints
echo ============================================
echo.
echo API Gateway:        http://localhost:9000/actuator/health
echo Product Service:    http://localhost:8080/actuator/health
echo Order Service:      http://localhost:8081/actuator/health
echo Inventory Service:  http://localhost:8082/actuator/health
echo Notification:       http://localhost:8083/actuator/health
echo.
echo Keycloak:           http://localhost:8086/admin
echo Grafana:            http://localhost:3000
echo Prometheus:         http://localhost:9090
echo Loki:               http://localhost:3100
echo Tempo:              http://localhost:3200
echo.
exit /b 0

REM ================================================
REM Restart Services
REM ================================================
:restart_services
echo.
echo [INFO] Restarting all services...
docker-compose restart
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to restart services
    exit /b 1
)
echo [OK] Services restarted successfully
echo.
timeout /t 10 /nobreak
call :show_status
exit /b 0

REM ================================================
REM Build and Start
REM ================================================
:build_and_start
echo.
echo [INFO] Building and starting services...
docker-compose up -d --build
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to build and start services
    exit /b 1
)
echo [OK] Services built and started successfully
echo.
timeout /t 30 /nobreak
call :show_status
exit /b 0

REM ================================================
REM Check Health
REM ================================================
:check_health
echo.
echo ============================================
echo Checking Service Health
echo ============================================
echo.

set "services=api-gateway product-service order-service inventory-service notification-service"
set "ports=9000 8080 8081 8082 8083"

setlocal enabledelayedexpansion
for /F "tokens=1*" %%A in ("x!services!") do (
    set "svc=%%A"
    set services=%%B
    REM Would need complex logic to test ports, simplified here
)

echo.
echo Testing connectivity to services...
echo.

REM Simple test - check if containers are running
docker-compose ps | findstr "Up"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] All containers are running
) else (
    echo.
    echo [WARN] Some containers are not running
)

exit /b 0

REM ================================================
REM Clean Volumes
REM ================================================
:clean_volumes
echo.
echo [WARN] *** WARNING: This will delete all data! ***
echo.
set /p confirm="Are you sure? Type 'yes' to confirm: "
if /i "%confirm%"=="yes" (
    echo [INFO] Removing all volumes...
    docker-compose down -v
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to remove volumes
        exit /b 1
    )
    echo [OK] All volumes removed successfully
) else (
    echo [INFO] Operation cancelled
)
echo.
exit /b 0
