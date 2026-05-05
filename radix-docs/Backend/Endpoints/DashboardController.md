# DashboardController

> **Package:** `com.project.radix.Controller.DashboardController`
> **Ruta base:** `/api/dashboard`
> **Endpoints:** 1

---

## Descripción general

Proporciona estadísticas agregadas para el dashboard principal. Los datos se calculan mediante consultas de conteo a los repositorios correspondientes.

---

## Endpoints

### `GET /api/dashboard/stats`

Estadísticas agregadas en tiempo real del sistema.

**Respuesta `200`:**
```json
{
  "totalPatients": 12,
  "totalDoctors": 6,
  "activeTreatments": 8,
  "pendingAlerts": 14,
  "totalSmartwatches": 12,
  "activeIsotopes": 11
}
```

**Campos:**
| Campo | Tipo | Origen |
|-------|------|--------|
| `totalPatients` | long | `PatientRepository.count()` (activos) |
| `totalDoctors` | long | `UserRepository` filtrando por rol `Doctor` |
| `activeTreatments` | long | `TreatmentRepository.findByIsActiveTrue().size()` |
| `pendingAlerts` | long | `AlertRepository.findByIsResolvedFalse().size()` |
| `totalSmartwatches` | long | `SmartwatchRepository.count()` |
| `activeIsotopes` | long | `IsotopeCatalogRepository.count()` |

---

## Uso en el frontend

El widget KPI del dashboard (`DashboardWidgets.tsx`) llama a este endpoint cada 30 segundos para actualizar las tarjetas de:

- **Pacientes Totales:** Total de pacientes activos en el sistema
- **Tratamientos Activos:** Tratamientos en curso
- **Alertas Pendientes:** Alertas que requieren acción del médico

**Ejemplo de uso en frontend:**
```typescript
const stats = await dashboard.getStats();
// stats.totalPatients → 12
// stats.pendingAlerts → 14
```

---

## Notas de implementación

- Sin autenticación requerida (endpoint público).
- Utiliza inyección de dependencias con `@RequiredArgsConstructor`.
- Los repositorios inyectados: `PatientRepository`, `UserRepository`, `TreatmentRepository`, `AlertRepository`, `SmartwatchRepository`, `IsotopeCatalogRepository`.
- Sin capa de servicio intermedia (la lógica está en el propio controlador por simplicidad).
