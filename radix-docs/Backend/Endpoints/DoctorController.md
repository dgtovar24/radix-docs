# DoctorController

> **Package:** `com.project.radix.Controller.DoctorController`
> **Ruta base:** `/api/doctors`
> **Endpoints:** 3

---

## Endpoints

### `GET /api/doctors`

Lista todos los facultativos con sus datos profesionales completos: número de colegiado, especialidad médica, teléfono de contacto.

**Respuesta `200`:**
```json
[
  {
    "id": 2,
    "firstName": "Elena",
    "lastName": "Ruiz",
    "email": "elena.ruiz@radix.pro",
    "phone": "600111001",
    "role": "Doctor",
    "licenseNumber": "282864321",
    "specialty": "Medicina Nuclear",
    "createdAt": "2026-04-30T21:25:01"
  }
]
```

**Campos relevantes:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `licenseNumber` | String | Número de colegiado médico |
| `specialty` | String | Especialidad (Medicina Nuclear, Oncología Radioterápica, etc.) |
| `phone` | String | Teléfono de contacto |

---

### `GET /api/doctors/{id}`

Obtiene el perfil detallado de un doctor por su ID.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del doctor |

**Respuesta `200`:** Objeto `Doctor` con los mismos campos que el listado.

**Respuesta `404`:**
```json
{ "error": "Doctor not found" }
```

---

### `PUT /api/doctors/{id}`

Actualiza los datos profesionales de un facultativo. Solo se actualizan los campos enviados en el body; el resto se mantiene.

**Cuerpo de la petición:**
```json
{
  "phone": "+34 600 999 888",
  "licenseNumber": "282868888",
  "specialty": "Oncología Radioterápica"
}
```

**Respuesta `200`:** Objeto `Doctor` actualizado.

---

## Notas de implementación

- Usa `UserRepository` para acceder a la tabla `users`, filtrando por `role = 'Doctor'`.
- El modelo `User` se extendió con los campos `licenseNumber` y `specialty` para dar soporte a este controlador.
- Los endpoints `PUT` y `GET /{id}` validan que el usuario exista y tenga rol `Doctor`.
- Sin autenticación requerida para lectura (`GET`).
