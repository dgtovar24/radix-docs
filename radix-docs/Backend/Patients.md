---
title: Patients Endpoints
description: Documentación completa de endpoints de pacientes - listado, registro y consulta
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - api
  - patients
module: Backend
status: active
---

# Patients Endpoints

## Base Path: `/api/patients`

---

## GET /api/patients

Retorna todos los pacientes activos del sistema.

### Response (200 OK)

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

### Notas

- Solo retorna pacientes con `isActive = true`
- Respuesta minimalista (solo id y fullName)
- Para información completa, consultar directamente la entidad Patient

---

## GET /api/patients/{id}

Retorna un paciente específico por su ID.

### Path Parameters

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| id | Integer | ID del paciente |

### Response (200 OK)

```json
{
  "id": 1,
  "fullName": "Juan Pérez"
}
```

### Response (404 Not Found)

```json
{
  "error": "Not found"
}
```

### Condiciones

- Paciente debe existir
- Paciente debe tener `isActive = true`

---

## GET /api/patients/profile/{userId}

Retorna el perfil de un paciente buscando por el ID del usuario asociado.

### Path Parameters

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| userId | Integer | ID del User vinculado |

### Response (200 OK)

```json
{
  "id": 1,
  "fullName": "Juan Pérez"
}
```

### Response (404 Not Found)

```json
{
  "error": "Patient not found"
}
```

---

## POST /api/patients/register

Registra un nuevo paciente en el sistema. Crea tanto el usuario como el registro de paciente.

### Request

```json
{
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "password": "string",
  "doctorId": "integer (opcional)"
}
```

### Campos Requeridos

- firstName
- lastName
- email
- password

### Campos Opcionales

- doctorId - ID del doctor que atenderá al paciente

### Response (200 OK)

```json
{
  "message": "Patient created successfully",
  "userId": 123
}
```

### Response (400 Bad Request)

```json
{
  "error": "Email already exists"
}
```

### Lógica de Registro

1. Verifica que el email no exista en la tabla users
2. Crea nuevo `User` con rol "patient"
3. Crea nuevo `Patient` vinculado al user
4. Genera código de acceso familiar: `FAM-XXXXXXXX` (8 caracteres)
5. Si se provee `doctorId`, asigna el doctor

### Código de Acceso Familiar

Cada paciente recibe un código único para que familiares puedan acceder a su información:

```
FAM-A1B2C3D4
```

## Repository

```java
public interface PatientRepository extends JpaRepository<Patient, Integer> {
    List<Patient> findByIsActiveTrue();
    Optional<Patient> findByFkUserId(Integer fkUserId);
    Optional<Patient> findByFkDoctorId(Integer fkDoctorId);
    Optional<Patient> findByFamilyAccessCode(String familyAccessCode);
}
```

## Ver También

- [[Backend/Auth]] - Registro vía AuthController (con autorización)
- [[Backend/Entities-Overview]] - Entidad Patient completa
- [[Backend/Database-Schema]] - Esquema de la tabla patients