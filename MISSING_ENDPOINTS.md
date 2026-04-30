# RADIX API — Endpoints Faltantes y Análisis de Brechas

> **Fecha del análisis:** Abril 2026
> **Fuente:** Análisis exhaustivo de cada componente del frontend (`radix-web/src/`) y cada controlador del backend (`radix-api/src/main/java/com/project/radix/Controller/`)
> **Resultado:** 35 endpoints necesarios no implementados + 3 problemas de implementación parcial

---

## Diagrama de Dependencias Frontend → Backend

```mermaid
graph TB
    subgraph "Frontend — Páginas Astro"
        DASH[/dashboard]
        PAC[/pacientes]
        TRAT[/tratamientos]
        ALERTA[/alertas]
        USR[/usuarios]
        FAC[/facultativos]
        CONF[/configuracion]
        RIX[/rix]
    end

    subgraph "Frontend — Componentes React"
        DW[DashboardWidgets<br/>mockDashboardData.ts]
        PL[PatientList]
        PD[PatientDetails<br/>+ gráficos simulados]
        PF[PatientForm]
        PW[PatientRegistrationWizard<br/>4 pasos]
        TL[TreatmentList]
        TF[TreatmentForm]
        CC[ConfinementCalculator]
        AL[AlertList<br/>+ WebSocket]
        UL[UsuariosList]
        FL[FacultativosList]
        UW[UserRegistrationWizard<br/>colegiado+especialidad]
        BP[BluetoothPairing]
        DL[DashboardLayout<br/>Chat interno + Rix]
    end

    subgraph "Backend — Controladores EXISTENTES"
        AUTH[AuthController ✓<br/>4 endpoints]
        PAT[PatientController ⚠️<br/>4 endpoints<br/>respuesta incompleta]
        USRC[UserController ⚠️<br/>2 endpoints<br/>sin CRUD completo]
        TRTC[TreatmentController ✓<br/>6 endpoints]
        ALTC[AlertController ✓<br/>4 endpoints]
        WTC[WatchController ✓<br/>3 endpoints]
        ISOC[IsotopeController ✓<br/>2 endpoints]
        DSHC[DashboardController ✓<br/>1 endpoint]
    end

    subgraph "Backend — Controladores FALTANTES"
        SWC[SmartwatchController ✗]
        DOCC[DoctorController ✗]
        HLMC[HealthLogController ✗]
        RADLC[RadiationLogController ✗]
        MSGC[MessageController ✗]
        GAMEC[GameController ✗]
        SETC[SettingsController ✗]
        CHATC[ChatController ✗]
        UNITC[UnitController ✗]
        OAC[OAuthClientController ✗]
    end

    subgraph "Entidades sin API"
        SW[(Smartwatch)]
        HL[(HealthLog)]
        RL[(RadiationLog)]
        GM[(GameSession)]
        MM[(MotivationalMessage)]
        ST[(Settings)]
        UN[(Unit)]
    end

    %% Dependencias frontend → backend existente
    DASH --> DW --> DSHC
    PAC --> PL --> PAT
    PAC --> PD --> PAT
    PAC --> PF --> PAT
    PAC --> PW
    TRAT --> TL --> TRTC
    TRAT --> TF --> TRTC
    TRAT --> CC --> ISOC
    ALERTA --> AL --> ALTC
    USR --> UL --> USRC
    USR --> UW
    FAC --> FL --> USRC
    CONF --> DL
    
    %% Dependencias frontend → backend FALTANTE
    PW -.-> SWC
    PW -.-> SWC
    BP -.-> SWC
    PD -.-> HLMC
    PD -.-> RADLC
    PD -.-> MSGC
    DW -.-> HLMC
    DW -.-> RADLC
    UW -.-> DOCC
    UW -.-> USRC
    DL -.-> CHATC
    DL -.-> MSGC
    TF -.-> SWC

    %% Entidades ↔ controladores faltantes
    SWC -.-> SW
    HLMC -.-> HL
    RADLC -.-> RL
    GAMEC -.-> GM
    MSGC -.-> MM
    SETC -.-> ST
    UNITC -.-> UN

    style SWC fill:#ef4444,color:#fff
    style DOCC fill:#ef4444,color:#fff
    style HLMC fill:#ef4444,color:#fff
    style RADLC fill:#ef4444,color:#fff
    style MSGC fill:#ef4444,color:#fff
    style GAMEC fill:#ef4444,color:#fff
    style SETC fill:#ef4444,color:#fff
    style CHATC fill:#ef4444,color:#fff
    style UNITC fill:#f59e0b,color:#fff
    style OAC fill:#f59e0b,color:#fff
    style PAT fill:#f59e0b,color:#fff
    style USRC fill:#f59e0b,color:#fff
```

