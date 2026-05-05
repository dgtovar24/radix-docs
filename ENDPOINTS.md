# RADIX API v1 — Reference Documentation

> **Base URL:** `https://api.raddix.pro/v1`
> **Dev URL:** `http://localhost:8080/v2`
> **Last updated:** Mayo 2026
> **Total endpoints:** 66 REST + 3 WebSocket

---

## Diagrama General de la API

```mermaid
graph TB
    subgraph "Clientes"
        WEB["Web App<br/>raddix.pro"]
        IOS["iOS App<br/>Expo/React Native"]
        WATCH["Smartwatch<br/>RADIX"]
        FAM["Familiares<br/>Acceso por código"]
    end

    subgraph "Autenticación"
        LOGIN["POST /api/auth/login<br/>Email + Password → JWT"]
        TOKEN["POST /api/auth/token<br/>OAuth 2.0 Client Credentials"]
        REG_DOC["POST /api/auth/register/doctor<br/>Admin crea facultativo"]
        REG_PAT["POST /api/auth/register/patient<br/>Doctor crea paciente"]
    end

    subgraph "Gestión de Pacientes"
        PAT_LIST["GET /api/patients"]
        PAT_GET["GET /api/patients/{id}"]
        PAT_PROF["GET /api/patients/profile/{userId}"]
        PAT_REG["POST /api/patients/register"]
        PAT_UPD["PUT /api/patients/{id}"]
        PAT_DEL["DELETE /api/patients/{id}"]
    end

    subgraph "Usuarios y Doctores"
        USR_ALL["GET /api/users"]
        USR_ROL["GET /api/users/role/{role}"]
        USR_GET["GET /api/users/{id}"]
        USR_UPD["PUT /api/users/{id}"]
        USR_DEL["DELETE /api/users/{id}"]
        DOC_ALL["GET /api/doctors"]
        DOC_GET["GET /api/doctors/{id}"]
        DOC_UPD["PUT /api/doctors/{id}"]
    end

    subgraph "Dispositivos"
        SW_CRE["POST /api/smartwatches"]
        SW_ALL["GET /api/smartwatches"]
        SW_GET["GET /api/smartwatches/{id}"]
        SW_PAT["GET /api/smartwatches/patient/{id}"]
        SW_UPD["PUT /api/smartwatches/{id}"]
        SW_DEL["DELETE /api/smartwatches/{id}"]
    end

    subgraph "Tratamientos"
        TRT_ALL["GET /api/treatments"]
        TRT_ACT["GET /api/treatments/active"]
        TRT_GET["GET /api/treatments/{id}"]
        TRT_PAT["GET /api/treatments/patient/{id}"]
        TRT_CRE["POST /api/treatments"]
        TRT_END["POST /api/treatments/{id}/end"]
    end

    subgraph "Monitorización"
        WT_ING["POST /api/watch/ingest"]
        WT_IME["GET /api/watch/{imei}/metrics"]
        WT_LAT["GET /api/watch/patient/{id}/latest"]
        HM_PAT["GET /api/health-metrics/patient/{id}?days="]
        HM_LAT["GET /api/health-metrics/patient/{id}/latest"]
        HM_TRT["GET /api/health-metrics/treatment/{id}"]
        HM_CRE["POST /api/health-metrics"]
        HL_PAT["GET /api/health-logs/patient/{id}?days="]
        RL_PAT["GET /api/radiation-logs/patient/{id}?days="]
        RL_TRT["GET /api/radiation-logs/treatment/{id}"]
    end

    subgraph "Alertas"
        ALT_ALL["GET /api/alerts"]
        ALT_PEN["GET /api/alerts/pending"]
        ALT_PAT["GET /api/alerts/patient/{id}"]
        ALT_RES["PUT /api/alerts/{id}/resolve"]
    end

    subgraph "Comunicación"
        MSG_PAT["GET /api/messages/patient/{id}"]
        MSG_SEN["POST /api/messages"]
        MSG_RED["PUT /api/messages/{id}/read"]
    end

    subgraph "Tiempo Real"
        WS_ALT["WS /ws/alerts"]
        WS_CHT["WS /ws/chat"]
        WS_RIX["WS /ws/rix"]
    end

    subgraph "Catálogos y Configuración"
        ISO_ALL["GET /api/isotopes"]
        UNT_ALL["GET /api/units"]
        DSH_STS["GET /api/dashboard/stats"]
        SET_GET["GET /api/settings/patient/{id}"]
        SET_UPD["PUT /api/settings/patient/{id}"]
        GAM_PAT["GET /api/games/patient/{id}"]
        GAM_CRE["POST /api/games"]
        OAUTH_AL["GET /api/oauth-clients"]
        OAUTH_CR["POST /api/oauth-clients"]
        UPLOAD["POST /api/upload"]
        FILE_GET["GET /api/files/{filename}"]
    end

    WEB --> LOGIN
    IOS --> LOGIN
    WATCH --> WT_ING
    FAM --> TOKEN
    LOGIN -->|JWT| PAT_LIST
    LOGIN -->|JWT| TRT_ALL
    LOGIN -->|JWT| ALT_ALL
    TOKEN -->|OAuth| WT_ING
    REG_DOC --> DOC_ALL
    REG_PAT --> PAT_LIST
    SW_CRE --> WATCH
    TRT_CRE --> HM_PAT
    WT_ING --> HM_PAT
    WT_ING --> ALT_ALL
    HM_PAT --> RL_PAT
```

