---
title: POST /api/auth/login
description: Endpoint de inicio de sesión - autenticación de usuarios
method: POST
path: /api/auth/login
tags:
  - api
  - endpoint
  - auth
controller: AuthController
auth_required: false
status_code: 200
module: Backend
author: Documentation Bot
date: 2026-04-27
---

# POST /api/auth/login

Inicia sesión y retorna token de sesión.

## Request



## Response (200)



## Notas

- Admin hardcoded: email , password 
- Usuarios DB: token = user ID
- Sin hashing de passwords

## Controller



## Ver

[[Backend/Auth]]