---

## Prioridades

| Prioridad | Significado | Cantidad |
|-----------|-------------|----------|
| **P0 — Crítico** | Componentes del frontend rotos sin estos endpoints | 8 |
| **P1 — Alto** | Frontend usa mock data, necesita API real | 14 |
| **P2 — Medio** | Funcionalidad futura o de soporte | 13 |

---

## 1. Smartwatch / Dispositivos Médicos (P0 — 5 endpoints)

### Componentes afectados
- `PatientRegistrationWizard.tsx` Step 2 — recoge IMEI, MAC, modelo
- `BluetoothPairing.tsx` — conecta dispositivos RADIX vía Web Bluetooth
- `TreatmentForm.tsx` — puede asociar `fkSmartwatchId` al tratamiento

### Entidad existente
`Smartwatch.java` — tabla `smartwatches` con campos: `id`, `fkPatientId`, `imei`, `macAddress`, `model`, `isActive`

### Repositorio existente
`SmartwatchRepository.java` — métodos: `findByImei`, `findByMacAddress`, `findByFkPatientId`

### Endpoints necesarios

#### `POST /v2/api/smartwatches`
Vincular un nuevo smartwatch a un paciente.

**Request Body:**
```json
{
  "fkPatientId": 101,
  "imei": "35928108492011",
  "macAddress": "00:1B:44:11:3A:B7",
  "model": "RadixWatch Pro v2"
}
```

**Response `201`:**
```json
{
  "id": 3,
  "fkPatientId": 101,
  "imei": "35928108492011",
  "macAddress": "00:1B:44:11:3A:B7",
  "model": "RadixWatch Pro v2",
  "isActive": true
}
```

**Propósito:** `PatientRegistrationWizard` Step 2 → `BluetoothPairing.onPaired(imei)` → registro del dispositivo en BD.

---

#### `GET /v2/api/smartwatches`
Listar todos los smartwatches registrados.

**Response `200`:**
```json
[
  {
    "id": 3,
    "fkPatientId": 101,
    "patientName": "María González",
    "imei": "35928108492011",
    "macAddress": "00:1B:44:11:3A:B7",
    "model": "RadixWatch Pro v2",
    "isActive": true
  }
]
```

**Propósito:** Vista de administración de dispositivos.

---

#### `GET /v2/api/smartwatches/{id}`
Obtener detalle de un smartwatch.

---

#### `PUT /v2/api/smartwatches/{id}`
Actualizar datos del dispositivo (reasignar paciente, cambiar modelo, activar/desactivar).

---

#### `GET /v2/api/smartwatches/patient/{patientId}`
Obtener los smartwatches vinculados a un paciente.

**Propósito:** `PatientDetails.tsx` — mostrar dispositivo vinculado al paciente.

---

## 2. Usuarios — CRUD completo (P0 — 3 endpoints)

### Componentes afectados
- `UsuariosList.tsx` — botón "Nuevo Usuario" → `/usuarios/nuevo`
- `UserRegistrationWizard.tsx` — wizard de 3-4 pasos para crear usuarios
- `FacultativosList.tsx` — botón "Nuevo Facultativo" → `/register`

### Endpoints existentes
- `GET /v2/api/users` ✓ — listar todos
- `GET /v2/api/users/role/{role}` ✓ — filtrar por rol
- `POST /v2/api/auth/register/doctor` ✓ — crear doctor (solo admin)
- `POST /v2/api/auth/register/patient` ✓ — crear paciente (solo doctor)

### Endpoints necesarios

#### `GET /v2/api/users/{id}`
Obtener un usuario específico por ID.

**Propósito:** `UserRegistrationWizard` resumen, edición de usuario existente.

---

#### `PUT /v2/api/users/{id}`
Actualizar datos de un usuario (nombre, email, rol, teléfono).