---

## 1. Autenticación — `AuthController.java`

### `POST /api/auth/login`
**Descripción:** Inicia sesión con email y contraseña. Devuelve un token JWT firmado (HS384, 24h expiración) que debe enviarse en peticiones autenticadas como `Authorization: Bearer <token>`.

**Rate Limit:** 5 intentos por minuto por email. El 6º intento devuelve 429.

**Request Body:**
```json
{
  "email": "elena.ruiz@radix.pro",
  "password": "pass123"
}
```

**Response `200`:**
```json
{
  "token": "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiIyIiwicm9sZSI6IkRvY3RvciIsImZpcnN0TmFtZSI6IkVsZW5hIiwiaWF0IjoxNzc3NjE4NTcxLCJleHAiOjE3Nzc3MDQ5NzF9.xxx",
  "id": 2,
  "firstName": "Elena",
  "role": "Doctor"
}
```

**Response `401`:**
```json
{ "error": "Invalid credentials" }
```

**Response `429`:**
```json
{ "error": "Too many login attempts. Try again in 58 seconds." }
```

**Errores posibles:** `400` si faltan email/password, `401` credenciales inválidas, `429` rate limit excedido.

---

### `POST /api/auth/token`
**Descripción:** OAuth 2.0 Client Credentials Grant. Para acceso de familiares al smartwatch del paciente. El `clientId` es el código de acceso familiar (`familyAccessCode`), el `clientSecret` se genera al registrar al paciente.

**Request Body:**
```json
{
  "grantType": "client_credentials",
  "clientId": "FAM-0001",
  "clientSecret": "secret_1",
  "scope": "read"
}
```

**Response `200`:**
```json
{
  "accessToken": "d6f43ccf-fc97-4fa9-9678-876e4ce33c63",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "scope": "read write",
  "patientId": 1,
  "patientName": "Ana García",
  "familyAccessCode": "FAM-0001"
}
```

**Response `401`:**
```json
{ "error": "Invalid client credentials" }
```

---

### `POST /api/auth/register/doctor`
**Descripción:** Solo ADMIN. Registra un nuevo médico/facultativo en el sistema. Requiere token JWT de admin en `Authorization: Bearer <admin_jwt>`.

