# GameController

> **Package:** `com.project.radix.Controller.GameController`
> **Ruta base:** `/api/games`
> **Endpoints:** 2

---

## Descripción general

Gestiona las sesiones de juego de los pacientes como parte del sistema de gamificación del tratamiento. Los juegos ayudan a mantener al paciente activo mentalmente durante el aislamiento y proporcionan métricas de engagement al equipo médico.

---

## Endpoints

### `GET /api/games/patient/{patientId}`

Lista las sesiones de juego de un paciente, ordenadas de la más reciente a la más antigua.

**Respuesta `200`:**
```json
[
  {
    "id": 35,
    "patientId": 1,
    "score": 1250,
    "levelReached": 5,
    "playedAt": "2026-05-01T15:00:00"
  }
]
```

---

### `POST /api/games`

Registra una nueva sesión de juego completada por el paciente.

**Cuerpo de la petición:**
```json
{
  "fkPatientId": 1,
  "score": 2500,
  "levelReached": 7
}
```

**Validación:**
| Campo | Regla |
|-------|-------|
| `fkPatientId` | `@NotNull` — Obligatorio |
| `score` | `@NotNull` — Obligatorio, por defecto 0 |
| `levelReached` | Opcional, por defecto 1 |

**Respuesta `201`:**
```json
{
  "id": 36,
  "patientId": 1,
  "score": 2500,
  "levelReached": 7,
  "playedAt": "2026-05-01T16:00:00"
}
```

---

## Notas de implementación

- Utiliza directamente `GameSessionRepository` sin capa de servicio.
- La entidad `GameSession` está en la tabla `game_sessions` con campos: `id`, `fk_patient_id`, `score`, `level_reached`, `played_at`.
- El repositorio tiene la consulta: `findByFkPatientIdOrderByPlayedAtDesc`.
- Relación `@ManyToOne` (LAZY) con `Patient`.