**Request Body:**
```json
{
  "firstName": "Carlos",
  "lastName": "López Gómez",
  "email": "carlos@clinica.es",
  "role": "Doctor",
  "phone": "+34 600 111 222"
}
```

> ⚠️ **Nota:** El modelo `User.java` NO tiene campo `phone`. Debe añadirse.

**Propósito:** Edición de perfil desde panel de administración.

---

#### `DELETE /v2/api/users/{id}`
Desactivar o eliminar un usuario.

**Propósito:** Gestión de bajas en el sistema.

---

## 3. Perfil de Doctor / Facultativo (P0 — 3 endpoints)

### Componentes afectados
- `UserRegistrationWizard.tsx` Step 3 — recoge `colegiadoNumber` y `specialty`
- `FacultativosList.tsx` — muestra lista de doctores

### Problema
El modelo `User.java` solo tiene: `id`, `firstName`, `lastName`, `email`, `password`, `role`, `createdAt`.
**NO tiene campos para número de colegiado ni especialidad médica.**

### Solución propuesta
- Opción A: Extender modelo `User` con campos `licenseNumber` y `specialty`
- Opción B: Crear nueva entidad `DoctorProfile` con FK a `User`

### Endpoints necesarios (asumiendo Opción A)

#### `GET /v2/api/doctors`
Listar doctores con sus datos profesionales completos.

**Response `200`:**
```json
[
  {
    "id": 5,
    "firstName": "Carlos",
    "lastName": "López",
    "email": "carlos@clinica.es",
    "role": "Doctor",
    "licenseNumber": "282865432",
    "specialty": "Medicina Nuclear",
    "createdAt": "2024-01-15T10:30:00"
  }
]
```

**Propósito:** `FacultativosList.tsx` — reemplazar la llamada actual a `GET /users/role/Doctor` que no incluye datos profesionales.

---

#### `GET /v2/api/doctors/{id}`
Perfil completo de un doctor.

---

#### `PUT /v2/api/doctors/{id}`
Actualizar datos profesionales (número colegiado, especialidad).

---

## 4. Pacientes — CRUD completo (P1 — 2 endpoints)

### Endpoints existentes pero incompletos
- `GET /v2/api/patients` — solo devuelve `{id, fullName}`
- `GET /v2/api/patients/{id}` — solo devuelve `{id, fullName}`

### Mejora necesaria en endpoints existentes
**Ampliar respuesta** de ambos endpoints para incluir todos los campos que el frontend espera:

```json
{
  "id": 101,
  "fullName": "María González",
  "phone": "+34 612 345 678",
  "address": "Calle Mayor 123, Madrid",
  "isActive": true,
  "familyAccessCode": "RADIX-FAM-A1B2",
  "fkUserId": 9,
  "fkDoctorId": 5,
  "createdAt": "2024-03-15T09:00:00"
}
```

**Componentes afectados:** `PatientList.tsx:148-162` (phone, address, isActive, createdAt), `PatientDetails.tsx:157` (birthDate — **no existe en BD**)

### Endpoints nuevos necesarios

#### `PUT /v2/api/patients/{id}`
Actualizar datos de un paciente.

**Request Body:**
```json
{
  "phone": "+34 600 000 000",
  "address": "Nueva Dirección 456",
  "familyAccessCode": "RADIX-FAM-NEW",
  "isActive": true
}
```

**Propósito:** Edición de datos de paciente desde `PatientDetails.tsx`.

---

#### `DELETE /v2/api/patients/{id}`
Desactivar un paciente (soft delete: `isActive = false`).

---

## 5. Historial de Salud y Radiación (P1 — 6 endpoints)

### Componentes afectados
- `DashboardWidgets.tsx` — **RadiationChartWidget** (usa `MOCK_RADIATION_LOGS`), **PatientActivityRadarWidget** (usa `MOCK_RADAR_DATA`)
- `PatientDetails.tsx` — gráficos de **pasos**, **oxígeno (SpO2)**, **sueño** con `setInterval` simulado
- `mockDashboardData.ts` — todos los datos son estáticos/hardcodeados

### Entidades existentes sin controlador
- `HealthMetrics.java` — tabla `health_metrics`: `id`, `fkTreatmentId`, `fkPatientId`, `bpm`, `steps`, `distance`, `currentRadiation`, `recordedAt`
- `HealthLog.java` — tabla `health_logs`: `id`, `fkPatientId`, `bpm`, `steps`, `distance`, `timestamp`
- `RadiationLog.java` — tabla `radiation_logs`: `id`, `fkPatientId`, `fkTreatmentId`, `radiationLevel`, `timestamp`