**Request Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzM4NCJ9...
```

**Request Body:**
```json
{
  "firstName": "Carlos",
  "lastName": "López Gómez",
  "email": "carlos@clinica.es",
  "password": "secure123",
  "licenseNumber": "282865432",
  "specialty": "Medicina Nuclear",
  "phone": "+34 600 000 000"
}
```

**Response `200`:**
```json
{ "message": "Doctor registered successfully", "id": 8 }
```

**Response `403`:**
```json
{ "error": "Only Admin can create Doctors" }
```

---

### `POST /api/auth/register/patient`
**Descripción:** Solo DOCTOR. Registra un nuevo paciente (crea User + Patient). Requiere token JWT de doctor en `Authorization: Bearer <doctor_jwt>`.

**Request Body:**
```json
{
  "firstName": "María",
  "lastName": "García",
  "email": "maria@email.com",
  "password": "secure123",
  "phone": "+34 612 345 678",
  "address": "Calle Mayor 123, Madrid"
}
```

**Response `200`:**
```json
{ "message": "Patient registered successfully", "id": 9 }
```

---

## 2. Pacientes — `PatientController.java`

### `GET /api/patients`
**Descripción:** Lista todos los pacientes activos (`isActive = true`). Sin autenticación requerida.

**Response `200`:**
```json
[
  {
    "id": 1,
    "fullName": "Ana García",
    "phone": "+34 612 345 610",
    "address": "Calle Mayor 1, Madrid",
    "isActive": true,
    "familyAccessCode": "FAM-0001",
    "fkUserId": 8,
    "fkDoctorId": 2,
    "createdAt": "2026-04-30T21:25:01"
  }
]
```

---

### `GET /api/patients/{id}`
**Descripción:** Obtiene un paciente por su ID. Solo pacientes activos.

**Path Parameters:**
| Param | Tipo | Descripción |
|-------|------|-------------|
| `id` | Integer | ID del paciente |

**Response `200`:** Objeto `Patient` (ver estructura arriba).

**Response `404`:**
```json
{ "error": "Not found" }
```

---

### `GET /api/patients/profile/{userId}`
**Descripción:** Busca el perfil de paciente asociado a un User ID específico. Útil para apps móviles que tienen el userId del login.

**Response `200`:** Objeto `Patient`.

---

### `POST /api/patients/register`
**Descripción:** Registro legacy de paciente + usuario. No requiere autenticación previa.

**Request Body:**
```json
{
  "firstName": "María",
  "lastName": "García",
  "email": "maria@email.com",
  "password": "secure123",
  "phone": "+34 612 345 678",
  "address": "Calle Mayor 123",
  "doctorId": 2
}
```

**Response `200`:**
```json
{ "message": "Patient created successfully", "userId": 9 }
```

---

### `PUT /api/patients/{id}`
**Descripción:** Actualiza datos de un paciente. Campos opcionales: solo se actualizan los campos enviados.

**Request Body:**
```json
{
  "phone": "+34 600 000 000",
  "address": "Nueva Dirección 456",
  "familyAccessCode": "FAM-NEW",
  "isActive": "true"
}
```

**Response `200`:** Objeto `Patient` actualizado.

---

### `DELETE /api/patients/{id}`
**Descripción:** Desactiva un paciente (soft delete: `isActive = false`). No elimina registros.

**Response `200`:**
```json
{ "message": "Patient deactivated" }
```

---

## 3. Usuarios — `UserController.java`

### `GET /api/users`
**Descripción:** Lista todos los usuarios registrados en el sistema.

**Response `200`:**
```json
[
  {
    "id": 1,
    "firstName": "Radix",
    "lastName": "Admin",
    "email": "Radix",
    "role": "ADMIN",
    "phone": "600111000",
    "licenseNumber": null,
    "specialty": null,
    "createdAt": "2026-04-30T21:25:01"
  }
]
```

---

### `GET /api/users/role/{role}`
**Descripción:** Filtra usuarios por rol. Valores válidos: `Doctor`, `Admin`, `patient`.

**Response `200`:** `List<User>`

---

### `GET /api/users/{id}`
**Descripción:** Obtiene un usuario específico por su ID.

**Response `404`:**
```json
{ "error": "User not found" }
```

---

### `PUT /api/users/{id}`
**Descripción:** Actualiza datos de un usuario. Todos los campos son opcionales.

**Request Body:**
```json
{
  "firstName": "Carlos",
  "lastName": "López",
  "email": "carlos@clinica.es",
  "phone": "+34 600 111 222",
  "licenseNumber": "282865432",
  "specialty": "Medicina Nuclear",
  "role": "Doctor"
}
```

---

### `DELETE /api/users/{id}`
**Descripción:** Elimina un usuario por su ID.

**Response `200`:**
```json
{ "message": "User deleted" }
```

---

## 4. Doctores — `DoctorController.java`

### `GET /api/doctors`
**Descripción:** Lista todos los facultativos con sus datos profesionales completos (número de colegiado, especialidad).

**Response `200`:**
```json
[
  {
    "id": 2,
    "firstName": "Elena",
    "lastName": "Ruiz",
    "email": "elena.ruiz@radix.pro",
    "phone": "600111001",
    "role": "Doctor",
    "licenseNumber": "282864321",
    "specialty": "Medicina Nuclear",
    "createdAt": "2026-04-30T21:25:01"
  }
]
```

---

### `GET /api/doctors/{id}`
**Descripción:** Perfil detallado de un doctor por ID.

---

### `PUT /api/doctors/{id}`
**Descripción:** Actualiza datos profesionales de un facultativo.

**Request Body:**
```json
{
  "phone": "+34 600 999 888",
  "licenseNumber": "282868888",
  "specialty": "Oncología Radioterápica"
}
```

---

## 5. Smartwatches — `SmartwatchController.java`

### `POST /api/smartwatches`
**Descripción:** Vincula un nuevo smartwatch a un paciente. Registra IMEI, MAC y modelo.

**Request Body:**
```json
{
  "fkPatientId": 1,
  "imei": "35928108492011",
  "macAddress": "00:1B:44:11:3A:B7",
  "model": "RadixWatch Pro v2"
}
```

**Response `201`:**
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

**Validación:** `fkPatientId` obligatorio, `imei` obligatorio y único.

---

### `GET /api/smartwatches`
**Descripción:** Lista todos los smartwatches registrados.

---

### `GET /api/smartwatches/{id}`
**Descripción:** Detalle de un smartwatch específico.

---

### `GET /api/smartwatches/patient/{patientId}`
**Descripción:** Dispositivos vinculados a un paciente concreto.

---

### `PUT /api/smartwatches/{id}`
**Descripción:** Actualiza datos del dispositivo (reasignar paciente, cambiar modelo).

---

### `DELETE /api/smartwatches/{id}`
**Descripción:** Desactiva un smartwatch (`isActive = false`).

---

## 6. Tratamientos — `TreatmentController.java`

### `POST /api/treatments`
**Descripción:** Crea un nuevo tratamiento de medicina nuclear. Requiere autenticación. Calcula automáticamente `isolationDays` (halfLife × 10) y `safetyThreshold` (initialDose × 0.1).

**Request Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "fkPatientId": 1,
  "fkRadioisotopeId": 1,
  "fkSmartwatchId": 1,
  "room": 402,
  "initialDose": 150.0
}
```

