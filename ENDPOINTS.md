# RADIX API v2 — Catálogo Completo de Endpoints

> Context path: `/v2` (local) / `/v1` (production, vía `CONTEXT_PATH` env var)
> Frontend proxy: `radix-web/src/pages/api/auth/*.ts` → `${PUBLIC_API_URL}/...`
> Base URL frontend: `https://api.raddix.pro/v2` | Dev: `http://localhost:8080/v2`

---

## Resumen

| Área | Endpoints | Controlador |
|------|-----------|-------------|
| Auth | 4 | `AuthController.java` |
| Patients | 4 | `PatientController.java` |
| Users | 2 | `UserController.java` |
| Treatments | 6 | `TreatmentController.java` |
| Alerts | 4 | `DoctorAlertController.java` |
| Watch/Smartwatch | 3 | `WatchDataController.java` |
| Isotopes | 2 | `IsotopeController.java` |
| Dashboard | 1 | `DashboardController.java` |
| System | 2 | `HealthController`, `DocsController` |
| WebSocket | 1 | `WebSocketConfig.java` |
| **Total REST** | **29** | |

---

## 1. Auth — `AuthController.java`

### `POST /v2/api/auth/login`
Inicia sesión con email/password. No requiere autenticación previa.

**Request Body:**
```json
{
  "email": "doctor@clinica.es",
  "password": "••••••••"
}
```

**Response `200`:**
```json
{
  "token": "abc123...",
  "id": 5,
  "firstName": "Carlos",
  "role": "Doctor"
}
```

**Response `401`:** `{"error": "Invalid credentials"}`

**Frontend usage:** `LoginForm.tsx` → `api.ts:42` → `pages/api/auth/login.ts:47`

---

### `POST /v2/api/auth/token`
OAuth 2.0 token endpoint para acceso de familiares/pacientes vía smartwatch.

**Request Body:**
```json
{
  "grantType": "family_access",
  "clientId": "RADIX-FAM-XXXX",
  "clientSecret": "secret",
  "scope": "watch:read"
}
```

**Response `200`:**
```json
{
  "accessToken": "fam_token...",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "scope": "watch:read",
  "patientId": 101,
  "patientName": "María González",
  "familyAccessCode": "RADIX-FAM-XXXX"
}
```

**Frontend usage:** No direct frontend usage actualmente (diseñado para app móvil/familiar).

---

### `POST /v2/api/auth/register/doctor`
**Requiere:** `Authorization: Bearer <ADMIN_TOKEN>`

Registra un nuevo médico/facultativo en el sistema.

**Request Body:**
```json
{
  "firstName": "Carlos",
  "lastName": "López",
  "email": "carlos@clinica.es",
  "password": "secure123"
}
```

**Response `200`:**
```json
{
  "message": "Doctor registered successfully",
  "id": 6
}
```

**Frontend usage:** `RegisterForm.tsx` (Admin role) → `api.ts:47` → `pages/api/auth/register.ts:47`

---

### `POST /v2/api/auth/register/patient`
**Requiere:** `Authorization: Bearer <DOCTOR_TOKEN>`

Registra un nuevo paciente. Crea tanto el `User` como el `Patient`.

**Request Body:**
```json
{
  "firstName": "María",
  "lastName": "García",
  "email": "maria@email.com",
  "password": "secure123",
  "phone": "+34 612 345 678",
  "address": "Calle Mayor 123"
}
```

**Response `200`:**
```json
{
  "message": "Patient registered successfully",
  "id": 9
}
```

**Frontend usage:** `RegisterForm.tsx` (Doctor role) → `api.ts:58` → `pages/api/auth/register.ts:50`

---

## 2. Patients — `PatientController.java`

### `GET /v2/api/patients`
Lista todos los pacientes activos.

**Response `200`:**
```json
[
  { "id": 101, "fullName": "María González" },
  { "id": 102, "fullName": "Juan Pérez" }
]
```

> ⚠️ **Limitación:** Solo devuelve `id` y `fullName`. El frontend espera también `phone`, `address`, `isActive`, `familyAccessCode`, `createdAt`. Ver `PatientList.tsx`.

**Frontend usage:** `PatientList.tsx:19` → `api.ts:74`, `PatientDetails.tsx:52`

---

### `GET /v2/api/patients/{id}`
Obtiene un paciente por su ID interno.

**Response `200`:**
```json
{ "id": 101, "fullName": "María González" }
```

**Response `404`:** `{"error": "Patient not found"}`

> ⚠️ **Limitación:** Misma limitación que el endpoint de lista. `PatientDetails.tsx:157` referencia `patient.birthDate` pero el modelo no tiene ese campo.

**Frontend usage:** `api.ts:76`

---

### `GET /v2/api/patients/profile/{userId}`
Obtiene el perfil de paciente asociado a un User ID.

**Response `200`:**
```json
{ "id": 101, "fullName": "María González" }
```

**Response `404`:** `{"error": "Patient not found"}`

