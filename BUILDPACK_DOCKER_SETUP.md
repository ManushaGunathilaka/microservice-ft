# Docker Compose Setup for Microservices with Cloud Native BuildPacks

## Overview
This docker-compose orchestrates a complete microservices architecture with:
- **5 Microservices**: API Gateway, Product, Order, Inventory, Notification
- **Databases**: MySQL (Order, Inventory), MongoDB (Product)
- **Message Broker**: Apache Kafka with ZooKeeper and Schema Registry
- **Authentication**: Keycloak with MySQL backend
- **Observability**: Prometheus, Grafana, Loki, Tempo
- **Network**: Isolated bridge network for all services

## Architecture - Cloud Native BuildPacks Approach

Instead of traditional Dockerfiles, Cloud Native BuildPacks (like Google Cloud Buildpacks, Heroku Buildpacks, or Spring Boot Buildpacks) automatically:
1. Detect the application type (Java/Maven)
2. Compile and optimize the build
3. Create efficient OCI-compliant container images
4. Apply security best practices and base image updates

### Advantages
✅ **No Dockerfile needed** - Automatic detection and building
✅ **Efficient layers** - Better caching and reuse
✅ **Security** - Automatic vulnerability scanning
✅ **Reproducible** - Consistent builds across environments
✅ **Small images** - Optimized base images

---

## Prerequisites

### System Requirements
- Docker Engine 20.10+
- Docker Compose 2.10+
- Cloud Native Buildpacks (pack CLI) - [Install](https://buildpacks.io/docs/tools/pack/)
- Maven 3.8+
- Java 21+

### Verify Installation
```bash
docker --version
docker-compose --version
pack --version
mvn --version
java -version
```

---

## Quick Start

### 1. Build Images with Cloud Native BuildPacks

#### Option A: Using `pack` CLI (Recommended)
```bash
# Build all microservices using pack
pack build api-gateway:0.0.1-SNAPSHOT \
  --path ./api-gateway \
  --builder paketobuildpacks/builder-jammy-base:latest
  
pack build product-service:0.0.1-SNAPSHOT \
  --path ./product \
  --builder paketobuildpacks/builder-jammy-base:latest
  
pack build order-service:0.0.1-SNAPSHOT \
  --path ./order \
  --builder paketobuildpacks/builder-jammy-base:latest
  
pack build inventory-service:0.0.1-SNAPSHOT \
  --path ./Inventory \
  --builder paketobuildpacks/builder-jammy-base:latest
  
pack build notification-service:0.0.1-SNAPSHOT \
  --path ./notification-service \
  --builder paketobuildpacks/builder-jammy-base:latest
```

#### Option B: Using Maven Spring Boot Plugin
```bash
# From each service directory
cd api-gateway && mvn spring-boot:build-image && cd ..
cd product && mvn spring-boot:build-image && cd ..
cd order && mvn spring-boot:build-image && cd ..
cd Inventory && mvn spring-boot:build-image && cd ..
cd notification-service && mvn spring-boot:build-image && cd ..
```

#### Option C: Using Docker with Buildpacks
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd):/workspace" -w /workspace \
  buildpacksio/pack \
  build api-gateway:0.0.1-SNAPSHOT --path ./api-gateway
```

### 2. Start All Services
```bash
docker-compose up -d
```

### 3. Verify Services are Running
```bash
docker-compose ps
```

Expected output:
```
CONTAINER ID   IMAGE                              COMMAND              STATUS
...
xxx            api-gateway:0.0.1-SNAPSHOT        "java -jar /app.jar" Up 10s
xxx            product-service:0.0.1-SNAPSHOT    "java -jar /app.jar" Up 10s
xxx            order-service:0.0.1-SNAPSHOT      "java -jar /app.jar" Up 10s
xxx            inventory-service:0.0.1-SNAPSHOT  "java -jar /app.jar" Up 10s
xxx            notification-service:...          "java -jar /app.jar" Up 10s
```

---

## Service Endpoints

### Microservices
| Service | URL | Health Check |
|---------|-----|------|
| API Gateway | http://localhost:9000 | http://localhost:9000/actuator/health |
| Product Service | http://localhost:8080 | http://localhost:8080/actuator/health |
| Order Service | http://localhost:8081 | http://localhost:8081/actuator/health |
| Inventory Service | http://localhost:8082 | http://localhost:8082/actuator/health |
| Notification Service | http://localhost:8083 | http://localhost:8083/actuator/health |

### Infrastructure
| Component | URL | Credentials |
|-----------|-----|-------------|
| Keycloak | http://localhost:8086/admin | admin / admin |
| Grafana | http://localhost:3000 | admin / admin |
| Prometheus | http://localhost:9090 | - |
| Loki | http://localhost:3100 | - |
| Tempo | http://localhost:3200 | - |
| Kafka Broker | localhost:9092 | - |
| Schema Registry | http://localhost:8085 | - |

### Databases
| Database | Host | Port | User | Password |
|----------|------|------|------|----------|
| MySQL Order | localhost | 3307 | manu | 1234 |
| MySQL Inventory | localhost | 3308 | root | 1234 |
| MongoDB Product | localhost | 27017 | root | 1234 |
| Keycloak MySQL | (internal) | 3306 | keycloak | password |

---

## Configuration

### Environment Variables
The docker-compose automatically configures all services. To customize:

1. Create a `.env` file in the project root:
```env
# Keycloak
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=admin

# MySQL Passwords
MYSQL_ROOT_PASSWORD=1234
MYSQL_ORDER_PASSWORD=1234
MYSQL_INVENTORY_PASSWORD=1234
KEYCLOAK_DB_PASSWORD=password

# MongoDB
MONGO_ROOT_PASSWORD=1234