**Response `201`:**
```json
{
  "id": 13,
  "patientName": "Ana García",
  "patientId": 1,
  "doctorName": "Elena Ruiz",
  "doctorId": 2,
  "isotopeName": "Yodo-131",
  "isotopeId": 1,
  "room": 402,
  "initialDose": 150.0,
  "safetyThreshold": 15.0,
  "isolationDays": 80,
  "startDate": "2026-05-01T12:00:00",
  "endDate": null,
  "isActive": true,
  "currentRadiation": 45.2
}
```

---

### `GET /api/treatments`
**Descripción:** Lista todos los tratamientos con datos completos (paciente, doctor, isótopo).

---

### `GET /api/treatments/active`
**Descripción:** Solo tratamientos activos (`isActive = true`).

---

### `GET /api/treatments/{id}`
**Descripción:** Detalle de un tratamiento por ID.

---

### `GET /api/treatments/patient/{patientId}`
**Descripción:** Todos los tratamientos de un paciente específico.

---

### `POST /api/treatments/{id}/end`
**Descripción:** Finaliza un tratamiento. Establece `endDate` y `isActive = false`.

---

## 7. Alertas — `DoctorAlertController.java`

### `GET /api/alerts`
**Descripción:** Lista todas las alertas del sistema.

**Response `200`:**
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
    "createdAt": "2026-04-30T21:25:01"
  }
]
```

**Tipos de alerta:**
| Tipo | Significado |
|------|-------------|
| `RADIATION_HIGH` | Radiación supera el umbral de seguridad |
| `BPM_IRREGULAR` | Frecuencia cardíaca anómala detectada |
| `LOW_ACTIVITY` | Actividad física por debajo del mínimo |
| `OUTSIDE_ZONE` | Paciente fuera de la zona de aislamiento |
| `DEVICE_OFFLINE` | Smartwatch sin conexión |
| `INFO` | Informativo |

---

### `GET /api/alerts/pending`
**Descripción:** Solo alertas no resueltas (`isResolved = false`).

---

### `GET /api/alerts/patient/{patientId}`
**Descripción:** Alertas de un paciente concreto.

---

### `PUT /api/alerts/{id}/resolve`
**Descripción:** Marca una alerta como resuelta.

**Response `200`:** Objeto `Alert` con `isResolved: true`.

---

## 8. Watch Data — `WatchDataController.java`

### `POST /api/watch/ingest`
**Descripción:** Ingesta de métricas desde el smartwatch. Requiere IMEI + código familiar. Crea `HealthMetrics` y genera alertas automáticas si la radiación supera el umbral.

**Request Body:**
```json
{
  "imei": "35928108492011",
  "familyAccessCode": "FAM-0001",
  "bpm": 72,
  "steps": 4500,
  "distance": 3.2,
  "currentRadiation": 12.5,
  "recordedAt": "2026-05-01T14:30:00"
}
```

**Response `200`:**
```json
{ "status": "received" }
```

**Response `401`:**
```json
{ "error": "Invalid family access code" }
```

---

### `GET /api/watch/{imei}/metrics`
**Descripción:** Historial de métricas de un smartwatch por IMEI.

---

### `GET /api/watch/patient/{patientId}/latest`
**Descripción:** Última métrica registrada de un paciente.

**Response `200`:**
```json
{
  "id": 1,
  "patientId": 1,
  "imei": "35928108492011",
  "bpm": 72,
  "steps": 4500,
  "distance": 3.2,
  "currentRadiation": 12.5,
  "recordedAt": "2026-05-01T14:30:00"
}
```

---

## 9. Health Metrics — `HealthMetricsController.java`

### `GET /api/health-metrics/patient/{patientId}?days=7`
**Descripción:** Métricas de salud del paciente filtradas por los últimos N días. Datos: BPM, pasos, distancia, radiación.

**Query Parameters:**
| Param | Tipo | Default | Descripción |
|-------|------|---------|-------------|
| `days` | Integer | (todos) | Últimos N días de datos |

**Response `200`:**
```json
[
  {
    "id": 1,
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
**Descripción:** Última métrica registrada del paciente.

---

### `GET /api/health-metrics/treatment/{treatmentId}`
**Descripción:** Métricas asociadas a un tratamiento específico.

---

### `POST /api/health-metrics`
**Descripción:** Ingesta de métricas directamente desde el dashboard.

**Request Body:**
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

---

### `GET /api/health-logs/patient/{patientId}?days=30`
**Descripción:** Logs de salud sin procesar (BPM, pasos, distancia). Datos crudos del smartwatch.

---

### `GET /api/radiation-logs/patient/{patientId}?days=7`
**Descripción:** Historial de radiación del paciente. Usado por el gráfico de radiación en el dashboard.

**Response `200`:**
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
**Descripción:** Radiación asociada a un tratamiento concreto.

---

## 10. Mensajes — `MessageController.java`

### `GET /api/messages/patient/{patientId}`
**Descripción:** Mensajes motivacionales enviados a un paciente. Ordenados del más reciente al más antiguo.

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientId": 1,
    "messageText": "¡Ánimo! Ya has completado el 25% de tu tratamiento.",
    "isRead": false,
    "sentAt": "2026-05-01T10:00:00"
  }
]
```

---

### `POST /api/messages`
**Descripción:** Envía un mensaje motivacional a un paciente.

**Request Body:**
```json
{
  "fkPatientId": 1,
  "messageText": "Recuerda tu cita de control mañana a las 10:00."
}
```

**Response `201`:**
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
**Descripción:** Marca un mensaje como leído por el paciente.

---

## 11. Sesiones de Juego — `GameController.java`

### `GET /api/games/patient/{patientId}`
**Descripción:** Sesiones de juego del paciente. Gamificación del tratamiento.

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientId": 1,
    "score": 1250,
    "levelReached": 5,
    "playedAt": "2026-05-01T15:00:00"
  }
]
```

