# HealthMetricsController

> **Package:** `com.project.radix.Controller.HealthMetricsController`
> **Rutas:** `/api/health-metrics`, `/api/health-logs`, `/api/radiation-logs`
> **Endpoints:** 7

---

## Descripción general

Gestiona las métricas de salud, logs sin procesar e historial de radiación de los pacientes. Estos endpoints alimentan los gráficos del dashboard y la vista de detalle del paciente.

---

## Endpoints

### `GET /api/health-metrics/patient/{patientId}?days=7`

Métricas de salud del paciente: BPM, pasos, distancia recorrida, radiación actual. Filtrable por los últimos N días.

**Parámetros de consulta:**
| Param | Tipo | Default | Descripción |
|-------|------|---------|-------------|
| `days` | Integer | (todos) | Últimos N días de datos |

**Respuesta `200`:**
```json
[
  {
    "id": 96,
    "patientId": 1,
    "treatmentId": 1,
    "bpm": 72,
    "steps": 4500,
    "distance": 3.2,
    "currentRadiation": 12.5,
    "recordedAt": "2026-05-01T14:30:00"
  }
]
```

---

### `GET /api/health-metrics/patient/{patientId}/latest`

Última métrica registrada del paciente. Usado por el widget KPI del dashboard y el monitor cardíaco en tiempo real.

**Respuesta `200`:** Un único objeto `HealthMetric`.

**Respuesta `404`:**
```json
{ "error": "No metrics found" }
```

---

### `GET /api/health-metrics/treatment/{treatmentId}`

Métricas de salud asociadas a un tratamiento específico.

---

### `POST /api/health-metrics`

Ingesta batch de métricas de salud. Alternativa a `/api/watch/ingest` para integraciones externas o ingesta desde el dashboard.

**Cuerpo de la petición:**
```json
{
  "fkPatientId": 1,
  "fkTreatmentId": 1,
  "bpm": 72,
  "steps": 4500,
  "distance": 3.2,
  "currentRadiation": 12.5
}
```

**Validación:**
| Campo | Regla |
|-------|-------|
| `fkPatientId` | `@NotNull` — Obligatorio |

**Respuesta `201`:** Objeto `HealthMetric` creado.

---

### `GET /api/health-logs/patient/{patientId}?days=30`

Logs de salud sin procesar del smartwatch. Datos crudos para exportación y análisis histórico.

**Parámetros de consulta:**
| Param | Tipo | Default | Descripción |
|-------|------|---------|-------------|
| `days` | Integer | (todos) | Últimos N días |

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "patientId": 1,
    "bpm": 72,
    "steps": 4500,
    "distance": 3.2,
    "timestamp": "2026-05-01T14:30:00"
  }
]
```

---

### `GET /api/radiation-logs/patient/{patientId}?days=7`

Historial de niveles de radiación del paciente. Alimenta el gráfico de radiación del dashboard.

**Parámetros de consulta:**
| Param | Tipo | Default | Descripción |
|-------|------|---------|-------------|
| `days` | Integer | (todos) | Últimos N días |

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "patientId": 1,
    "treatmentId": 1,
    "radiationLevel": 12.5,
    "timestamp": "2026-05-01T12:00:00"
  }
]
```

---

### `GET /api/radiation-logs/treatment/{treatmentId}`

Historial de radiación asociado a un tratamiento concreto.

---

## Notas de implementación

- Usa `HealthMetricsService` como capa de servicio que agrupa los repositorios `HealthMetricsRepository`, `HealthLogRepository` y `RadiationLogRepository`.
- El filtro `?days=N` se aplica en memoria filtrando por `recordedAt`/`timestamp` con un cutoff de `LocalDateTime.now().minusDays(N)`.
- Las métricas se crean automáticamente desde `WatchDataService.ingestData()` cuando el smartwatch envía datos.
- Los radiation logs se crean por cada ingesta del smartwatch que incluya `currentRadiation`.
