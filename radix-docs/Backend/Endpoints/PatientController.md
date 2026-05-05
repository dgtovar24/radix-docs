# PatientController

> **Package:** `com.project.radix.Controller.PatientController`
> **Ruta base:** `/api/patients`
> **Endpoints:** 6

---

## Descripción general

Gestiona el ciclo de vida completo de los pacientes: registro, consulta, actualización y desactivación. Cada paciente está vinculado a un `User` (rol `patient`) mediante `fkUserId` y opcionalmente a un doctor mediante `fkDoctorId`. Los listados solo retornan pacientes activos (`isActive = true`). La respuesta usa el DTO `PatientResponse` con todos los campos del paciente.

---

## Endpoints

### `GET /api/patients`

Lista todos los pacientes activos del sistema.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "fullName": "Ana García",
    "phone": "600222002",
    "address": "Calle Mayor 12, Madrid",
    "isActive": true,
    "familyAccessCode": "FAM-A1B2C3D4",
    "fkUserId": 5,
    "fkDoctorId": 2,
    "createdAt": "2026-04-30T21:25:01"
  },
  {
    "id": 2,
    "fullName": "Carlos López",
    "phone": null,
    "address": null,
    "isActive": true,
    "familyAccessCode": "FAM-E5F6G7H8",
    "fkUserId": 6,
    "fkDoctorId": 2,
    "createdAt": "2026-05-01T10:15:00"
  }
]
```

---

### `GET /api/patients/{id}`

Obtiene un paciente por su ID. Solo retorna pacientes activos.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del paciente |

**Respuesta `200`:** Objeto `PatientResponse` con los mismos campos que el listado.

**Respuesta `404`:**
```json
{ "error": "Not found" }
```

---

### `GET /api/patients/profile/{userId}`

Obtiene el perfil del paciente buscando por el ID del `User` vinculado. Ignora el filtro `isActive` — usa `findByFkUserId` directamente.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `userId` | Integer | ID del `User` vinculado al paciente |

**Respuesta `200`:** Objeto `PatientResponse`.

**Respuesta `404`:**
```json
{ "error": "Patient not found" }
```

---

### `POST /api/patients/register`

Registra un nuevo paciente creando simultáneamente el `User` y el registro `Patient`. No requiere autenticación (a diferencia de `POST /api/auth/register/patient` que sí requiere token de doctor). Genera automáticamente `familyAccessCode` con formato `FAM-XXXXXXXX`.

**Cuerpo de la petición:**
```json
{
  "firstName": "Ana",
  "lastName": "García",
  "email": "ana.garcia@example.com",
  "password": "paciente123",
  "phone": "600222002",
  "address": "Calle Mayor 12, Madrid",
  "doctorId": "2"
}
```

**Validaciones:**
| Campo | Regla |
|-------|-------|
| `firstName` | Obligatorio |
| `lastName` | Obligatorio |
| `email` | Obligatorio, único |
| `password` | Obligatorio (texto plano — sin hash en este endpoint) |
| `phone` | Opcional |
| `address` | Opcional |
| `doctorId` | Opcional — asigna el doctor que atenderá al paciente |

**Respuesta `200`:**
```json
{
  "message": "Patient created successfully",
  "userId": 12
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `Email already exists` |

---

### `PUT /api/patients/{id}`

Actualiza los datos de un paciente. Solo se modifican los campos enviados en el body; el resto se mantiene.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del paciente |

**Cuerpo de la petición:**
```json
{
  "phone": "600333003",
  "address": "Av. Diagonal 456, Barcelona",
  "familyAccessCode": "FAM-X9Y8Z7W6",
  "isActive": "true"
}
```

**Campos actualizables:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `phone` | String | Teléfono de contacto |
| `address` | String | Dirección del paciente |
| `familyAccessCode` | String | Código de acceso familiar |
| `isActive` | String | Estado — se parsea con `Boolean.parseBoolean` |

**Respuesta `200`:** Objeto `PatientResponse` con los datos actualizados.

**Respuesta `404`:**
```json
{ "error": "Patient not found" }
```

---

### `DELETE /api/patients/{id}`

Desactiva un paciente (`isActive = false`). No se elimina el registro de la base de datos; se conserva para auditoría y trazabilidad histórica.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del paciente |

**Respuesta `200`:**
```json
{ "message": "Patient deactivated" }
```

**Respuesta `404`:**
```json
{ "error": "Patient not found" }
```

---

## Notas de implementación

- Usa `PatientRepository` con consultas: `findByIsActiveTrue`, `findByFkUserId`, `findByFkDoctorId`, `findByFamilyAccessCode`.
- El DTO `PatientResponse` (via `toResponse()`) expone todos los campos: `id`, `fullName`, `phone`, `address`, `isActive`, `familyAccessCode`, `fkUserId`, `fkDoctorId`, `createdAt`.
- `GET /` y `GET /{id}` filtran por `isActive = true`. `GET /profile/{userId}` no aplica este filtro.
- `POST /register` no hashea la contraseña (texto plano). Para registro con hash y autorización, usar `POST /api/auth/register/patient`.
- `familyAccessCode` se genera como `"FAM-" + UUID.randomUUID().substring(0, 8).toUpperCase()`.
- `DELETE` es un borrado lógico: establece `isActive = false` sin eliminar el registro.
- Sin autenticación requerida en ningún endpoint de este controlador. Usar `AuthController` para operaciones con control de acceso.