---

### `POST /api/games`
**Descripción:** Registra una nueva sesión de juego.

**Request Body:**
```json
{
  "fkPatientId": 1,
  "score": 2500,
  "levelReached": 7
}
```

---

## 12. Configuración — `SettingsController.java`

### `GET /api/settings/patient/{patientId}`
**Descripción:** Preferencias del paciente: unidad de medida, tema, notificaciones.

**Response `200`:**
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

---

### `PUT /api/settings/patient/{patientId}`
**Descripción:** Actualiza preferencias. Si no existen, las crea automáticamente.

**Request Body:**
```json
{
  "unitPreference": "imperial",
  "theme": "light",
  "notificationsEnabled": false
}
```

---

## 13. Catálogos

### `GET /api/isotopes` — `IsotopeController.java`
**Descripción:** Catálogo de radioisótopos para tratamientos de medicina nuclear.

**Response `200`:**
```json
[
  {
    "id": 1,
    "name": "Yodo-131",
    "symbol": "I-131",
    "type": "Beta/Gamma",
    "halfLife": 8.02,
    "halfLifeUnit": "días"
  }
]
```

---

### `GET /api/units` — `UnitController.java`
**Descripción:** Catálogo de unidades de medida para dosis de radiación.

**Response `200`:**
```json
[
  { "id": 1, "name": "Milicurio", "symbol": "mCi" },
  { "id": 2, "name": "Becquerel", "symbol": "Bq" },
  { "id": 3, "name": "Gray", "symbol": "Gy" },
  { "id": 4, "name": "Sievert", "symbol": "Sv" }
]
```

