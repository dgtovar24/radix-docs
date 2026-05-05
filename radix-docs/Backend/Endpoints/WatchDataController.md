# WatchDataController

> **Package:** `com.project.radix.Controller.WatchDataController`
> **Ruta base:** `/api/watch`
> **Endpoints:** 3

---

## Descripción general

Recibe y consulta los datos de telemetría enviados por los smartwatches de los pacientes. El endpoint de ingesta acepta autenticación opcional vía token OAuth (Bearer) o sin autenticación usando `familyAccessCode`. Cuando la radiación supera el umbral de seguridad del tratamiento activo, se genera automáticamente una alerta para el doctor.

**Flujo de ingesta:**
1. El smartwatch envía `POST /api/watch/ingest` con IMEI, `familyAccessCode` y métricas
2. El sistema valida el código de acceso familiar contra el paciente
3. Verifica que el IMEI esté registrado y vinculado a ese paciente
4. Guarda los datos en `health_metrics`
5. Si `currentRadiation > safetyThreshold` del tratamiento activo, crea una `DoctorAlert` y la transmite por WebSocket

---

## Endpoints

### `POST /api/watch/ingest`

Ingesta datos desde el smartwatch del paciente. La autenticación puede ser vía Bearer token (OAuth 2.0) o mediante `familyAccessCode` sin token. Si se envía un header `Authorization: Bearer <token>`, se valida contra `oauth_clients`.

**Cuerpo de la petición:**
```json
{
  "imei": "35928108492011",
  "familyAccessCode": "FAM-A1B2C3D4",
  "bpm": 72,
  "steps": 150,
  "distance": 0.5,
  "currentRadiation": 0.023,
  "recordedAt": "2026-04-28T10:30:00"
}
```

**Validaciones (`@Valid` + Jakarta):**
| Campo | Regla |
|-------|-------|
| `imei` | `@NotBlank` — Obligatorio |
| `familyAccessCode` | `@NotBlank` — Obligatorio |
| `bpm` | Opcional — Pulsaciones por minuto |
| `steps` | Opcional — Pasos dados |
| `distance` | Opcional — Distancia recorrida (km) |
| `currentRadiation` | `@NotNull` — Obligatorio. Nivel de radiación en mCi |
| `recordedAt` | Opcional — Timestamp de la medición (default: `now()`) |

**Respuesta `200`:**
```json
{ "status": "received" }
```

**Errores:**
| Código | Mensaje | Causa |
|--------|---------|-------|
| 400 | `Invalid family access code` | El código no coincide con ningún paciente |
| 400 | `Smartwatch not registered` | El IMEI no está en el sistema |
| 400 | `Smartwatch not linked to this patient` | El IMEI pertenece a otro paciente |
| 401 | `Invalid token` | Bearer token OAuth inválido o inactivo |

---

### `GET /api/watch/{imei}/metrics`

Obtiene el histórico completo de métricas para un smartwatch por su IMEI.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `imei` | String | IMEI del smartwatch |

**Respuesta `200`:**
```json
[
  {
    "id": 45,
    "patientId": 1,
    "patientName": "Ana García",
    "imei": "35928108492011",
    "bpm": 72,
    "steps": 150,
    "distance": 0.5,
    "currentRadiation": 0.023,
    "recordedAt": "2026-04-28T10:30:00"
  },
  {
    "id": 44,
    "patientId": 1,
    "patientName": "Ana García",
    "imei": "35928108492011",
    "bpm": 70,
    "steps": 120,
    "distance": 0.4,
    "currentRadiation": 0.022,
    "recordedAt": "2026-04-28T10:20:00"
  }
]
```

---

### `GET /api/watch/patient/{patientId}/latest`

Obtiene la última medición registrada para un paciente específico. Útil para dashboards y monitorización en tiempo real.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `patientId` | Integer | ID del paciente |

**Respuesta `200`:**
```json
{
  "id": 45,
  "patientId": 1,
  "patientName": "Ana García",
  "imei": "35928108492011",
  "bpm": 72,
  "steps": 150,
  "distance": 0.5,
  "currentRadiation": 0.023,
  "recordedAt": "2026-04-28T10:30:00"
}
```

**Respuesta `404`:** Sin body (`.notFound().build()`) — El paciente no tiene métricas registradas.

---

## Notas de implementación

- Delega la lógica en `WatchDataService` (`ingestData`, `getMetricsByImei`, `getLatestMetricsByPatient`).
- `ingestData` valida tres condiciones secuenciales:
  1. El `familyAccessCode` debe coincidir con un paciente existente.
  2. El `imei` debe estar registrado en la tabla `smartwatches`.
  3. El smartwatch debe estar vinculado al paciente identificado por el código.
- La detección de alertas por radiación se realiza dentro de `WatchDataService.ingestData()`: busca el tratamiento activo del paciente (`isActive = true`) y compara `currentRadiation` con `safetyThreshold`. Si se supera, crea una `DoctorAlert` con tipo `RADIATION_HIGH` y la transmite por WebSocket.
- El DTO `WatchMetricsResponse` incluye `patientName` además de `patientId` para facilitar la lectura en dashboards.
- `WatchIngestRequest` permite un `Authorization` header opcional para autenticación OAuth 2.0 (clientes registrados en `oauth_clients`). Si no se envía token, la validación se basa exclusivamente en `familyAccessCode`.
- La entidad subyacente es `HealthMetrics` (tabla `health_metrics`) que también es usada por `HealthMetricsController`.
