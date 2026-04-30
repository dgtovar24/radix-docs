---
title: API Documentation Endpoint
description: Documentación completa del esquema del API - parámetros, request bodies y respuestas
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - api
  - documentation
module: Backend
status: active
---

# API Documentation Endpoint

## GET /docs

Retorna documentación completa del esquema del API en formato JSON.

### Response (200 OK)

```json
{
  "api": "Radix API v1",
  "description": "Complete API Schema with expected POST bodies and GET responses",
  "endpoints": [
    {
      "path": "/api/auth/login",
      "method": "POST",
      "description": "Login user to get session ID/Token",
      "request_body": {
        "email": "string (required)",
        "password": "string (required)"
      },
      "response": {
        "token": "integer (ID as token)",
        "id": "integer",
        "firstName": "string",
        "role": "string"
      }
    },
    {
      "path": "/api/auth/register/doctor",
      "method": "POST",
      "description": "ADMIN ONLY: Register a new doctor",
      "headers": "Authorization: Bearer <ADMIN_ID>",
      "request_body": {
        "firstName": "string (required)",
        "lastName": "string (required)",
        "email": "string (required)",
        "password": "string (required)"
      },
      "response": {
        "message": "string",
        "id": "integer"
      }
    },
    {
      "path": "/api/auth/register/patient",
      "method": "POST",
      "description": "DOCTOR ONLY: Register a new patient",
      "headers": "Authorization: Bearer <DOCTOR_ID>",
      "request_body": {
        "firstName": "string (required)",
        "lastName": "string (required)",
        "email": "string (required)",
        "password": "string (required)",
        "phone": "string (optional)",
        "address": "string (optional)"
      },
      "response": {
        "message": "string",
        "id": "integer"
      }
    },
    {
      "path": "/api/patients",
      "method": "GET",
      "description": "Get all active patients",
      "response": [
        {
          "id": "integer",
          "fullName": "string"
        }
      ]
    },
    {
      "path": "/api/patients/{id}",
      "method": "GET",
      "description": "Get specific patient by internal ID",
      "response": {
        "id": "integer",
        "fullName": "string"
      }
    },
    {
      "path": "/api/patients/profile/{userId}",
      "method": "GET",
      "description": "Get specific patient by their User ID",
      "response": {
        "id": "integer",
        "fullName": "string"
      }
    },
    {
      "path": "/api/patients/register",
      "method": "POST",
      "description": "Legacy/alternative patient registration",
      "request_body": {
        "firstName": "string (required)",
        "lastName": "string (required)",
        "email": "string (required)",
        "password": "string (required)",
        "doctorId": "string (optional)"
      },
      "response": {
        "message": "string",
        "userId": "integer"
      }
    }
  ]
}
```

## Uso

```bash
# Obtener documentación completa
curl https://api.raddix.pro/v1/docs
```

## Notas

- Esta documentación es auto-generada desde el `DocsController`
- Útil para consumidores del API que quieren descubrir endpoints
- No incluye endpoints de Spring Actuator

## Ver También

- [[Backend/API-Overview]] - Vista general del API
- [[Backend/Auth]] - Endpoints de autenticación
- [[Backend/Patients]] - Endpoints de pacientes