---

## 14. Dashboard — `DashboardController.java`

### `GET /api/dashboard/stats`
**Descripción:** Estadísticas agregadas para el dashboard principal.

**Response `200`:**
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

---

## 15. OAuth Clients — `OAuthClientController.java`

### `GET /api/oauth-clients`
**Descripción:** Lista clientes OAuth registrados (accesos familiares).

---

### `POST /api/oauth-clients`
**Descripción:** Crea un nuevo cliente OAuth para acceso familiar.

**Request Body:**
```json
{
  "clientId": "FAM-CUSTOM",
  "clientSecret": "my-secret",
  "clientName": "Custom Client",
  "grantType": "client_credentials",
  "scopes": "read"
}
```

---

## 16. Archivos — `FileController.java`

### `POST /api/upload`
**Descripción:** Subida de archivos (imágenes, PDFs). Límite 50MB. Almacenamiento persistente en volumen Docker.

**Request:** `multipart/form-data` con campo `file`.

**Response `201`:**
```json
{
  "url": "/api/files/fba4bbfc-5af6-4163-a5e2-4f6fc4afa396",
  "filename": "fba4bbfc-5af6-4163-a5e2-4f6fc4afa396",
  "originalName": "radiografia.jpg",
  "size": 245760
}
```

---

### `GET /api/files/{filename}`
**Descripción:** Sirve un archivo subido. Content-Type detectado automáticamente de la extensión.

**Response `200`:** Archivo binario con headers Content-Type apropiados.

---

## 17. WebSocket

### `WS /ws/alerts`
**Descripción:** Recibe alertas en tiempo real. El servidor envía objetos `Alert` cuando se genera una nueva alerta.

**Conexión:**
```
wss://api.raddix.pro/ws/alerts
```

**Mensaje recibido:**
```json
{
  "id": 25,
  "patientName": "Ana García",
  "patientId": 1,
  "treatmentId": 1,
  "alertType": "RADIATION_HIGH",
  "message": "Nivel de radiación crítico detectado",
  "isResolved": false,
  "createdAt": "2026-05-01T15:00:00"
}
```

---

### `WS /ws/chat`
**Descripción:** Chat interno entre facultativos. Broadcast a todos los conectados.

