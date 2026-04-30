---
title: Users Endpoint
description: Documentación del endpoint GET /api/users - Listar y filtrar usuarios del sistema
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - api
  - users
module: Backend
status: active
---

# Users Endpoint

This page documents the current users API and the frontend model that now
combines users and facultativos in a single administration surface.

## Base Path: `/api/users`

---

## GET /api/users

Retorna todos los usuarios registrados en el sistema.

### Response (200 OK)

```json
[
  {
    "id": 1,
    "firstName": "Diego",
    "lastName": "Tovar",
    "email": "diego@example.com",
    "role": "ADMIN",
    "createdAt": "2026-04-27T10:00:00"
  },
  {
    "id": 2,
    "firstName": "María",
    "lastName": "García",
    "email": "maria@example.com",
    "role": "FACULTATIVO",
    "createdAt": "2026-04-27T11:30:00"
  }
]
```

### Campos de User

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | Integer | Identificador único |
| firstName | String | Nombre del usuario |
| lastName | String | Apellido |
| email | String | Email único |
| role | String | Rol: DESARROLLADOR, ADMIN, FACULTATIVO |
| createdAt | DateTime | Fecha de creación |

> [!note] Pending backend fields
> The frontend currently mocks `department`, `assignedPatients`,
> `activeTreatments`, and `resolvedAlerts` until department and facultativo
> metric endpoints are implemented.

---

## GET /api/users/role/{role}

Retorna usuarios filtrados por rol específico.

### Path Parameters

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| role | String | Rol a filtrar (DESARROLLADOR, ADMIN, FACULTATIVO) |

### Response (200 OK)

```json
[
  {
    "id": 2,
    "firstName": "María",
    "lastName": "García",
    "email": "maria@example.com",
    "role": "FACULTATIVO",
    "createdAt": "2026-04-27T11:30:00"
  }
]
```

### Roles Disponibles

- `DESARROLLADOR` - Acceso técnico y soporte de plataforma
- `ADMIN` - Administradores del sistema; también son facultativos clínicos
- `FACULTATIVO` - Usuarios clínicos que atienden pacientes

## Missing server-side filters

The frontend can filter locally today. The backend still needs this endpoint to
replace mock and client-side filtering:

```http
GET /api/users?role=&departmentId=&q=
```

## Repository

```java
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRole(String role);
}
```

## Ver También

- [[Backend/Auth]] - Autenticación y roles
- [[Backend/Patients]] - Pacientes vinculados a usuarios
