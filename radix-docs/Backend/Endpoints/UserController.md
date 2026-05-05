# UserController

> **Package:** `com.project.radix.Controller.UserController`
> **Ruta base:** `/api/users`
> **Endpoints:** 5

---

## Descripción general

CRUD completo de usuarios del sistema. Los usuarios pueden tener roles `Doctor`, `ADMIN`, o `patient`. La entidad `User` incluye campos profesionales (`licenseNumber`, `specialty`) y de contacto (`phone`). Sin autenticación requerida en los endpoints de lectura; `PUT` y `DELETE` no tienen control de acceso actualmente.

---

## Endpoints

### `GET /api/users`

Lista todos los usuarios registrados en el sistema, independientemente de su rol o estado.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "firstName": "Diego",
    "lastName": "Tovar",
    "email": "diego@example.com",
    "password": "$2a$10$…",
    "role": "ADMIN",
    "phone": null,
    "licenseNumber": null,
    "specialty": null,
    "createdAt": "2026-04-27T10:00:00"
  },
  {
    "id": 2,
    "firstName": "Elena",
    "lastName": "Ruiz",
    "email": "elena.ruiz@radix.pro",
    "password": "$2a$10$…",
    "role": "Doctor",
    "phone": "600111001",
    "licenseNumber": "282864321",
    "specialty": "Medicina Nuclear",
    "createdAt": "2026-04-30T21:25:01"
  }
]
```

---

### `GET /api/users/role/{role}`

Filtra usuarios por rol específico.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `role` | String | Rol a filtrar (`Doctor`, `ADMIN`, `patient`) |

**Respuesta `200`:** Array de objetos `User` con los mismos campos que `GET /api/users`.

**Roles disponibles:**
| Rol | Descripción |
|-----|-------------|
| `ADMIN` | Administrador del sistema |
| `Doctor` | Facultativo clínico |
| `patient` | Paciente |

---

### `GET /api/users/{id}`

Obtiene un usuario por su ID.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del usuario |

**Respuesta `200`:** Objeto `User` completo incluyendo `password` (hash BCrypt).

**Respuesta `404`:**
```json
{ "error": "User not found" }
```

---

### `PUT /api/users/{id}`

Actualiza los datos de un usuario. Solo se modifican los campos enviados en el body; el resto se mantiene. Permite actualizar la contraseña en texto plano (no se aplica hash en este endpoint).

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del usuario |

**Cuerpo de la petición:**
```json
{
  "firstName": "Elena",
  "lastName": "Ruiz Gómez",
  "email": "elena.ruiz@radix.pro",
  "phone": "600999888",
  "licenseNumber": "282868888",
  "specialty": "Oncología Radioterápica",
  "role": "Doctor",
  "password": "nuevaClave123"
}
```

**Campos actualizables:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `firstName` | String | Nombre |
| `lastName` | String | Apellido |
| `email` | String | Email (no se valida unicidad) |
| `phone` | String | Teléfono |
| `licenseNumber` | String | Número de colegiado |
| `specialty` | String | Especialidad médica |
| `role` | String | Rol del usuario |
| `password` | String | Contraseña (se guarda en texto plano sin hash) |

**Respuesta `200`:** Objeto `User` completo con los datos actualizados.

**Respuesta `404`:**
```json
{ "error": "User not found" }
```

---

### `DELETE /api/users/{id}`

Elimina permanentemente un usuario de la base de datos. No es un borrado lógico — el registro se destruye.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del usuario |

**Respuesta `200`:**
```json
{ "message": "User deleted" }
```

**Respuesta `404`:**
```json
{ "error": "User not found" }
```

---

## Notas de implementación

- Usa `UserRepository` con consultas: `findAll`, `findById`, `findByRole`, `findByEmail`, `existsByEmail`, `deleteById`.
- El modelo `User` incluye los campos `phone`, `licenseNumber` y `specialty` desde la v2 del API.
- `DELETE` es un borrado físico (`deleteById`). No hay borrado lógico en este controlador.
- `PUT` guarda la contraseña tal cual se recibe (sin hash). Para actualizar contraseñas con BCrypt, usar el flujo de registro en `AuthController`.
- Sin autenticación requerida. Los campos `licenseNumber` y `specialty` también son usados por `DoctorController`.
- El campo `password` se incluye en todas las respuestas GET. En producción debería excluirse con `@JsonIgnore`.
