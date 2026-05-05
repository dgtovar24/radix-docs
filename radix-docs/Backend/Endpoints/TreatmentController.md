# TreatmentController

> **Package:** `com.project.radix.Controller.TreatmentController`
> **Ruta base:** `/api/treatments`
> **Endpoints:** 6

---

## Descripción general

Gestiona los tratamientos de medicina nuclear. Cada tratamiento asocia un paciente, un radioisótopo, y opcionalmente un smartwatch. Al crear un tratamiento, el sistema calcula automáticamente los días de aislamiento y el umbral de seguridad usando la vida media del isótopo. Los endpoints de creación y finalización requieren autenticación JWT con rol `Doctor`.

**Cálculo automático de confinamiento:**
| Variable | Fórmula | Descripción |
|----------|---------|-------------|
| `isolationDays` | `ceil(half_life × 10)` | Días de aislamiento seguro |
| `safetyThreshold` | `initial_dose × 0.1` | Umbral de radiación que dispara alertas (10% de la dosis inicial) |

---

## Endpoints

### `GET /api/treatments`

Lista todos los tratamientos del sistema, activos e inactivos.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "patientName": "Ana García",
    "patientId": 1,
    "doctorName": "Dr. Juan Pérez",
    "doctorId": 2,
    "isotopeName": "Iodo-131",
    "isotopeId": 1,
    "room": 101,
    "initialDose": 150.5,
    "safetyThreshold": 15.05,
    "isolationDays": 80,
    "startDate": "2026-04-28T10:00:00",
    "endDate": null,
    "isActive": true,
    "currentRadiation": null
  }
]
```

---

### `GET /api/treatments/active`

Lista solo los tratamientos activos (`isActive = true`). Usado por el dashboard para mostrar tratamientos en curso.

**Respuesta `200`:** Mismo formato que `GET /api/treatments`, filtrado por `isActive = true`.

---

### `GET /api/treatments/{id}`

Obtiene el detalle completo de un tratamiento por su ID.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del tratamiento |

**Respuesta `200`:** Objeto `TreatmentResponse` completo.

**Respuesta `404`:** Sin body (`.notFound().build()`).

---

### `GET /api/treatments/patient/{patientId}`

Lista todos los tratamientos de un paciente específico.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `patientId` | Integer | ID del paciente |

**Respuesta `200`:** Array de `TreatmentResponse` filtrado por paciente.

---

### `POST /api/treatments`

Crea un nuevo tratamiento con cálculo automático de confinamiento. Requiere autenticación de doctor. El `doctorId` se extrae del token JWT.

**Headers:**
```
Authorization: Bearer <JWT_DOCTOR>
```

**Cuerpo de la petición:**
```json
{
  "fkPatientId": 1,
  "fkRadioisotopeId": 1,
  "fkSmartwatchId": 3,
  "room": 101,
  "initialDose": 150.5
}
```

**Validaciones (`@Valid` + Jakarta):**
| Campo | Regla |
|-------|-------|
| `fkPatientId` | `@NotNull` — Obligatorio |
| `fkRadioisotopeId` | `@NotNull` — Obligatorio |
| `fkSmartwatchId` | Opcional |
| `room` | `@NotNull` — Obligatorio |
| `initialDose` | `@NotNull` — Obligatorio |

**Respuesta `200`:**
```json
{
  "id": 1,
  "patientName": "Ana García",
  "patientId": 1,
  "doctorName": "Dr. Juan Pérez",
  "doctorId": 2,
  "isotopeName": "Iodo-131",
  "isotopeId": 1,
  "room": 101,
  "initialDose": 150.5,
  "safetyThreshold": 15.05,
  "isolationDays": 80,
  "startDate": "2026-04-28T10:00:00",
  "endDate": null,
  "isActive": true,
  "currentRadiation": null
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 401 | `Invalid authorization` — Token ausente, inválido o expirado |
| 500 | `Isotope not found` — El `fkRadioisotopeId` no existe |

---

### `POST /api/treatments/{id}/end`

Finaliza un tratamiento. Establece `endDate` a la fecha/hora actual y `isActive = false`.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del tratamiento |

**Respuesta `200`:** Objeto `TreatmentResponse` con `endDate` establecido y `isActive = false`.

**Respuesta `404`:** Sin body (`.notFound().build()`).

---

## Notas de implementación

- Delega toda la lógica de negocio en `TreatmentService` (`getAllTreatments`, `getActiveTreatments`, `getTreatmentById`, `getTreatmentsByPatient`, `createTreatment`, `endTreatment`).
- El `doctorId` se resuelve del JWT mediante `jwtUtil.getUserId(token)`. Si el token es inválido, devuelve 401.
- `TreatmentCreateRequest` usa validación Jakarta (`@NotNull`) con mensajes descriptivos.
- `TreatmentResponse` incluye `currentRadiation` (Double) que se actualiza con cada ingesta de datos del smartwatch.
- El cálculo de confinamiento usa `ConfinementCalculationService`: busca el isótopo por ID en `IsotopeCatalog`, toma su `halfLife`, y aplica las fórmulas `ceil(halfLife * 10)` y `initialDose * 0.1`.
- `endTreatment` busca el tratamiento activo en `TreatmentRepository`, establece `endDate = LocalDateTime.now()` y `isActive = false`.
