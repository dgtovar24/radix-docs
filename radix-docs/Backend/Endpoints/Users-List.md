---
title: GET /api/users
description: Listar todos los usuarios
method: GET
path: /api/users
tags:
  - api
  - endpoint
  - users
controller: UserController
auth_required: false
status_code: 200
module: Backend
author: Documentation Bot
date: 2026-04-27
---

# GET /api/users

Retorna todos los usuarios del sistema.

## Response (200)

```json
[
  {
    "id": 1,
    "firstName": "Diego",
    "lastName": "Tovar",
    "email": "diego@example.com",
    "role": "ADMIN",
    "createdAt": "2026-04-27T10:00:00"
  }
]
```

## Campos

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | Integer | ID único |
| firstName | String | Nombre |
| lastName | String | Apellido |
| email | String | Email único |
| role | String | ADMIN, DOCTOR, PATIENT |
| createdAt | DateTime | Fecha creación |

## Controller

`UserController.java:21`

## Ver

[[Backend/Users]]