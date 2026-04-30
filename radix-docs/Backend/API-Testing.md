---
title: API Testing Guide
description: Guía para probar todos los endpoints del API de Radix con curl y Postman
author: Documentation Bot
date: 2026-04-27
tags:
  - development
  - testing
  - api
  - curl
  - postman
module: Backend
status: active
---

# API Testing Guide

## Endpoints Disponibles

Base URL: `http://localhost:8080/v2`

---

## Autenticación

### POST /api/auth/login

Login de usuario.

**curl**

```bash
curl -X POST http://localhost:8080/v2/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "Radix", "password": "radixelmejor1"}'
```

**Request**

```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200)**

```json
{
  "token": "admin-hardcoded-token",
  "id": 0,
  "firstName": "Radix",
  "role": "ADMIN"
}
```

**Admin Hardcoded**

> [!tip]
> Email: `Radix`
> Password: `radixelmejor1`

---

### POST /api/auth/register/doctor

Registrar nuevo doctor. Solo ADMIN.

**curl**

```bash
curl -X POST http://localhost:8080/v2/api/auth/register/doctor \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer admin-hardcoded-token" \
  -d '{
    "firstName": "María",
    "lastName": "García",
    "email": "maria@hospital.com",
    "password": "secure123"
  }'
```

**Request**

```json
{
  "firstName": "string (required)",
  "lastName": "string (required)",
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response (200)**

```json
{
  "message": "Doctor user created successfully",
  "id": 2
}
```

---

### POST /api/auth/register/patient

Registrar nuevo paciente. Solo DOCTOR.

**curl**

```bash
curl -X POST http://localhost:8080/v2/api/auth/register/patient \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 2" \
  -d '{
    "firstName": "Juan",
    "lastName": "Pérez",
    "email": "juan@email.com",
    "password": "password123",
    "phone": "+34912345678",
    "address": "Calle Mayor 123"
  }'
```

**Request**

```json
{
  "firstName": "string (required)",
  "lastName": "string (required)",
  "email": "string (required)",
  "password": "string (required)",
  "phone": "string (optional)",
  "address": "string (optional)"
}
```

**Response (200)**

```json
{
  "message": "Patient registered successfully",
  "id": 3
}
```

---

## Usuarios

### GET /api/users

Lista todos los usuarios.

**curl**

```bash
curl http://localhost:8080/v2/api/users
```

**Response (200)**

```json
[
  {
    "id": 0,
    "firstName": "Radix",
    "lastName": "Admin",
    "email": "Radix",
    "role": "ADMIN",
    "createdAt": "2026-04-27T10:00:00"
  },
  {
    "id": 2,
    "firstName": "María",
    "lastName": "García",
    "email": "maria@hospital.com",
    "role": "DOCTOR",
    "createdAt": "2026-04-27T11:30:00"
  }
]
```

---

### GET /api/users/role/{role}

Lista usuarios filtrados por rol.

**curl**

```bash
curl http://localhost:8080/v2/api/users/role/DOCTOR
```

**Parámetros**

| Parámetro | Valor |
|-----------|-------|
| role | ADMIN, DOCTOR, PATIENT |

**Response (200)**

```json
[
  {
    "id": 2,
    "firstName": "María",
    "lastName": "García",
    "email": "maria@hospital.com",
    "role": "DOCTOR",
    "createdAt": "2026-04-27T11:30:00"
  }
]
```

---

## Pacientes

### GET /api/patients

Lista todos los pacientes activos.

**curl**

```bash
curl http://localhost:8080/v2/api/patients
```

**Response (200)**

```json
[
  {
    "id": 1,
    "fullName": "Juan Pérez"
  },
  {
    "id": 2,
    "fullName": "Ana López"
  }
]
```

---

### GET /api/patients/{id}

Obtiene un paciente específico por ID.

**curl**

```bash
curl http://localhost:8080/v2/api/patients/1
```

**Response (200)**

```json
{
  "id": 1,
  "fullName": "Juan Pérez"
}
```

**Response (404)**

```json
{
  "error": "Not found"
}
```

---

### GET /api/patients/profile/{userId}

Obtiene el perfil de un paciente por ID de usuario.

**curl**

```bash
curl http://localhost:8080/v2/api/patients/profile/3
```

**Response (200)**

```json
{
  "id": 1,
  "fullName": "Juan Pérez"
}
```

---

### POST /api/patients/register

Registra un nuevo paciente (alternativo).

**curl**

```bash
curl -X POST http://localhost:8080/v2/api/patients/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Pedro",
    "lastName": "Sánchez",
    "email": "pedro@email.com",
    "password": "password456"
  }'
```

**Request**

```json
{
  "firstName": "string (required)",
  "lastName": "string (required)",
  "email": "string (required)",
  "password": "string (required)",
  "doctorId": "integer (optional)"
}
```

**Response (200)**

```json
{
  "message": "Patient created successfully",
  "userId": 4
}
```

---

## Sistema

### GET /

Información del API.

**curl**

```bash
curl http://localhost:8080/v2/
```

**Response (200)**

```json
{
  "name": "Radix API",
  "version": "v1",
  "description": "REST API for Radix medical management system",
  "status": "operational",
  "timestamp": "2026-04-27T12:00:00Z",
  "endpoints": [...]
}
```

---

### GET /actuator/health

Health check de Spring Boot Actuator.

**curl**

```bash
curl http://localhost:8080/v2/actuator/health
```

**Response (200)**

```json
{
  "status": "UP"
}
```

---

### GET /docs

Documentación del esquema del API.

**curl**

```bash
curl http://localhost:8080/v2/docs
```

**Response (200)**

```json
{
  "api": "Radix API v1",
  "description": "Complete API Schema...",
  "endpoints": [...]
}
```

---

## Postman Collection

Para importar en Postman:

1. Crear nueva colección "Radix API"
2. Agregar request para cada endpoint
3. Configurar variables de entorno:

| Variable | Valor |
|----------|-------|
| `baseUrl` | http://localhost:8080/v2 |
| `token` | admin-hardcoded-token |

### Ejemplo Request Auth

```
POST {{baseUrl}}/api/auth/login
Content-Type: application/json

{
  "email": "Radix",
  "password": "radixelmejor1"
}
```

---

## Testing Workflow

### 1. Login como Admin

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/v2/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "Radix", "password": "radixelmejor1"}' \
  | jq -r '.token')