### Repositorios existentes
- `HealthMetricsRepository.java` — `findByFkPatientIdOrderByRecordedAtDesc`, `findFirstByFkPatientIdOrderByRecordedAtDesc`, `findByFkTreatmentId`
- `HealthLogRepository.java` — `findByFkPatientIdOrderByTimestampDesc`, `findByTimestampBetween`
- `RadiationLogRepository.java` — `findByFkPatientIdOrderByTimestampDesc`, `findByFkTreatmentIdOrderByTimestampDesc`, `findByTimestampBetween`

### Endpoints necesarios

#### `GET /v2/api/health-metrics/patient/{patientId}`
Métricas de salud del paciente: BPM, pasos, distancia, radiación actual.

**Query params:** `?days=7` (últimos N días), `?from=2024-03-01&to=2024-03-15`

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientId": 101,
    "treatmentId": 1,
    "bpm": 72,
    "steps": 4500,
    "distance": 3.2,
    "currentRadiation": 12.5,
    "recordedAt": "2024-03-15T14:30:00"
  }
]
```

**Propósito:** `PatientDetails.tsx` — reemplazar `setInterval` simulado con datos reales del smartwatch. `DashboardWidgets.tsx` — gráficos de actividad del paciente.

---

#### `GET /v2/api/health-metrics/treatment/{treatmentId}`
Métricas de salud de un tratamiento específico.

---

#### `GET /v2/api/radiation-logs/patient/{patientId}`
Historial de niveles de radiación de un paciente.

**Query params:** `?days=7`

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientId": 101,
    "treatmentId": 1,
    "radiationLevel": 12.5,
    "timestamp": "2024-03-15T12:00:00"
  }
]
```

**Propósito:** `DashboardWidgets.tsx` **RadiationChartWidget** — reemplazar `MOCK_RADIATION_LOGS`. `PatientDetails.tsx` — evolución de radiación.

---

#### `GET /v2/api/radiation-logs/treatment/{treatmentId}`
Radiación de un tratamiento específico.

---

#### `GET /v2/api/health-logs/patient/{patientId}`
Logs de salud sin procesar del smartwatch.

**Propósito:** Datos históricos sin procesar para exportación/análisis.

---

#### `POST /v2/api/health-metrics`
Ingesta de métricas desde el smartwatch (similar a `POST /watch/ingest` pero orientado al dashboard).

> *Nota:* `POST /v2/api/watch/ingest` ya crea `HealthMetrics`. Este endpoint sería para ingesta desde el dashboard o integración con APIs externas.

---

## 6. Mensajería y Motivación (P2 — 6 endpoints)

### Componentes afectados
- `DashboardLayout.tsx` — **InternalChatPanel** con chat interno entre médicos, **RixPanel** con asistente IA
- `PatientDetails.tsx` — formulario "Comunicación Directa" para enviar mensajes al dispositivo del paciente

### Entidades existentes sin controlador
- `MotivationalMessage.java` — tabla `motivational_messages`: `id`, `fkPatientId`, `messageText`, `isRead`, `sentAt`
- `GameSession.java` — tabla `game_sessions`: `id`, `fkPatientId`, `score`, `levelReached`, `playedAt`
- `Settings.java` — tabla `settings`: `id`, `fkPatientId`, `unitPreference`, `theme`, `notificationsEnabled`, `updatedAt`

### Repositorios existentes
- `MotivationalMessageRepository.java` — `findByFkPatientIdOrderBySentAtDesc`, `findByIsReadFalseAndFkPatientId`
- `GameSessionRepository.java` — `findByFkPatientIdOrderByPlayedAtDesc`
- `SettingsRepository.java` — `findByFkPatientId`

### Endpoints necesarios