**Frontend usage:** `api.ts:79`

---

### `POST /v2/api/patients/register`
Endpoint legacy/alternativo para registrar paciente + usuario.

**Request Body:**
```json
{
  "firstName": "María",
  "lastName": "García",
  "email": "maria@email.com",
  "password": "secure123",
  "doctorId": 5,
  "phone": "+34 612 345 678",
  "address": "Calle Mayor 123"
}
```

**Response `200`:**
```json
{
  "message": "Patient registered successfully",
  "userId": 9
}
```

**Frontend usage:** `PatientForm.tsx:33` → `api.ts:82`

---

## 3. Users — `UserController.java`

### `GET /v2/api/users`
Lista todos los usuarios registrados.

**Response `200`:**
```json
[
  {
    "id": 1,
    "firstName": "Admin",
    "lastName": "Radix",
    "email": "admin@radix.pro",
    "role": "Admin",
    "createdAt": "2024-01-15T10:30:00"
  }
]
```

**Frontend usage:** `UsuariosList.tsx:26` (llamada directa a backend), `api.ts:98`

---

### `GET /v2/api/users/role/{role}`
Filtra usuarios por rol (`Doctor`, `Patient`, `Admin`).

**Response `200`:** Mismo formato que `GET /users`.

**Frontend usage:** `FacultativosList.tsx:26` (llamada directa), `api.ts:101`

---

## 4. Treatments — `TreatmentController.java`

### `GET /v2/api/treatments`
Lista todos los tratamientos.

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientName": "María González",
    "patientId": 101,
    "doctorName": "Carlos López",
    "doctorId": 5,
    "isotopeName": "Yodo-131",
    "isotopeId": 1,
    "room": 402,
    "initialDose": 150.0,
    "safetyThreshold": 15.0,
    "isolationDays": 80,
    "startDate": "2024-03-15T09:00:00",
    "endDate": null,
    "isActive": true,
    "currentRadiation": 45.2
  }
]
```

**Frontend usage:** `TreatmentList.tsx:19` → `api.ts:107`

---

### `GET /v2/api/treatments/active`
Lista solo tratamientos activos (`isActive = true`).

**Response `200`:** Mismo formato que `GET /treatments`.

**Frontend usage:** `api.ts:109`

---

### `GET /v2/api/treatments/{id}`
Obtiene un tratamiento por ID.

**Response `200`:** Objeto `TreatmentResponse`.

**Response `404`:** `{"error": "Treatment not found"}`

**Frontend usage:** `api.ts:111`

---

### `GET /v2/api/treatments/patient/{patientId}`
Tratamientos de un paciente específico.

**Response `200`:** `List<TreatmentResponse>`

**Frontend usage:** `api.ts:114`

---

### `POST /v2/api/treatments`
**Requiere:** `Authorization: Bearer <token>`

Crea un nuevo tratamiento de medicina nuclear.

**Request Body:**
```json
{
  "fkPatientId": 101,
  "fkRadioisotopeId": 1,
  "fkSmartwatchId": 3,
  "room": 402,
  "initialDose": 150.0
}
```

**Response `200`:** `TreatmentResponse` con datos calculados (`isolationDays`, `safetyThreshold`).

**Frontend usage:** `TreatmentForm.tsx:56` → `api.ts:117`

---

### `POST /v2/api/treatments/{id}/end`
Finaliza un tratamiento activo (establece `endDate` y `isActive = false`).

**Response `200`:** `TreatmentResponse` actualizado.

**Response `404`:** `{"error": "Treatment not found"}`

**Frontend usage:** `api.ts:129`

---

## 5. Alerts — `DoctorAlertController.java`

### `GET /v2/api/alerts`
Lista todas las alertas.

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientName": "María González",
    "patientId": 101,
    "treatmentId": 1,
    "alertType": "RADIATION_HIGH",
    "message": "Nivel de radiación supera el umbral de seguridad",
    "isResolved": false,
    "createdAt": "2024-03-16T14:30:00"
  }
]
```

**Frontend usage:** `AlertList.tsx:25` → `api.ts:146`

---

### `GET /v2/api/alerts/pending`
Alertas no resueltas (`isResolved = false`).

**Response `200`:** `List<AlertResponse>`

**Frontend usage:** `AlertList.tsx:24` → `api.ts:148`

---

### `GET /v2/api/alerts/patient/{patientId}`
Alertas de un paciente específico.

**Response `200`:** `List<AlertResponse>`

**Frontend usage:** `AlertList.tsx:22` → `api.ts:150`

---

### `PUT /v2/api/alerts/{id}/resolve`
Marca una alerta como resuelta.

**Response `200`:** `AlertResponse` con `isResolved: true`.

**Response `404`:** `{"error": "Alert not found"}`

**Frontend usage:** `AlertList.tsx:86` → `api.ts:153`

---

## 6. Watch/Smartwatch — `WatchDataController.java`

### `POST /v2/api/watch/ingest`
**Requiere (opcional):** `Authorization: Bearer <token>`