**Conexión:**
```
wss://api.raddix.pro/ws/chat
```

**Enviar mensaje:**
```json
{
  "from": "Elena Ruiz",
  "text": "He actualizado la ficha de aislamiento."
}
```

**Recibir mensaje:**
```json
{
  "type": "message",
  "from": "Elena Ruiz",
  "text": "He actualizado la ficha de aislamiento.",
  "timestamp": "2026-05-01T15:00:00"
}
```

---

### `WS /ws/rix`
**Descripción:** Asistente Rix AI para consultas clínicas. Procesa consultas y devuelve respuestas contextuales.

**Conexión:**
```
wss://api.raddix.pro/ws/rix
```

**Enviar consulta:**
```json
{
  "text": "Resume las alertas pendientes del turno",
  "context": { "doctorId": 2 }
}
```

**Recibir respuesta:**
```json
{
  "type": "response",
  "text": "Rix ha recibido tu consulta. Conectando con el contexto clínico...",
  "timestamp": "2026-05-01T15:00:00"
}
```

---

## 18. Sistema

### `GET /`
**Descripción:** Health check y metadata de la API.

**Response `200`:**
```json
{
  "name": "Radix API",
  "version": "v1",
  "description": "Nuclear Medicine Treatment Management System",
  "status": "operational",
  "timestamp": "2026-05-01T12:00:00",
  "docs": "/v1/docs",
  "endpoints": ["/v1/api/auth/login", "/v1/api/patients", ...]
}
```

---

### `GET /docs`
**Descripción:** Esquema autodescriptivo de la API en JSON.

---

## Índice Completo de Endpoints

| # | Método | Endpoint | Controlador |
|---|--------|----------|-------------|
| 1 | POST | `/api/auth/login` | AuthController |
| 2 | POST | `/api/auth/token` | AuthController |
| 3 | POST | `/api/auth/register/doctor` | AuthController |
| 4 | POST | `/api/auth/register/patient` | AuthController |
| 5 | GET | `/api/patients` | PatientController |
| 6 | GET | `/api/patients/{id}` | PatientController |
| 7 | GET | `/api/patients/profile/{userId}` | PatientController |
| 8 | POST | `/api/patients/register` | PatientController |
| 9 | PUT | `/api/patients/{id}` | PatientController |
| 10 | DELETE | `/api/patients/{id}` | PatientController |
| 11 | GET | `/api/users` | UserController |
| 12 | GET | `/api/users/role/{role}` | UserController |
| 13 | GET | `/api/users/{id}` | UserController |
| 14 | PUT | `/api/users/{id}` | UserController |
| 15 | DELETE | `/api/users/{id}` | UserController |
| 16 | GET | `/api/doctors` | DoctorController |
| 17 | GET | `/api/doctors/{id}` | DoctorController |
| 18 | PUT | `/api/doctors/{id}` | DoctorController |
| 19 | POST | `/api/smartwatches` | SmartwatchController |
| 20 | GET | `/api/smartwatches` | SmartwatchController |
| 21 | GET | `/api/smartwatches/{id}` | SmartwatchController |
| 22 | GET | `/api/smartwatches/patient/{id}` | SmartwatchController |
| 23 | PUT | `/api/smartwatches/{id}` | SmartwatchController |
| 24 | DELETE | `/api/smartwatches/{id}` | SmartwatchController |
| 25 | POST | `/api/treatments` | TreatmentController |
| 26 | GET | `/api/treatments` | TreatmentController |
| 27 | GET | `/api/treatments/active` | TreatmentController |
| 28 | GET | `/api/treatments/{id}` | TreatmentController |
| 29 | GET | `/api/treatments/patient/{id}` | TreatmentController |
| 30 | POST | `/api/treatments/{id}/end` | TreatmentController |
| 31 | GET | `/api/alerts` | DoctorAlertController |
| 32 | GET | `/api/alerts/pending` | DoctorAlertController |
| 33 | GET | `/api/alerts/patient/{id}` | DoctorAlertController |
| 34 | PUT | `/api/alerts/{id}/resolve` | DoctorAlertController |
| 35 | POST | `/api/watch/ingest` | WatchDataController |
| 36 | GET | `/api/watch/{imei}/metrics` | WatchDataController |
| 37 | GET | `/api/watch/patient/{id}/latest` | WatchDataController |
| 38 | GET | `/api/health-metrics/patient/{id}` | HealthMetricsController |
| 39 | GET | `/api/health-metrics/patient/{id}/latest` | HealthMetricsController |
| 40 | GET | `/api/health-metrics/treatment/{id}` | HealthMetricsController |
| 41 | POST | `/api/health-metrics` | HealthMetricsController |
| 42 | GET | `/api/health-logs/patient/{id}` | HealthMetricsController |
| 43 | GET | `/api/radiation-logs/patient/{id}` | HealthMetricsController |
| 44 | GET | `/api/radiation-logs/treatment/{id}` | HealthMetricsController |
| 45 | GET | `/api/messages/patient/{id}` | MessageController |
| 46 | POST | `/api/messages` | MessageController |
| 47 | PUT | `/api/messages/{id}/read` | MessageController |
| 48 | GET | `/api/games/patient/{id}` | GameController |
| 49 | POST | `/api/games` | GameController |
| 50 | GET | `/api/settings/patient/{id}` | SettingsController |
| 51 | PUT | `/api/settings/patient/{id}` | SettingsController |
| 52 | GET | `/api/isotopes` | IsotopeController |
| 53 | GET | `/api/isotopes/{id}` | IsotopeController |
| 54 | GET | `/api/units` | UnitController |
| 55 | GET | `/api/units/{id}` | UnitController |
| 56 | GET | `/api/oauth-clients` | OAuthClientController |
| 57 | POST | `/api/oauth-clients` | OAuthClientController |
| 58 | GET | `/api/dashboard/stats` | DashboardController |
| 59 | POST | `/api/upload` | FileController |
| 60 | GET | `/api/files/{filename}` | FileController |
| 61 | GET | `/` | HealthController |
| 62 | GET | `/docs` | DocsController |
| 63 | WS | `/ws/alerts` | WebSocketConfig |
| 64 | WS | `/ws/chat` | WebSocketConfig |
| 65 | WS | `/ws/rix` | WebSocketConfig |

