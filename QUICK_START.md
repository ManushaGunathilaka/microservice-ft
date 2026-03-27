# Quick Start Guide - Docker Compose with Cloud Native BuildPacks

## Overview
This project uses **Cloud Native BuildPacks** to build microservice images automatically without traditional Dockerfiles. All services are orchestrated using Docker Compose at the parent project level.

---

## Prerequisites Setup (First Time Only)

### 1. Install Cloud Native BuildPacks CLI
```bash
# Windows (using Chocolatey)
choco install pack

# Mac (using Homebrew)
brew install buildpacks/tap/pack

# Linux (download from)
# https://buildpacks.io/docs/tools/pack/
```

### 2. Verify Installation
```bash
docker --version        # Should be 20.10+
docker-compose --version # Should be 2.10+
pack --version         # Should be v0.24+
mvn --version          # Should be 3.8+
java -version          # Should be 21+
```

### 3. Setup Environment (Optional)
```bash
# Copy example environment file
copy .env.example .env

# Edit .env to customize settings (optional)
```

---

## Quick Start (5 Minutes)

### Step 1: Build All Microservice Images

#### Option A: Windows (Recommended)
```bash
build-images.bat
```

#### Option B: Mac/Linux
```bash
chmod +x build-images.sh
./build-images.sh
```

#### Option C: Manual using Pack CLI
```bash
pack build api-gateway:0.0.1-SNAPSHOT --path ./api-gateway
pack build product-service:0.0.1-SNAPSHOT --path ./product
pack build order-service:0.0.1-SNAPSHOT --path ./order
pack build inventory-service:0.0.1-SNAPSHOT --path ./Inventory
pack build notification-service:0.0.1-SNAPSHOT --path ./notification-service
```

**Expected Output**: 5 successful image builds
```
✓ api-gateway:0.0.1-SNAPSHOT
✓ product-service:0.0.1-SNAPSHOT
✓ order-service:0.0.1-SNAPSHOT
✓ inventory-service:0.0.1-SNAPSHOT
✓ notification-service:0.0.1-SNAPSHOT
```

### Step 2: Start All Services

#### Windows
```bash
manage-compose.bat up
```

#### Mac/Linux
```bash
docker-compose up -d
```

**Wait 30-45 seconds** for all services to initialize and become healthy.

### Step 3: Verify Services are Running
```bash
# Windows
manage-compose.bat ps

# Mac/Linux
docker-compose ps
```

Expected: All services show "Up" status

### Step 4: Check Service Health

Open these URLs in your browser:
- **Dashboard**: http://localhost:3000 (Grafana - admin/admin)
- **API Gateway**: http://localhost:9000/actuator/health
- **Keycloak**: http://localhost:8086/admin (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100

---

## Common Operations

### View All Logs
```bash
# Windows
manage-compose.bat logs

# Mac/Linux
docker-compose logs -f
```

### View Specific Service Logs
```bash
# Windows
docker-compose logs -f api-gateway

# Mac/Linux (same)
docker-compose logs -f api-gateway
```

### Restart a Service
```bash
docker-compose restart api-gateway
```

### Stop All Services
```bash
# Windows
manage-compose.bat down

# Mac/Linux
docker-compose down
```

### Stop and Remove All Data
```bash
# WARNING: Deletes all database data!
docker-compose down -v
```

---

## Service Ports & Credentials

### Microservices

| Service | Port | URL |
|---------|------|-----|
| API Gateway | 9000 | http://localhost:9000 |
| Product Service | 8080 | http://localhost:8080 |
| Order Service | 8081 | http://localhost:8081 |
| Inventory Service | 8082 | http://localhost:8082 |
| Notification Service | 8083 | http://localhost:8083 |

### Infrastructure & Admin Tools

| Service | Port | URL | User | Password |
|---------|------|-----|------|----------|
| Keycloak | 8086 | http://localhost:8086/admin | admin | admin |
| Grafana | 3000 | http://localhost:3000 | admin | admin |
| Prometheus | 9090 | http://localhost:9090 | - | - |
| Loki | 3100 | http://localhost:3100 | - | - |
| Tempo | 3200 | http://localhost:3200 | - | - |
| Kafka Schema Registry | 8085 | http://localhost:8085 | - | - |

### Databases

| Database | Port | Host | User | Password |
|----------|------|------|------|----------|
| MySQL (Order) | 3307 | localhost | manu | 1234 |
| MySQL (Inventory) | 3308 | localhost | root | 1234 |
| MongoDB | 27017 | localhost | root | 1234 |
| Kafka Broker | 9092 | localhost | - | - |

---

## Troubleshooting

### Issue: "pack not found"
**Solution**: Install Cloud Native BuildPacks from https://buildpacks.io/docs/tools/pack/