Ingesta de datos desde smartwatch (IMEI + métricas).

**Request Body:**
```json
{
  "imei": "35928108492011",
  "familyAccessCode": "RADIX-FAM-XXXX",
  "bpm": 72,
  "steps": 4500,
  "distance": 3.2,
  "currentRadiation": 12.5,
  "recordedAt": "2024-03-15T14:30:00"
}
```

**Response `200`:**
```json
{ "status": "received" }
```

**Frontend usage:** No usado directamente por el frontend (diseñado para smartwatch/app familiar).

---

### `GET /v2/api/watch/{imei}/metrics`
Historial de métricas de un smartwatch por IMEI.

**Response `200`:**
```json
[
  {
    "id": 1,
    "patientId": 101,
    "imei": "35928108492011",
    "bpm": 72,
    "steps": 4500,
    "distance": 3.2,
    "currentRadiation": 12.5,
    "recordedAt": "2024-03-15T14:30:00"
  }
]
```

**Frontend usage:** `api.ts:140`

---

### `GET /v2/api/watch/patient/{patientId}/latest`
Última métrica registrada de un paciente.

**Response `200`:** `WatchMetricsResponse`

**Response `404`:** `{"error": "No metrics found"}`

**Frontend usage:** `api.ts:137`

---

## 7. Isotopes — `IsotopeController.java`

### `GET /v2/api/isotopes`
Catálogo completo de radioisótopos.

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

**Frontend usage:** `TreatmentForm.tsx:29`, `ConfinementCalculator.tsx:16` → `api.ts:161`

---

### `GET /v2/api/isotopes/{id}`
Obtiene un isótopo por ID.

**Response `200`:** `IsotopeResponse`

**Response `404`:** `{"error": "Isotope not found"}`

**Frontend usage:** `ConfinementCalculator.tsx:16` → `api.ts:163`

---

## 8. Dashboard — `DashboardController.java`

### `GET /v2/api/dashboard/stats`
Estadísticas agregadas para el dashboard principal.

**Response `200`:**
```json
{
  "totalPatients": 142,
  "totalDoctors": 12,
  "activeTreatments": 38,
  "pendingAlerts": 5,
  "totalSmartwatches": 150,
  "activeIsotopes": 4
}
```

**Frontend usage:** `api.ts:169` (referenciado pero `DashboardWidgets.tsx` actualmente usa `MOCK_STATS`).

---

## 9. Sistema

### `GET /v2/` — `HealthController.java`
Health check y metadata del sistema.

```json
{
  "name": "RADIX API",
  "version": "v2.0",
  "description": "Nuclear Medicine Treatment Management System",
  "status": "operational",
  "timestamp": "2024-03-15T10:30:00",
  "docs": "/v2/docs",
  "endpoints": [...]
}
```

---

### `GET /v2/docs` — `DocsController.java`
Documentación autodescriptiva de la API en JSON.

---

## 10. WebSocket

### `WS /ws/alerts`
Conexión WebSocket para recibir alertas en tiempo real.

**Protocolo:** `ws://` (dev) / `wss://` (production)

**Mensaje recibido (JSON):**
```json
{
  "id": 25,
  "patientName": "María González",
  "patientId": 101,
  "treatmentId": 1,
  "alertType": "RADIATION_HIGH",
  "message": "Nivel de radiación crítico detectado",
  "isResolved": false,
  "createdAt": "2024-03-16T15:00:00"
}
```

**Frontend usage:** `AlertList.tsx:41`, `useWebSocketAlerts.ts:41`

---

## Notas de Implementación

1. **PatientController incompleto:** Solo devuelve `{id, fullName}`. El frontend (`PatientList.tsx`) espera `phone`, `address`, `isActive`, `familyAccessCode`, `createdAt`. El modelo `Patient.java` tiene estos campos pero el controlador no los expone.

2. **Campos inexistentes en frontend:** `PatientDetails.tsx:157` referencia `patient.birthDate` pero el modelo `Patient` no tiene ese campo.

3. **AlertRepository duplicado:** `AlertRepository` y `DoctorAlertRepository` apuntan ambos a `DoctorAlert`. Solo `DoctorAlertRepository` se usa en producción.

4. **Campos de doctor:** `UserRegistrationWizard.tsx` recoge `colegiadoNumber` y `specialty` que no existen en el modelo `User` ni en el backend.

5. **apiScheme.json desactualizado:** Solo documenta 7 endpoints. Ver archivo corregido en `radix-web/apiScheme.json`.

6. **Dockerfile HEALTHCHECK:** Usa `/v1/actuator/health` pero el context-path es `/v2`.

7. **Entidades sin controlador:** `HealthLog`, `RadiationLog`, `GameSession`, `MotivationalMessage`, `Settings`, `Unit`, `Smartwatch` — tienen modelo JPA + repositorio pero **cero endpoints HTTP**. Ver `MISSING_ENDPOINTS.md`.