---

## Autenticación

La API usa **JWT HS384** con expiración de 24 horas. El token se obtiene mediante `POST /api/auth/login` y debe enviarse en el header:
```
Authorization: Bearer eyJhbGciOiJIUzM4NCJ9...
```

Los endpoints públicos sin autenticación son:
- `GET /api/patients`, `GET /api/alerts`, `GET /api/treatments`
- `GET /api/isotopes`, `GET /api/units`, `GET /api/doctors`
- `GET /api/dashboard/stats`, `GET /`, `GET /docs`
- `POST /api/patients/register`

El acceso OAuth para familiares usa `POST /api/auth/token` con `clientId` (código familiar) + `clientSecret`.

---

## Validación

Los DTOs usan `jakarta.validation`:
- `RegisterRequest`: `@NotBlank firstName, lastName, email; @Email email; @Size(min=6) password`
- `SmartwatchRequest`: `@NotNull fkPatientId; @NotBlank imei`
- `MessageRequest`: `@NotNull fkPatientId; @NotBlank messageText`
- `GameSessionRequest`: `@NotNull fkPatientId, score`
- `HealthMetricsRequest`: `@NotNull fkPatientId`
- `TreatmentCreateRequest`: `@NotNull fkPatientId, fkRadioisotopeId, room, initialDose`

**Rate limiting:** Login limitado a 5 intentos/minuto por email. Excedido devuelve 429.

---

## Errores

| Código | Significado | Ejemplo |
|--------|-------------|---------|
| 400 | Bad Request | Faltan campos obligatorios |
| 401 | Unauthorized | Credenciales inválidas |
| 403 | Forbidden | Rol sin permisos |
| 404 | Not Found | Recurso no existe |
| 429 | Too Many Requests | Rate limit excedido |
| 500 | Internal Error | Error del servidor |

Todos los errores siguen el formato:
```json
{ "error": "Descripción del error" }
```
