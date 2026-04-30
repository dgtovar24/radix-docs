---
title: POST /api/auth/register/doctor
description: Registro de nuevo doctor - solo ADMIN
method: POST
path: /api/auth/register/doctor
tags:
  - api
  - endpoint
  - auth
  - admin
controller: AuthController
auth_required: true
auth_role: ADMIN
status_code: 200
module: Backend
author: Documentation Bot
date: 2026-04-27
---

# POST /api/auth/register/doctor

Registra un nuevo usuario doctor. Solo accesible para ADMIN.

## Headers

```
Authorization: Bearer <ADMIN_TOKEN>
```

## Request

```json
{
  "firstName": "María",
  "lastName": "García",
  "email": "maria@hospital.com",
  "password": "secure123"
}
```

## Response (200)

```json
{
  "message": "Doctor user created successfully",
  "id": 2
}
```

## Errores

- 400: Campos requeridos faltantes o email existe
- 403: No es ADMIN

## Controller

`AuthController.java:63`

## Ver

[[Backend/Auth]]