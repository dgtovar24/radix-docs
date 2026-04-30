---
title: Docker Development
description: Cómo usar Docker y Docker Compose para el desarrollo local del ecosistema Radix
author: Documentation Bot
date: 2026-04-27
tags:
  - development
  - docker
  - compose
  - local
module: root
status: active
---

# Docker Development

## Descripción General

El ecosistema Radix puede ejecutarse parcialmente en contenedores Docker. Esta guía cubre el setup de desarrollo con Docker.

---

## Backend con Docker

### Build Image

```bash
cd radix-api
docker build -t radix-api:local .
```

### Run Container

```bash
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e DB_HOST=mysql-host \
  -e DB_PORT=3306 \
  -e DB_NAME=radixDB \
  -e DB_USER=root \
  -e DB_PASSWORD=test \
  radix-api:local
```

### docker-compose.yml (Backend + MySQL)

```yaml
version: '3.8'

services:
  api:
    build: ../radix-api
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_NAME=radixDB
      - DB_USER=root
      - DB_PASSWORD=test
    depends_on:
      mysql:
        condition: service_healthy

  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: test
      MYSQL_DATABASE: radixDB
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  mysql_data:
```

### Ejecutar

```bash
docker-compose up -d
docker-compose ps
docker-compose logs -f api
```

---

## Frontend Web con Docker

### Dockerfile Explicado

```dockerfile
# Builder stage (Bun)
FROM oven/bun:1.2 AS builder
WORKDIR /app
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun run build

# Runner stage (Node)
FROM node:22-slim AS runner
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "./dist/server/entry.mjs"]
```

### Build y Run

```bash
cd radix-web
docker build -t radix-web:local .
docker run -p 4321:4321 radix-web:local
```

### Acceder

```
http://localhost:4321
```

---

## Android (Solo Build)

El APK no se corre en Docker, pero se puede construir:

```bash
cd radix_app
docker run --rm -v $(pwd):/app -w /app gradle:9.3 ./gradlew assembleDebug
```

### Output

```
app/build/outputs/apk/debug/app-debug.apk
```

---

## iOS (No Soportado en Docker)

iOS requiere Xcode/macOS. Solo se puede desarrollar en máquina Mac.

---

## Smartwatch (Wear OS)

Similar a Android - requiere Android SDK. Solo build en Docker:

```bash
cd radix_reloj
docker run --rm -v $(pwd):/app -w /app gradle:9.3 ./gradlew assembleDebug
```

---

## Desarrollo Multi-Container

Para correr backend + frontend simultáneamente:

### docker-compose.yml (Completo)

```yaml
version: '3.8'

services:
  # Backend API
  api:
    build: ./radix-api
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_NAME=radixDB
      - DB_USER=root
      - DB_PASSWORD=test
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - radix-net

  # Frontend Web
  web:
    build: ./radix-web
    ports:
      - "4321:4321"
    depends_on:
      - api
    environment:
      - API_URL=http://api:8080/v2
    networks:
      - radix-net

  # MySQL Database
  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: test
      MYSQL_DATABASE: radixDB
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - radix-net

networks:
  radix-net:
    driver: bridge

volumes:
  mysql_data:
```

### Ejecutar Todo

```bash
docker-compose up -d

# Ver logs
docker-compose logs -f

# Status
docker-compose ps
```

### URLs

| Servicio | URL |
|----------|-----|
| API | http://localhost:8080 |
| Web | http://localhost:4321 |
| MySQL | localhost:3306 |

---

## Limpiar

```bash
# Parar contenedores
docker-compose down

# Eliminar volúmenes
docker-compose down -v

# Eliminar imágenes
docker rmi radix-api:local radix-web:local
```

---

## Troubleshooting Docker

### Puerto en uso

```bash
# Ver qué usa el puerto 8080
lsof -i :8080

# Matar proceso
kill -9 <PID>
```

### MySQL connection refused

```bash
# Ver logs de MySQL
docker-compose logs mysql

# Reiniciar MySQL
docker-compose restart mysql
```

### API health check fail

```bash
# Ver logs del API
docker-compose logs api

# Reiniciar
docker-compose restart api
```

---

## Ver También

- [[Development-Setup]] - Setup completo de desarrollo
- [[Backend/Deployment]] - Deployment en producción