#### `GET /v2/api/messages/patient/{patientId}`
Mensajes motivacionales enviados a un paciente.

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientId": 101,
    "messageText": "¡Ánimo! Ya has completado el 50% del tratamiento.",
    "isRead": false,
    "sentAt": "2024-03-16T10:00:00"
  }
]
```

**Propósito:** `PatientDetails.tsx` — historial de comunicación con el paciente.

---

#### `POST /v2/api/messages`
Enviar un mensaje a un paciente.

**Request Body:**
```json
{
  "fkPatientId": 101,
  "messageText": "Recuerda tu cita de control mañana a las 10:00."
}
```

**Propósito:** `PatientDetails.tsx` formulario "Comunicación Directa" (línea 260).

---

#### `PUT /v2/api/messages/{id}/read`
Marcar mensaje como leído.

---

#### `GET /v2/api/games/patient/{patientId}`
Sesiones de juego del paciente (gamificación del tratamiento).

**Propósito:** Seguimiento de engagement del paciente durante el confinamiento.

---

#### `POST /v2/api/games`
Registrar una nueva sesión de juego.

**Request Body:**
```json
{
  "fkPatientId": 101,
  "score": 1250,
  "levelReached": 5
}
```

---

#### `GET /v2/api/settings/patient/{patientId}` + `PUT /v2/api/settings/patient/{patientId}`
Preferencias del paciente: unidad de medida, tema, notificaciones.

**Response `200`:**
```json
{
  "unitPreference": "metric",
  "theme": "dark",
  "notificationsEnabled": true,
  "updatedAt": "2024-03-15T09:00:00"
}
```

---

## 7. Chat y Rix AI (P2 — 3 endpoints)

### Componentes afectados
- `DashboardLayout.tsx` — **InternalChatPanel** (chat entre médicos con mensajes hardcodeados), **RixPanel** (asistente IA con historial y chats grupales)

### Estado actual
Todo el chat es **puramente visual** — los mensajes son hardcodeados (`ChatMessage` con nombre, imagen, texto fijo). No hay backend que almacene ni enrute mensajes.

### Endpoints necesarios

#### `WS /ws/chat`
WebSocket para chat interno entre facultativos.

**Mensaje (JSON):**
```json
{
  "type": "message",
  "from": "Carlos López",
  "to": "channel:general",
  "text": "He actualizado la ficha de aislamiento.",
  "timestamp": "2024-03-16T10:15:00"
}
```

**Propósito:** `InternalChatPanel` — chat en tiempo real entre médicos, reemplazar mensajes hardcodeados.

---

#### `WS /ws/rix`
WebSocket para el asistente Rix AI.

**Mensaje (JSON):**
```json
{
  "type": "query",
  "text": "Resume las alertas pendientes del turno",
  "context": { "doctorId": 5 }
}
```

**Respuesta:**
```json
{
  "type": "response",
  "text": "Hay 5 alertas pendientes: 2 por radiación alta, 3 por BPM irregular...",
  "sources": ["patient:101", "treatment:1"]
}
```

**Propósito:** `RixPanel` — asistente IA que conecta contexto de pacientes, tratamientos y alertas.

---

#### `GET /v2/api/chat/history`
Historial de conversaciones recientes del chat interno.

**Propósito:** `RixPanel` lista de "Chats con Rix" y "Chats grupales".

---

## 8. Soporte — Unidades y OAuth (P2 — 4 endpoints)

### `GET /v2/api/units`
Catálogo de unidades de medida.

**Entidad:** `Unit.java` — tabla `units`: `id`, `name`, `symbol`

**Response `200`:**
```json
[
  { "id": 1, "name": "Milicurio", "symbol": "mCi" },
  { "id": 2, "name": "Becquerel", "symbol": "Bq" },
  { "id": 3, "name": "Gray", "symbol": "Gy" },
  { "id": 4, "name": "Sievert", "symbol": "Sv" }
]
```

**Propósito:** Selectores de unidades en formularios de tratamiento.

---

### `GET /v2/api/oauth-clients` / `POST /v2/api/oauth-clients`
Gestión de clientes OAuth para acceso familiar.

**Entidad:** `OAuthClient.java` — tabla `oauth_clients`: `id`, `clientId`, `clientSecret`, `clientName`, `grantType`, `scopes`, `isActive`, `fkUserId`, `expiresAt`

---

## Resumen de Entidades sin API

| Entidad | Tabla | Repositorio | Endpoints necesarios |
|---------|-------|-------------|---------------------|
| `Smartwatch` | `smartwatches` | `SmartwatchRepository` | 5 (P0) |
| `HealthMetrics` | `health_metrics` | `HealthMetricsRepository` | 3 (P1) |
| `RadiationLog` | `radiation_logs` | `RadiationLogRepository` | 2 (P1) |
| `HealthLog` | `health_logs` | `HealthLogRepository` | 1 (P1) |
| `MotivationalMessage` | `motivational_messages` | `MotivationalMessageRepository` | 3 (P2) |
| `GameSession` | `game_sessions` | `GameSessionRepository` | 2 (P2) |
| `Settings` | `settings` | `SettingsRepository` | 2 (P2) |
| `Unit` | `units` | `UnitRepository` | 1 (P2) |
| `OAuthClient` | `oauth_clients` | `OAuthClientRepository` | 2 (P2) |

---

## Problemas de Implementación en Endpoints Existentes

### 1. PatientController — Respuesta incompleta
- **GET /v2/api/patients** y **GET /v2/api/patients/{id}** solo devuelven `{id, fullName}`
- El frontend (`PatientList.tsx`, `PatientDetails.tsx`) espera: `phone`, `address`, `isActive`, `familyAccessCode`, `createdAt`
- **Acción:** Crear `PatientResponse` completo con todos los campos del modelo

### 2. Campo birthDate inexistente
- `PatientDetails.tsx:157` referencia `patient.birthDate`
- El modelo `Patient.java` no tiene este campo
- **Acción:** Añadir campo `birthDate` al modelo Patient o eliminar la referencia del frontend

### 3. UserRegistrationWizard — Campos sin modelo
- `colegiadoNumber` y `specialty` se recogen en el wizard
- El modelo `User.java` no tiene estos campos
- **Acción:** Extender `User` con `licenseNumber` y `specialty`, o crear entidad `DoctorProfile`

---

## 9. iOS App — Endpoints Específicos (P1 — 10 endpoints)

> **Fuente:** Análisis de las 19 pantallas activas de la app iOS (`radix-ios/src/app/`)

### Pantallas que consumen API

| Pantalla iOS | Endpoint Actual | Estado |
|-------------|----------------|--------|
| Login | `POST /v2/api/auth/login` | ✅ Funciona |
| Dashboard | `GET /v2/api/patients` | ⚠️ Respuesta incompleta |
| Settings | `GET /v2/api/patients` | ⚠️ Solo `{id, fullName}` |
| Treatment | Mock `MOCK_TREATMENT` | ❌ Sin endpoint real |
| Alerts | Mock `MOCK_ALERTS` | ❌ Sin endpoint real |
| Health History | Mock + HealthKit local | ❌ Sin endpoint para historial |
| Radiation History | Mock datos generados | ❌ Sin endpoint real |
| Watch | Mock `MOCK_DEVICE` | ❌ Sin endpoint real |
| Family Dashboard | Mock `MOCK_FAMILY_PATIENT` | ❌ Sin endpoint de acceso familiar |
| Personal Info | No guarda en backend | ❌ Sin endpoint PUT |
| Contact Doctor | Sin backend | ❌ Sin endpoint de mensajería |
| Connections | Local SecureStore | ✅ No necesita API |

### Endpoints que necesita la app iOS

#### `GET /v2/api/patients/profile/{userId}` — AMPLIAR RESPUESTA
El endpoint actual devuelve `{id, fullName}`. La app iOS necesita:
- `phone` — Mostrado en perfil y settings
- `address` — Mostrado en perfil
- `isActive` — Estado del paciente
- `familyAccessCode` — Código de acceso familiar (ya en modelo, no en respuesta)
- `fkDoctorId` — ID del médico asignado
- `createdAt` — Fecha de registro

#### `PUT /v2/api/patients/profile/{userId}`
Actualizar datos del perfil del paciente: phone, address, email.
**Uso iOS:** `personal-info.tsx` — formulario de edición de perfil.

#### `GET /v2/api/patients/{patientId}/treatment`
Obtener el tratamiento activo del paciente con datos del isótopo.
**Response:**
```json
{
  "id": 1,
  "isotopeName": "I-131",
  "isotopeSymbol": "I",
  "isotopeHalfLife": 8.02,
  "isotopeHalfLifeUnit": "days",
  "initialDose": 150,
  "safetyThreshold": 200,
  "room": 101,
  "isolationDays": 14,
  "startDate": "2026-04-22",
  "endDate": "2026-05-06",
  "isActive": true
}
```
**Uso iOS:** `treatment.tsx`, dashboard countdown.

#### `GET /v2/api/patients/{patientId}/alerts`
Alertas del paciente con tipo, mensaje, estado.
**Response:** Array de `{id, alertType, message, isResolved, createdAt}`
**Uso iOS:** `alerts.tsx` (reemplazar MOCK_ALERTS).

#### `PUT /v2/api/alerts/{id}/resolve`
Marcar alerta como resuelta.
**Uso iOS:** `alerts.tsx` — toggle pending/resolved.

#### `GET /v2/api/patients/{patientId}/smartwatch`
Dispositivo vinculado al paciente.
**Response:**
```json
{
  "model": "Radix Watch Pro",
  "imei": "RW-2026-00142",
  "batteryPercent": 78,
  "batteryHoursRemaining": 18,
  "bluetoothStatus": "connected",
  "signalStrength": 3,
  "isActive": true
}
```
**Uso iOS:** `watch.tsx` (reemplazar MOCK_DEVICE).

#### `POST /v2/api/patients/{patientId}/messages`
Enviar mensaje al médico desde el paciente.
**Request:** `{subject, message}`
**Uso iOS:** `contact-doctor.tsx`.

#### `GET /v2/api/patients/{patientId}/radiation-history`
Historial de niveles de radiación del paciente.
**Query:** `?days=14`
**Response:** `[{day, radiationLevel, threshold}]`
**Uso iOS:** `radiation-history.tsx` (reemplazar mock de decaimiento).

#### `GET /v2/api/patients/{patientId}/health-metrics`
Historial de métricas de salud.
**Query:** `?days=7`
**Response:** `[{date, bpm, steps, distance}]`
**Uso iOS:** `health-history.tsx`, `health-data.tsx` (complementar HealthKit con datos del smartwatch).

#### `POST /v2/api/family/access`
Validar código de acceso familiar y obtener datos del paciente.
**Request:** `{accessCode: "FAM-ABC12345"}`
**Response:**
```json
{
  "patientName": "María García López",
  "isolationDays": 14,
  "isolationStartDate": "2026-04-22",
  "currentRadiation": 0.08,
  "admissionDate": "2026-04-21"
}
```
**Uso iOS:** `family-login.tsx` + `family-dashboard.tsx` (reemplazar mock).

---

## 10. iOS App — Data Mock Status

Pantallas que actualmente usan datos mock y necesitan endpoints:

| Pantalla | Mock Actual | Endpoint Necesario | Prioridad |
|----------|------------|-------------------|-----------|
| Dashboard | MOCK_TREATMENT, mock health | `GET /patients/{id}/treatment` | P1 |
| Treatment | MOCK_TREATMENT (I-131) | `GET /patients/{id}/treatment` | P1 |
| Alerts | MOCK_ALERTS (6 items) | `GET /patients/{id}/alerts` | P1 |
| Watch | MOCK_DEVICE | `GET /patients/{id}/smartwatch` | P1 |
| Radiation History | generated decay data | `GET /patients/{id}/radiation-history` | P1 |
| Health History | generated random + HealthKit | `GET /patients/{id}/health-metrics` | P2 |
| Family Dashboard | MOCK_FAMILY_PATIENT | `POST /family/access` | P2 |
| Contact Doctor | local state only | `POST /patients/{id}/messages` | P2 |
| Personal Info | local state only | `PUT /patients/profile/{userId}` | P2 |
| Connections | SecureStore | No necesita API | N/A |
| Language | local state | No necesita API | N/A |

---

## 11. Auth — Mejora Necesaria

### `POST /v2/api/auth/login` — Token como número

El endpoint devuelve `"token": 6` (número) para usuarios de base de datos. `expo-secure-store` requiere string. Se parcheó en frontend con `String(response.token)` pero debe corregirse en backend.

**Fix backend:** `AuthController.java:107` → `"token", String.valueOf(u.getId())`

### Hardcoded admin
`AuthController.java:89` — usuario hardcodeado `Radix` / `radixelmejor1`. Debe migrarse a base de datos o eliminarse en producción.

---

## Resumen Final de Endpoints

| # | Método | Endpoint | Prioridad | Consumido por |
|---|--------|----------|-----------|---------------|
| 1 | GET | `/patients/profile/{userId}` | P0 | iOS settings, dashboard |
| 2 | PUT | `/patients/profile/{userId}` | P2 | iOS personal-info |
| 3 | GET | `/patients/{id}/treatment` | P1 | iOS treatment, dashboard |
| 4 | GET | `/patients/{id}/alerts` | P1 | iOS alerts |
| 5 | PUT | `/alerts/{id}/resolve` | P1 | iOS alerts toggle |
| 6 | GET | `/patients/{id}/smartwatch` | P1 | iOS watch |
| 7 | POST | `/patients/{id}/messages` | P2 | iOS contact-doctor |
| 8 | GET | `/patients/{id}/radiation-history` | P1 | iOS radiation-history |
| 9 | GET | `/patients/{id}/health-metrics` | P2 | iOS health-history, health-data |
| 10 | POST | `/family/access` | P2 | iOS family-login, family-dashboard |

---

## 12. Smartwatch App — FHIR Endpoints (P0 — 6 endpoints)

> **Protocolo obligatorio:** HL7 FHIR R4  
> **Documentación completa:** `Watch App - FHIR & Endpoints.md`  
> **Base URL FHIR:** `/v2/fhir`

### Entidad Smartwatch — Campos a añadir

La entidad actual solo tiene: `id`, `fkPatientId`, `imei`, `macAddress`, `model`, `isActive`. Necesita:

| # | Campo | Tipo | Descripción |
|---|-------|------|-------------|
| 1 | `batteryPercent` | INTEGER | Nivel de batería 0-100 |
| 2 | `batteryLifeHours` | INTEGER | Horas restantes |
| 3 | `bluetoothStatus` | VARCHAR | connected/disconnected/pairing |
| 4 | `signalStrength` | INTEGER | 0-4 barras |
| 5 | `firmwareVersion` | VARCHAR | Versión firmware |
| 6 | `chargingStatus` | VARCHAR | charging/discharging/full |
| 7 | `wristDetection` | BOOLEAN | En muñeca |
| 8 | `lastSyncAt` | DATETIME | Última sincronización |
| 9 | `connectionType` | VARCHAR | wifi/cellular/bluetooth |

### FHIR Endpoints

| # | Método | Endpoint FHIR | Prioridad | Descripción |
|---|--------|--------------|-----------|-------------|
| 1 | POST | `/v2/fhir` | **P0** | FHIR Bundle transaction: ingesta de métricas (reemplaza `POST /api/watch/ingest`) |
| 2 | POST | `/v2/fhir/Device` | **P0** | Registrar nuevo smartwatch y vincular a paciente |
| 3 | PUT | `/v2/fhir/Device/{imei}` | **P0** | Actualizar estado del dispositivo (batería, BT, señal, firmware) |
| 4 | GET | `/v2/fhir/Observation?patient={id}&code={LOINC}` | P1 | Historial de observaciones FHIR con filtros |
| 5 | GET | `/v2/fhir/Device?patient={id}` | P1 | Dispositivo vinculado al paciente con estado actual |
| 6 | GET | `/v2/fhir/metadata` | P1 | CapabilityStatement (obligatorio FHIR) |

### Datos que el reloj envía en el FHIR Bundle

**Vital signs (LOINC):**
- Heart rate (`8867-4`), Steps (`55423-8`), Distance (`93824-6`)
- SpO2 (`2708-6`), Body temp (`8310-5`), Respiratory rate (`9279-1`)
- Blood pressure (`85354-9`): Systolic (`8480-6`) + Diastolic (`8462-4`)
- Sleep (`93832-9`), Active energy (`41981-2`), Fall detected (`10182-5`)

**Radiación (custom codes):**
- `RADIATION` — Current radiation level (mSv)
- `DOSERATE` — Radiation dose rate (μSv/h)
- `ACCUMDOSE` — Accumulated dose (mSv)

**Ubicación:**
- GPS coordinates + accuracy + zone status (in_zone/out_of_zone)

**Device status:**
- Battery %, battery life hours, Bluetooth status, signal strength
- Wrist detection, charging status, firmware version

### Dependencias Backend Nuevas

- `pom.xml`: HAPI FHIR R4 (`org.hl7.fhir.r4`)
- `FHIRController.java` — Endpoints FHIR RESTful
- `FHIRParser.java` — Valida/parsea FHIR Bundle → entidades JPA
