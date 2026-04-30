---
title: GET /api/patients
description: Listar todos los pacientes activos
method: GET
path: /api/patients
tags:
  - api
  - endpoint
  - patients
controller: PatientController
auth_required: false
status_code: 200
module: Backend
author: Documentation Bot
date: 2026-04-27
---

# GET /api/patients

Retorna lista de todos los pacientes con isActive=true.

## Response (200)

```json
[
  { "id": 1, "fullName": "Juan Pérez" },
  { "id": 2, "fullName": "Ana López" }
]
```

## Notas

- Solo pacientes activos
- Respuesta minimalista (id, fullName)

## Controller

`PatientController.java:74`

## Ver

[[Backend/Patients]]