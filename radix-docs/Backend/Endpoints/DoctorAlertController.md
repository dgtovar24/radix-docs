# DoctorAlertController

> **Package:** `com.project.radix.Controller.DoctorAlertController`
> **Ruta base:** `/api/alerts`
> **Endpoints:** 4

---

## Descripción general

Gestiona las alertas médicas generadas durante el monitoreo de pacientes. Las alertas se crean automáticamente cuando la radiación supera el umbral de seguridad, o cuando se detectan anomalías en el smartwatch (BPM irregular, baja actividad, fuera de zona).

**Tipos de alerta:**
| Tipo | Significado |
|------|-------------|
| `RADIATION_HIGH` | Radiación supera el umbral de seguridad |
| `BPM_IRREGULAR` | Frecuencia cardíaca anómala detectada |
| `LOW_ACTIVITY` | Actividad física por debajo del mínimo recomendado |
| `OUTSIDE_ZONE` | Paciente detectado fuera de la zona de aislamiento |
| `DEVICE_OFFLINE` | Smartwatch sin conexión |
| `INFO` | Informativo |

---

## Endpoints

### `GET /api/alerts`

Lista todas las alertas del sistema, ordenadas por fecha de creación (más recientes primero).

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "patientName": "Ana García",
    "patientId": 1,
    "treatmentId": 1,
    "alertType": "RADIATION_HIGH",
    "message": "Nivel de radiación supera el umbral de seguridad",
    "isResolved": false,
    "createdAt": "2026-05-01T14:30:00"
  }
]
```

---

### `GET /api/alerts/pending`

Filtra solo las alertas no resueltas (`isResolved = false`). Usado por el dashboard para mostrar las alertas que requieren acción.

---

### `GET /api/alerts/patient/{patientId}`

Alertas de un paciente concreto. Útil para la vista de detalle del paciente.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `patientId` | Integer | ID del paciente |

---

### `PUT /api/alerts/{id}/resolve`

Marca una alerta como resuelta. Cambia `isResolved` a `true` y guarda el cambio.

**Parámetros de ruta:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID de la alerta |

**Respuesta `200`:**
```json
{
  "id": 1,
  "patientName": "Ana García",
  "patientId": 1,
  "alertType": "RADIATION_HIGH",
  "message": "Nivel de radiación supera el umbral de seguridad",
  "isResolved": true,
  "createdAt": "2026-05-01T14:30:00"
}
```

**Respuesta `404`:**
```json
{ "error": "Alert not found" }
```

---

## WebSocket asociado

Las alertas también se transmiten en tiempo real por `WS /ws/alerts`. Ver `WebSocketConfig.md`.

---

## Notas de implementación

- Utiliza `AlertService` para la lógica de negocio.
- Las alertas se crean desde `WatchDataService.ingestData()` cuando `currentRadiation > safetyThreshold`.
- El repositorio `DoctorAlertRepository` tiene consultas: `findByIsResolvedFalse`, `findByFkPatientId`, `findByFkTreatmentId`.
- La entidad `DoctorAlert` está relacionada con `Patient` y `Treatment` mediante `@ManyToOne` (LAZY).
