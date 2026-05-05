# MessageController

> **Package:** `com.project.radix.Controller.MessageController`
> **Ruta base:** `/api/messages`
> **Endpoints:** 3

---

## Descripción general

Gestiona los mensajes motivacionales que los médicos envían a los pacientes durante el periodo de aislamiento. Los pacientes pueden ver sus mensajes en la app iOS y marcarlos como leídos.

---

## Endpoints

### `GET /api/messages/patient/{patientId}`

Lista los mensajes de un paciente, ordenados del más reciente al más antiguo.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "patientId": 1,
    "messageText": "¡Ánimo! Ya has completado el 25% de tu tratamiento. Sigue así.",
    "isRead": false,
    "sentAt": "2026-05-01T10:00:00"
  }
]
```

---

### `POST /api/messages`

Envía un mensaje motivacional a un paciente desde el panel del médico.

**Cuerpo de la petición:**
```json
{
  "fkPatientId": 1,
  "messageText": "Recuerda tu cita de control mañana a las 10:00. ¡Estamos contigo!"
}
```

**Validación:**
| Campo | Regla |
|-------|-------|
| `fkPatientId` | `@NotNull` — Obligatorio |
| `messageText` | `@NotBlank` — Obligatorio |

**Respuesta `201`:**
```json
{
  "id": 17,
  "patientId": 1,
  "messageText": "Recuerda tu cita de control mañana a las 10:00.",
  "isRead": false,
  "sentAt": "2026-05-01T12:00:00"
}
```

---

### `PUT /api/messages/{id}/read`

Marca un mensaje como leído por el paciente. La app iOS llama a este endpoint cuando el paciente abre un mensaje.

**Respuesta `200`:** Objeto `Message` con `isRead: true`.

**Respuesta `404`:**
```json
{ "error": "Message not found" }
```

---

## Notas de implementación

- Utiliza directamente `MotivationalMessageRepository` sin capa de servicio intermedia.
- La entidad `MotivationalMessage` está en la tabla `motivational_messages` con relación `@ManyToOne` a `Patient`.
- El repositorio tiene consultas: `findByFkPatientIdOrderBySentAtDesc`, `findByIsReadFalseAndFkPatientId`.
- El frontend web (`PatientDetails.tsx`) usa `POST /api/messages` para enviar mensajes al paciente desde la vista de detalle.
- La app iOS usa `GET` para mostrar mensajes en el dashboard del paciente y `PUT /{id}/read` al abrirlos.
