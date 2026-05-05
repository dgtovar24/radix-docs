# SmartwatchController

> **Package:** `com.project.radix.Controller.SmartwatchController`
> **Ruta base:** `/api/smartwatches`
> **Endpoints:** 6

---

## Descripción general

Gestiona el ciclo de vida completo de los smartwatches vinculados a pacientes: registro, consulta, actualización y desactivación. Cada smartwatch se identifica por su IMEI (único) y dirección MAC (única).

---

## Endpoints

### `POST /api/smartwatches`

Vincula un nuevo smartwatch a un paciente. Valida que el IMEI sea único y que el paciente exista.

**Cuerpo de la petición:**
```json
{
  "fkPatientId": 1,
  "imei": "35928108492011",
  "macAddress": "00:1B:44:11:3A:B7",
  "model": "RadixWatch Pro v2"
}
```

**Validación:**
| Campo | Regla |
|-------|-------|
| `fkPatientId` | `@NotNull` — Obligatorio |
| `imei` | `@NotBlank` — Obligatorio, único |

**Respuesta `201`:**
```json
{
  "id": 13,
  "imei": "35928108492011",
  "macAddress": "00:1B:44:11:3A:B7",
  "model": "RadixWatch Pro v2",
  "isActive": true,
  "patientId": 1,
  "patientName": "Ana García"
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `Patient ID is required` |
| 400 | `IMEI is required` |
| 400 | `IMEI already registered` |
| 400 | `MAC address already registered` |

---

### `GET /api/smartwatches`

Lista todos los smartwatches registrados en el sistema.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "imei": "35928108492011",
    "macAddress": "00:1B:44:11:3A:B7",
    "model": "RadixWatch Pro v2",
    "isActive": true,
    "patientId": 1,
    "patientName": "Ana García"
  }
]
```

---

### `GET /api/smartwatches/{id}`

Obtiene el detalle de un smartwatch por su ID.

---

### `GET /api/smartwatches/patient/{patientId}`

Lista los smartwatches vinculados a un paciente concreto. Útil para la vista de detalles del paciente y para la app iOS.

---

### `PUT /api/smartwatches/{id}`

Actualiza los datos de un smartwatch. Permite reasignarlo a otro paciente, cambiar el modelo o actualizar la MAC.

**Cuerpo de la petición:**
```json
{
  "fkPatientId": 2,
  "model": "RadixWatch Lite"
}
```

---

### `DELETE /api/smartwatches/{id}`

Desactiva un smartwatch (`isActive = false`). No se elimina el registro; se mantiene para auditoría.

**Respuesta `200`:**
```json
{ "message": "Smartwatch deactivated" }
```

---

## Notas de implementación

- Utiliza `SmartwatchService` para la lógica de negocio y validación.
- El repositorio `SmartwatchRepository` tiene consultas personalizadas: `findByImei`, `findByMacAddress`, `findByFkPatientId`.
- La entidad `Smartwatch` está relacionada con `Patient` mediante `@ManyToOne` (LAZY) sobre `fk_patient_id`.
- El modelo acepta los valores: `RadixWatch Pro v2`, `RadixWatch Lite`, `External Generic Watch`.