echo "Token: $TOKEN"
```

### 2. Registrar un Doctor

```bash
curl -X POST http://localhost:8080/v2/api/auth/register/doctor \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "firstName": "Dr. Test",
    "lastName": "Doctor",
    "email": "doctor@test.com",
    "password": "test123"
  }'
```

### 3. Login como Doctor

```bash
DOCTOR_TOKEN=$(curl -s -X POST http://localhost:8080/v2/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "doctor@test.com", "password": "test123"}' \
  | jq -r '.token')
echo "Doctor Token: $DOCTOR_TOKEN"
```

### 4. Registrar un Paciente

```bash
curl -X POST http://localhost:8080/v2/api/auth/register/patient \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DOCTOR_TOKEN" \
  -d '{
    "firstName": "Paciente",
    "lastName": "Test",
    "email": "paciente@test.com",
    "password": "test456"
  }'
```

### 5. Listar Pacientes

```bash
curl http://localhost:8080/v2/api/patients
```

---

## Códigos de Error

| Código | Significado |
|--------|-------------|
| 400 | Bad Request - Campos requeridos faltantes |
| 401 | Unauthorized - Credenciales inválidas |
| 403 | Forbidden - Permisos insuficientes |
| 404 | Not Found - Recurso no existe |
| 500 | Internal Server Error - Error del servidor |

---

## Ver También

- [[Backend/Auth]] - Documentación de autenticación
- [[Backend/Patients]] - Endpoints de pacientes
- [[Backend/Users]] - Endpoints de usuarios
- [[Development-Setup]] - Setup de desarrollo