# Service Ports
API_GATEWAY_PORT=9000
PRODUCT_SERVICE_PORT=8080
ORDER_SERVICE_PORT=8081
INVENTORY_SERVICE_PORT=8082
NOTIFICATION_SERVICE_PORT=8083
```

2. Modify docker-compose.yml services section to use these variables:
```yaml
environment:
  MYSQL_PASSWORD: ${MYSQL_ORDER_PASSWORD}
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

### Network Configuration
All services communicate via the `microservices-network` bridge network. Service names act as DNS:
- `mysql-order` resolves to the MySQL Order container
- `kafka-broker` resolves to Kafka
- `keycloak` resolves to Keycloak, etc.

---

## Command Reference

### Startup & Shutdown
```bash
# Start all services
docker-compose up -d

# Start with logs
docker-compose up

# Stop all services
docker-compose down

# Stop and remove volumes (careful: deletes data!)
docker-compose down -v

# Restart services
docker-compose restart
```

### Service Management
```bash
# View running services
docker-compose ps

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f api-gateway

# Check service health
docker-compose ps api-gateway

# Restart a specific service
docker-compose restart product-service
```

### Database Management
```bash
# Access MySQL Order
docker-compose exec mysql-order mysql -u manu -p1234 manu-orderdb-ms

# Access MongoDB
docker-compose exec mongodb-product mongosh

# Access Kafka
docker-compose exec kafka-broker kafka-broker-api-versions.sh
```

### Debugging
```bash
# Inspect network
docker network inspect microservices-network

# Check service dependencies
docker-compose config

# Validate compose file
docker-compose config --quiet

# View resource usage
docker stats
```

---

## Building with Cloud Native BuildPacks - Detailed Guide

### Using Paketo Buildpacks (Recommended)
```bash
# Install pack CLI if not present
# From https://buildpacks.io/docs/tools/pack/

# Build with default builder
pack build api-gateway:0.0.1-SNAPSHOT \
  --path ./api-gateway \
  --builder paketobuildpacks/builder-jammy-base:latest \
  --trust-builder

# Build with specific Java version and layers
pack build product-service:0.0.1-SNAPSHOT \
  --path ./product \
  --builder paketobuildpacks/builder-jammy-full:latest \
  --env BP_JVM_VERSION=21 \
  --pull-policy if-not-present
```

### Using Spring Boot Maven Plugin
Each microservice can be built with:
```bash
cd api-gateway
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=api-gateway:0.0.1-SNAPSHOT
cd ..
```

Requires pom.xml configuration:
```xml
<plugin>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-maven-plugin</artifactId>
  <version>4.0.4</version>
  <configuration>
    <image>
      <name>${project.artifactId}:${project.version}</name>
      <builder>paketobuildpacks/builder-jammy-full:latest</builder>
    </image>
  </configuration>
</plugin>
```

---

## Health Checks & Monitoring

### Spring Boot Actuator Endpoints
All services expose metrics and health via:
- Health: `/actuator/health`
- Metrics: `/actuator/metrics`
- Prometheus: `/actuator/prometheus`

### Kafka Broker Health
```bash
docker-compose exec kafka-broker kafka-broker-api-versions.sh \
  --bootstrap-server kafka-broker:29092
```

### Database Health
```bash
# MySQL
docker-compose exec mysql-order mysqladmin -u root -p1234 ping

# MongoDB
docker-compose exec mongodb-product mongosh --eval "db.adminCommand('ping')"
```

---

## Troubleshooting

### Service Won't Start
1. Check logs: `docker-compose logs api-gateway`
2. Check health: `docker-compose ps`
3. Verify ports aren't in use: `netstat -an | grep :9000`
4. Check buildpack build: `docker inspect api-gateway:0.0.1-SNAPSHOT`

### Port Conflicts
If port is already in use, modify docker-compose.yml:
```yaml
ports:
  - "9001:9000"  # External:Internal - change 9001 to unused port
```

### Network Issues
```bash
# Verify services can communicate
docker-compose exec api-gateway curl http://kafka-broker:29092

# Inspect network
docker network inspect microservices-network
```

### Database Connection Issues
1. Verify database is healthy: `docker-compose ps mysql-order`
2. Check credentials in environment variables
3. Verify network connectivity: `docker-compose exec order-service ping mysql-order`

### BuildPacks Image Size
Cloud Native Buildpacks produce larger images than minimal Dockerfiles but are more secure:
- Includes security patches
- Optimized layer caching
- Ready for production

To reduce size, use minimal builder or custom buildpacks.

---

## Production Considerations

### Security
- Change default passwords in `.env`
- Use secrets management (Docker secrets, Kubernetes)
- Enable authentication/authorization for all services
- Use SSL/TLS for external communication

### Persistence
- Volumes are stored in Docker's data directory
- For production: use external storage (NFS, cloud storage)
- Configure backup strategies for databases

### Scaling
- Multiple replicas require load balancing
- Use Docker Swarm or Kubernetes for orchestration
- Consider database replication and clustering

### Logging & Monitoring
- Configure centralized logging (ELK, Splunk)
- Set up alerting for metrics
- Use distributed tracing (Jaeger, Zipkin)
- Regular backup of monitoring data

---

## Next Steps

1. **Build all images**: Run the pack commands above
2. **Start services**: `docker-compose up -d`
3. **Verify health**: Check each service endpoint
4. **Configure applications**: Update application.properties in each service
5. **Deploy to production**: Use Kubernetes or cloud platform

---

## References

- [Cloud Native Buildpacks](https://buildpacks.io/)
- [Paketo Buildpacks](https://paketo.io/)
- [Spring Boot Container Images](https://spring.io/guides/topicals/spring-boot-docker/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Keycloak Documentation](https://www.keycloak.org/documentation.html)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
