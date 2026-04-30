---
title: Deployment Guide
description: Guía completa de despliegue de radix-api en Dokploy - variables de entorno, Docker y configuración
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - deployment
  - docker
  - dokploy
module: Backend
status: active
---

# Deployment Guide

## Plataforma de Despliegue

Dokploy - VPS management platform.

---

## Docker Configuration

### Dockerfile

Ubicación: `/radix-api/Dockerfile`

```dockerfile
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

RUN chmod +x mvnw && ./mvnw dependency:go-offline -q

COPY src src
RUN ./mvnw clean package -DskipTests -q

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
  CMD wget -qO- http://localhost:8080/v1/ || exit 1

ENTRYPOINT ["java", "-Dspring.profiles.active=prod", "-jar", "app.jar"]
```

### Características

- **Multi-stage build**: JDK para compilación, JRE para producción
- **Alpine Linux**: Imagen mínima y segura
- **Health check**: Verifica que el API responda en `/v1/`
- **Profile activo**: `-Dspring.profiles.active=prod` para MySQL

---

## Variables de Entorno

Configurar en Dokploy:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `DB_HOST` | `base-de-datos-radix-6awzza` | Hostname interno de MySQL |
| `DB_PORT` | `3306` | Puerto de MySQL |
| `DB_NAME` | `radixDB` | Nombre de la base de datos |
| `DB_USER` | `root` | Usuario de MySQL |
| `DB_PASSWORD` | `Diegoelmejor1.0` | Contraseña de MySQL |
| `SERVER_PORT` | `8080` | Puerto de la aplicación |
| `CONTEXT_PATH` | `/v1` | Path del contexto (default) |

### Conexión Pública MySQL

```
mysql://root:Diegoelmejor1.0@132.145.194.97:3306/radixDB
```

> [!warning] Credenciales en Texto Plano
> Las credenciales están en texto plano en application-prod.yml. No hacer commit de secretos reales.

---

## Pasos de Despliegue en Dokploy

1. **Conectar repositorio Git**
   - Usar el repositorio de radix-api

2. **Seleccionar método de build**
   - Elegir "Dockerfile"

3. **Configurar directorio raíz**
   - Establecer como `/` o la raíz del proyecto

4. **Establecer variables de entorno**
   - Añadir todas las variables de la tabla anterior

5. **Deploy**
   - Ejecutar el pipeline

6. **Configurar dominio**
   - `api.raddix.pro` → puerto 8080 del contenedor

---

## Build Local

```bash
# Compilar sin tests
./mvnw clean package -DskipTests

# Construir imagen Docker
docker build -t radix-api:v2 .

# Run contenedor
docker run -p 8080:8080 \
  -e DB_HOST=localhost \
  -e DB_PORT=3306 \
  -e DB_NAME=radixDB \
  -e DB_USER=root \
  -e DB_PASSWORD=test \
  radix-api:v2
```

---

## Verificación post-deploy

```bash
# Health check
curl https://api.raddix.pro/v1/actuator/health
# Expected: {"status":"UP"}

# Info del API
curl https://api.raddix.pro/v1/
# Expected: JSON con name, version, status

# Endpoint de docs
curl https://api.raddix.pro/v1/docs
# Expected: Documentación del API
```

---

## Arquitectura de Configuración

```mermaid
graph LR
    A[Local - H2] -->|dev profile| B[memory db]
    C[Prod - MySQL] -->|prod profile| D[132.145.194.97]
```

### Configuración por Profile

**application.yml (default/dev)**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:radixdb
    driver-class-name: org.h2.Driver
    username: sa
    password:
  jpa:
    hibernate:
      ddl-auto: update
```

**application-prod.yml**
```yaml
spring:
  datasource:
    url: jdbc:mysql://${DB_HOST:132.145.194.97}:${DB_PORT:3306}/${DB_NAME:radixDB}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: ${DB_USER:root}
    password: ${DB_PASSWORD:Diegoelmejor1.0}
  jpa:
    database-platform: org.hibernate.dialect.MySQLDialect
    hibernate:
      ddl-auto: update
```

---

## Troubleshooting

### API no responde

1. Verificar que el contenedor esté corriendo
2. Revisar logs: `docker logs <container>`
3. Verificar health endpoint localmente

### Errores de Conexión a DB

1. Verificar que MySQL esté accesible
2. Comprobar credenciales en variables de entorno
3. Revisar `application-prod.yml` para valores por defecto

### Timeout en Health Check

> [!note]
> El HEALTHCHECK tiene `start-period=60s`. La primera verificación puede fallar si la app tarda en iniciar. Esperar 60s antes de asumir que hay un problema.

## Ver También

- [[Backend/API-Overview]] - Vista general del API
- [[Backend/Health]] - Endpoints de monitoring
- [[Backend/Database-Schema]] - Configuración de la base de datos