@echo off
REM ================================================
REM Cloud Native BuildPacks Build Script for Windows
REM ================================================
REM This script builds all microservices using Cloud Native Buildpacks
REM Requirements: pack CLI, Docker, Maven

echo.
echo ============================================
echo Building Microservices with Cloud Native BuildPacks
echo ============================================
echo.

REM Check if pack CLI is installed
where pack >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] pack CLI not found. Please install from https://buildpacks.io/docs/tools/pack/
    exit /b 1
)

REM Check if Docker is running
docker ps >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop.
    exit /b 1
)

REM Set buildpack builder
set BUILDER=paketobuildpacks/builder-jammy-full:latest
set PULL_POLICY=if-not-present

echo [INFO] Using builder: %BUILDER%
echo [INFO] Java version: 21
echo.

REM Create logs directory
if not exist "build-logs" mkdir build-logs
set LOG_DIR=%cd%\build-logs
set LOG_FILE=%LOG_DIR%\build-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.log

echo [INFO] Build logs will be saved to: %LOG_FILE%
echo.

REM ================================================
REM Build API Gateway
REM ================================================
echo [1/5] Building API Gateway...
echo ============================================ >> %LOG_FILE%
echo Building API Gateway >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%

pack build api-gateway:0.0.1-SNAPSHOT ^
  --path ./api-gateway ^
  --builder %BUILDER% ^
  --trust-builder ^
  --pull-policy %PULL_POLICY% ^
  --env BP_JVM_VERSION=21 >> %LOG_FILE% 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [FAILED] API Gateway build failed. See %LOG_FILE% for details.
    exit /b 1
)
echo [OK] API Gateway built successfully.
echo.

REM ================================================
REM Build Product Service
REM ================================================
echo [2/5] Building Product Service...
echo ============================================ >> %LOG_FILE%
echo Building Product Service >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%

pack build product-service:0.0.1-SNAPSHOT ^
  --path ./product ^
  --builder %BUILDER% ^
  --trust-builder ^
  --pull-policy %PULL_POLICY% ^
  --env BP_JVM_VERSION=21 >> %LOG_FILE% 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [FAILED] Product Service build failed. See %LOG_FILE% for details.
    exit /b 1
)
echo [OK] Product Service built successfully.
echo.

REM ================================================
REM Build Order Service
REM ================================================
echo [3/5] Building Order Service...
echo ============================================ >> %LOG_FILE%
echo Building Order Service >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%

pack build order-service:0.0.1-SNAPSHOT ^
  --path ./order ^
  --builder %BUILDER% ^
  --trust-builder ^
  --pull-policy %PULL_POLICY% ^
  --env BP_JVM_VERSION=21 >> %LOG_FILE% 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [FAILED] Order Service build failed. See %LOG_FILE% for details.
    exit /b 1
)
echo [OK] Order Service built successfully.
echo.

REM ================================================
REM Build Inventory Service
REM ================================================
echo [4/5] Building Inventory Service...
echo ============================================ >> %LOG_FILE%
echo Building Inventory Service >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%

pack build inventory-service:0.0.1-SNAPSHOT ^
  --path ./Inventory ^
  --builder %BUILDER% ^
  --trust-builder ^
  --pull-policy %PULL_POLICY% ^
  --env BP_JVM_VERSION=21 >> %LOG_FILE% 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [FAILED] Inventory Service build failed. See %LOG_FILE% for details.
    exit /b 1
)
echo [OK] Inventory Service built successfully.
echo.

REM ================================================
REM Build Notification Service
REM ================================================
echo [5/5] Building Notification Service...
echo ============================================ >> %LOG_FILE%
echo Building Notification Service >> %LOG_FILE%
echo ============================================ >> %LOG_FILE%

pack build notification-service:0.0.1-SNAPSHOT ^
  --path ./notification-service ^
  --builder %BUILDER% ^
  --trust-builder ^
  --pull-policy %PULL_POLICY% ^
  --env BP_JVM_VERSION=21 >> %LOG_FILE% 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [FAILED] Notification Service build failed. See %LOG_FILE% for details.
    exit /b 1
)
echo [OK] Notification Service built successfully.
echo.

REM ================================================
REM Verify Images
REM ================================================
echo ============================================
echo Verifying Built Images
echo ============================================
docker images | findstr "SNAPSHOT"
echo.

REM ================================================
REM Summary
REM ================================================
echo.
echo ============================================
echo BUILD COMPLETE!
echo ============================================
echo.
echo All microservices have been built successfully!
echo.
echo Next steps:
echo 1. Start services: docker-compose up -d
echo 2. Check status: docker-compose ps
echo 3. View logs: docker-compose logs -f
echo.
echo Build logs saved to: %LOG_FILE%
echo.
pause
