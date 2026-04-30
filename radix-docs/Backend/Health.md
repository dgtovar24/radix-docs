---
title: Health & System Endpoints
description: Endpoints de salud del sistema - health check, info y estado del API
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - api
  - health
  - monitoring
module: Backend
status: active
---

# Health & System Endpoints

---

## GET /

Endpoint raíz que retorna información general del API y lista de endpoints disponibles.

### Response (200 OK)

```json
{
  "name": "Radix API",
  "version": "v1",
  "description": "REST API for Radix medical management system",
  "status": "operational",
  "timestamp": "2026-04-27T12:00:00Z",
  "docs": "https://api.aiflex.dev/v1/actuator",
  "endpoints": [
    {"method": "GET", "path": "/v1/", "description": "API info & status"},
    {"method": "POST", "path": "/v1/api/auth/login", "description": "User authentication"},
    {"method": "POST", "path": "/v1/api/auth/register", "description": "User registration"},
    {"method": "GET", "path": "/v1/api/pacientes", "description": "List all patients"},
    {"method": "GET", "path": "/v1/api/pacientes/{id}", "description": "Get patient by ID"},
    {"method": "GET", "path": "/v1/actuator/health", "description": "Service health check"},
    {"method": "GET", "path": "/v1/actuator/info", "description": "Build information"},
    {"method": "GET", "path": "/v1/actuator/metrics", "description": "Application metrics"}
  ]
}
```

### Uso

```bash
curl https://api.raddix.pro/v1/
```

---

## GET /actuator/health

Health check de Spring Boot Actuator. Útil para monitoreo y contenedores.

### Response (200 OK)

```json
{
  "status": "UP"
}
```

### Cuando la Aplicación Está Caída

El health check fallará con código de estado 5xx o timeout.

---

## GET /actuator/info

Información de la build.

### Response (200 OK)

```json
{
  "build": {
    "version": "2.0.0",
    "name": "radix"
  }
}
```

---

## GET /actuator/metrics

Métricas de la aplicación (JVM, HTTP, etc.).

### Response (200 OK)

```json
{
  "names": [
    "jvm.memory.used",
    "jvm.gc.pause",
    "http.server.requests",
    ...
  ]
}
```

### Métricas Específicas

```bash
# Memoria JVM
curl https://api.raddix.pro/v1/actuator/metrics/jvm.memory.used

# Requests HTTP
curl https://api.raddix.pro/v1/actuator/metrics/http.server.requests
```

---

## Monitoring en Producción

> [!tip] Configuración de Health Check
> El Dockerfile de producción tiene un HEALTHCHECK configurado:
> ```dockerfile
> HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
>   CMD wget -qO- http://localhost:8080/v1/ || exit 1
> ```

### Verificación Manual

```bash
# Health check
curl https://api.raddix.pro/v1/actuator/health

# Info de la build
curl https://api.raddix.pro/v1/actuator/info

# Verificar que el API está respondiendo
curl https://api.raddix.pro/v1/
```

## Ver También

- [[Backend/Deployment]] - Instrucciones de despliegue
- [[Backend/API-Overview]] - Vista general del API