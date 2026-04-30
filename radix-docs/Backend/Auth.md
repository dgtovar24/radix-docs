---
title: Auth Endpoints
description: Documentación completa de endpoints de autenticación - login, registro de doctores y pacientes
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - api
  - authentication
  - security
module: Backend
status: active
---

# Auth Endpoints

## Base Path: `/api/auth`

Todos los endpoints requieren CORS habilitado para todos los orígenes (`@CrossOrigin(origins = "*")`).

---

## POST /api/auth/login

Inicia sesión en el sistema y devuelve un token de sesión mock.

### Request

```json
{
  "email": "string",
  "password": "string"
}
```

### Response (200 OK)

```json
{
  "token": "admin-hardcoded-token",
  "id": 0,
  "firstName": "Radix",
  "role": "ADMIN"
}
```

### Response (400 Bad Request)

```json
{
  "error": "Email and password are required"
}
```

### Response (401 Unauthorized)

```json
{
  "error": "Invalid credentials"
}
```

### Lógica de Autenticación

1. **Admin Hardcoded**: Si email es `Radix` y password es `radixelmejor1`, devuelve token especial `admin-hardcoded-token` con ID 0
2. **Base de datos**: Busca usuario por email, verifica password en texto plano
3. **Token mock**: El token es simplemente el ID del usuario (arquitectura simplificada)

> [!warning] Security Issue
> Las contraseñas se almacenan en **texto plano**. No usar en producción sin implementar hashing bcrypt/SCrypt.

---

## POST /api/auth/register/doctor

Registra un nuevo usuario doctor. Solo el ADMIN puede ejecutar esta acción.

### Headers

```
Authorization: Bearer <ADMIN_TOKEN>
```

### Request

```json
{
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "password": "string"
}
```

### Response (200 OK)

```json
{
  "message": "Doctor user created successfully",
  "id": 123
}
```

### Response (400 Bad Request)

```json
{
  "error": "Fields firstName, lastName, email, and password are required"
}
```

```json
{
  "error": "Email already exists"
}
```

### Response (403 Forbidden)

```json
{
  "error": "Only Admin can create Doctors"
}
```

---

## POST /api/auth/register/patient

Registra un nuevo paciente. Solo doctores pueden ejecutar esta acción.

### Headers

```
Authorization: Bearer <DOCTOR_ID>
```

### Request

```json
{
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "password": "string",
  "phone": "string (opcional)",
  "address": "string (opcional)"
}
```

### Response (200 OK)

```json
{
  "message": "Patient registered successfully",
  "id": 456
}
```

### Lógica de Registro

1. Crea `User` con rol `PATIENT`
2. Crea `Patient` vinculado al usuario recién creado
3. Genera `familyAccessCode` único (UUID aleatorio)
4. Asigna automáticamente el doctor que registra (del token)

### Response (403 Forbidden)

```json
{
  "error": "Only a Doctor can register Patients"
}
```

---

## Validación de Tokens

El sistema valida tokens de la siguiente manera:

1. Extrae el token del header `Authorization: Bearer <TOKEN>`
2. Si es `admin-hardcoded-token`, devuelve usuario admin con ID 0
3. Intenta parsear como Integer (mock token = user ID)
4. Busca el usuario correspondiente en la base de datos

```java
private Optional<User> resolveTokenUser(String authHeader) {
    if (authHeader == null || !authHeader.startsWith("Bearer ")) return Optional.empty();

    String token = authHeader.substring(7).trim();

    if ("admin-hardcoded-token".equals(token)) {
        User admin = new User();
        admin.setId(0);
        admin.setRole("ADMIN");
        return Optional.of(admin);
    }

    try {
        return userRepository.findById(Integer.parseInt(token));
    } catch (NumberFormatException e) {
        return Optional.empty();
    }
}
```

## Estados de Error Comunes

| Código | Descripción |
|--------|-------------|
| 400 | Request body inválido o campos requeridos faltantes |
| 401 | Credenciales inválidas |
| 403 | Permisos insuficientes para la acción |
| 404 | Recurso no encontrado |
| 500 | Error interno del servidor |

## Notas de Implementación

- No hay JWT ni OAuth - el token es simplemente el ID del usuario
- Contraseñas en texto plano -安全隐患
- No hay rate limiting implementado
- No hay logout ( stateless)

## Ver También

- [[Backend/API-Overview]] - Vista general del API
- [[Backend/Users]] - Gestión de usuarios
- [[Backend/Patients]] - Gestión de pacientes