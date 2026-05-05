# SettingsController

> **Package:** `com.project.radix.Controller.SettingsController`
> **Ruta base:** `/api/settings`
> **Endpoints:** 2

---

## Descripción general

Gestiona las preferencias de configuración de cada paciente: unidad de medida preferida, tema visual y estado de las notificaciones. Las preferencias se crean automáticamente si no existen al hacer la primera actualización.

---

## Endpoints

### `GET /api/settings/patient/{patientId}`

Obtiene las preferencias de un paciente.

**Respuesta `200`:**
```json
{
  "id": 1,
  "patientId": 1,
  "unitPreference": "metric",
  "theme": "dark",
  "notificationsEnabled": true,
  "updatedAt": "2026-05-01T09:00:00"
}
```

**Respuesta `404`:**
```json
{ "error": "Settings not found" }
```

---

### `PUT /api/settings/patient/{patientId}`

Actualiza las preferencias del paciente. Si no existen, se crean automáticamente con los valores por defecto y luego se aplican los cambios.

**Cuerpo de la petición:**
```json
{
  "unitPreference": "imperial",
  "theme": "light",
  "notificationsEnabled": false
}
```

**Respuesta `200`:** Objeto `Settings` actualizado.

---

## Notas de implementación

- Utiliza directamente `SettingsRepository` sin capa de servicio.
- La entidad `Settings` está en la tabla `settings` con relación `@ManyToOne` (LAZY) a `Patient`.
- La clave `fk_patient_id` es única (un paciente tiene exactamente un registro de configuración).
- El repositorio tiene la consulta: `findByFkPatientId`.
- **Comportamiento especial:** Si se hace `PUT` y no existe el registro, se crea uno nuevo con los valores por defecto (`metric`, `light`, `notificationsEnabled=true`) y luego se aplican los campos enviados.