### Issue: "Docker is not running"
**Solution**: Start Docker Desktop or Docker daemon

### Issue: Port already in use
**Solution**: Edit docker-compose.yml and change the port mapping:
```yaml
ports:
  - "9001:9000"  # Change 9001 to an unused port
```

### Issue: Services won't start
1. Check logs: `docker-compose logs api-gateway`
2. Verify images exist: `docker images | grep SNAPSHOT`
3. Ensure buildpacks build succeeded

### Issue: Database connection refused
1. Wait 30-45 seconds for database to initialize
2. Check database is running: `docker-compose ps mysql-order`
3. Verify network: `docker network inspect microservices-network`

### Issue: Out of disk space
**Solution**: Clean up unused Docker images:
```bash
docker image prune -a
```

### Issue: High CPU/Memory usage
**Solution**: 
- Check running services: `docker-compose ps`
- Check resource limits: `docker stats`
- Reduce number of running services

---

## File Structure

```
.
├── docker-compose.yml                 # Main orchestration file
├── BUILDPACK_DOCKER_SETUP.md          # Detailed documentation
├── QUICK_START.md                     # This file
├── build-images.bat                   # Build script (Windows)
├── build-images.sh                    # Build script (Mac/Linux)
├── manage-compose.bat                 # Management script (Windows)
├── .env.example                       # Environment variables template
└── [microservices]/
    ├── pom.xml
    ├── src/
    └── docker/
```

---

## Next Steps After Quick Start

### 1. Customize Configuration
- Copy `.env.example` to `.env`
- Update settings as needed
- Update docker-compose.yml services with variables

### 2. Configure Applications
- Edit `src/main/resources/application.properties` in each service
- Set database URLs, credentials, and other settings
- Configure Keycloak realms and clients

### 3. Deploy Data
- Initialize databases with schema
- Create Kafka topics: `docker-compose exec kafka-broker kafka-topics.sh`
- Configure Keycloak users and roles

### 4. Start Development
- Access API Gateway at http://localhost:9000
- Monitor with Grafana at http://localhost:3000
- Check logs with: `docker-compose logs -f`

---

## Advanced Topics

### Building with Spring Boot Maven Plugin
Instead of pack CLI, use Maven directly:
```bash
cd api-gateway
mvn spring-boot:build-image \
  -Dspring-boot.build-image.imageName=api-gateway:0.0.1-SNAPSHOT
cd ..
```

### Using Different Buildpacks
```bash
# Use minimal builder (smaller images)
pack build api-gateway:0.0.1-SNAPSHOT \
  --path ./api-gateway \
  --builder paketobuildpacks/builder-jammy-tiny:latest

# Use full builder (more tools/debugging)
pack build api-gateway:0.0.1-SNAPSHOT \
  --path ./api-gateway \
  --builder paketobuildpacks/builder-jammy-full:latest
```

### Database Access
```bash
# MySQL Order
docker-compose exec mysql-order mysql -u manu -p1234 manu-orderdb-ms

# MongoDB
docker-compose exec mongodb-product mongosh

# Run SQL script
docker-compose exec mysql-order mysql -u manu -p1234 < schema.sql
```

### Production Deployment
See `BUILDPACK_DOCKER_SETUP.md` for security, scaling, and monitoring guidance.

---

## Performance Tips

1. **Use Volume Mounts for Development**
   - Mount source code to enable live reload
   ```yaml
   volumes:
     - ./api-gateway/src:/app/src
   ```

2. **Use Health Checks**
   - Services have built-in health checks
   - Allows gradual startup and recovery

3. **Limit Logging**
   - Configure LOG_LEVEL in environment
   - Reduces container resource usage

4. **Use Named Volumes**
   - Persistent data storage
   - Better performance than bind mounts

---

## Getting Help

### Documentation
- See `BUILDPACK_DOCKER_SETUP.md` for comprehensive guide
- Check individual service README.md files
- Review pom.xml files for dependencies

### Debugging
```bash
# Check docker-compose configuration
docker-compose config

# Inspect network
docker network inspect microservices-network

# Check service dependencies
docker-compose exec api-gateway curl -v http://kafka-broker:29092

# View service environment
docker-compose exec api-gateway env | sort
```

### Common Commands Reference
```bash
# Build and start
docker-compose up -d --build

# View all services
docker-compose ps

# Follow logs
docker-compose logs -f [service-name]

# Execute command in service
docker-compose exec [service-name] [command]

# Scale service replicas
docker-compose up -d --scale order-service=3

# Remove everything
docker-compose down -v
```

---

## Support & Contact

For issues or questions:
1. Check `BUILDPACK_DOCKER_SETUP.md`
2. Review docker-compose logs: `docker-compose logs`
3. Verify prerequisites are installed correctly
4. Ensure all ports are available

---

**Happy Building! 🚀**
