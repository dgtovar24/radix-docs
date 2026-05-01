# RADIX API v2 — Catálogo Completo de Endpoints

> Context path: `/v2` (local) / `/v1` (production, vía `CONTEXT_PATH` env var)
> Frontend proxy: `radix-web/src/pages/api/[...path].ts` forwards `/api/*`
> requests to `${PUBLIC_API_URL}/api/*`. Auth routes keep dedicated session
> handlers for cookie creation.
> Base URL: `https://api.raddix.pro/v1` | Dev: `http://localhost:8080/v2`

---

## Resumen

| Área | Endpoints | Controlador |
|------|-----------|-------------|
| Auth | 4 | `AuthController.java` |
| Patients | 6 | `PatientController.java` |
| Users | 5 | `UserController.java` |
| Doctors | 3 | `DoctorController.java` |
| Smartwatches | 6 | `SmartwatchController.java` |
| Treatments | 6 | `TreatmentController.java` |
| Alerts | 4 | `DoctorAlertController.java` |
| Watch/Smartwatch Data | 3 | `WatchDataController.java` |
| Health Metrics | 7 | `HealthMetricsController.java` |
| Messages | 3 | `MessageController.java` |
| Game Sessions | 2 | `GameController.java` |
| Settings | 2 | `SettingsController.java` |
| Isotopes | 2 | `IsotopeController.java` |
| Units | 2 | `UnitController.java` |
| OAuth Clients | 2 | `OAuthClientController.java` |
| Dashboard | 1 | `DashboardController.java` |
| Files/Upload | 2 | `FileController.java` |
| System | 2 | `HealthController`, `DocsController` |
| WebSocket | 3 | `WebSocketConfig.java` |
| **Total REST** | **66** | |
| **Total WS** | **3** | |

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

**Frontend usage:** `UsuariosList.tsx`, `ProfilePage`, `api.ts`.

---

### `GET /v2/api/users/role/{role}`
Filtra usuarios por rol (`Doctor`, `Patient`, `Admin`).

**Response `200`:** Mismo formato que `GET /users`.

**Frontend usage:** `api.ts`.

### `GET /v2/api/users/{id}`
Obtiene un usuario por ID. Lo usa `/mi-perfil` para cargar la información
editable del usuario conectado.

### `PUT /v2/api/users/{id}`
Actualiza datos de usuario. El frontend lo usa para editar perfil y resetear
contraseña desde `/mi-perfil`.

**Request Body parcial:**
```json
{
  "firstName": "Admin",
  "lastName": "Radix",
  "email": "admin@radix.pro",
  "phone": "+34 600 000 000",
  "licenseNumber": "COL-12345",
  "specialty": "Medicina nuclear",
  "password": "new-secure-password"
}
```

### `DELETE /v2/api/users/{id}`
Elimina un usuario. La pantalla `/mi-perfil` no expone esta acción para evitar
el borrado de la propia cuenta.

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

**Frontend usage:** `radix-web/src/services/api.ts` y `DashboardWidgets.tsx` consumen este endpoint mediante el proxy local `/api/dashboard/stats`.

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

### `WS /ws/chat`
Chat interno entre facultativos.

**Protocolo:** `ws://` (dev) / `wss://` (production)

**Mensaje enviado (JSON):**
```json
{
  "from": "Carlos López",
  "text": "He actualizado la ficha de aislamiento."
}
```

**Mensaje recibido (JSON):**
```json
{
  "type": "message",
  "from": "Carlos López",
  "text": "He actualizado la ficha de aislamiento.",
  "timestamp": "2024-03-16T10:15:00"
}
```

**Controlador:** `ChatWebSocketHandler.java`

---

### Chat interno REST pendiente

Estos endpoints están documentados porque el frontend ya los consume mediante
`internalChat` en `radix-web/src/services/api.ts`; si el backend no responde, la
UI muestra estado vacío.

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/v2/api/internal-chat/users` | Directorio de usuarios para iniciar chats. |
| `GET` | `/v2/api/internal-chat/conversations?type=` | Lista de chats directos o grupales. |
| `GET` | `/v2/api/internal-chat/conversations/{id}/messages` | Mensajes de una conversación interna. |
| `POST` | `/v2/api/internal-chat/conversations/{id}/messages` | Enviar mensaje interno. |

---

### `WS /ws/rix`
Asistente Rix AI para consultas clínicas.

**Mensaje enviado (JSON):**
```json
{
  "text": "Resume las alertas pendientes del turno"
}
```

**Mensaje recibido (JSON):**
```json
{
  "type": "response",
  "text": "Rix ha recibido tu consulta: \"Resume las alertas pendientes del turno\". Conectando con el contexto clínico...",
  "timestamp": "2024-03-16T10:15:00"
}
```

**Controlador:** `RixWebSocketHandler.java`

---

### Rix REST pendiente

Estos endpoints están documentados porque el frontend ya los consume mediante
`rix` en `radix-web/src/services/api.ts`; si el backend no responde, la UI
muestra estado vacío.

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/v2/api/rix/conversations` | Historial de conversaciones con Rix. |
| `GET` | `/v2/api/rix/group-conversations` | Sesiones grupales compartidas con médicos. |
| `GET` | `/v2/api/rix/doctors` | Médicos invitables a chats grupales. |
| `POST` | `/v2/api/rix/messages` | Enviar prompt a Rix con invitados opcionales. |

---

## 11. Smartwatches — `SmartwatchController.java`

### `POST /v2/api/smartwatches`
Vincular un smartwatch a un paciente.

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
  "imei": "35928108492011",
  "macAddress": "00:1B:44:11:3A:B7",
  "model": "RadixWatch Pro v2",
  "isActive": true,
  "patientId": 101,
  "patientName": "María González"
}
```

### `GET /v2/api/smartwatches`
Lista todos los smartwatches.

### `GET /v2/api/smartwatches/{id}`
Detalle de un smartwatch.

### `GET /v2/api/smartwatches/patient/{patientId}`
Smartwatches vinculados a un paciente.

### `PUT /v2/api/smartwatches/{id}`
Actualizar datos del dispositivo.

### `DELETE /v2/api/smartwatches/{id}`
Desactivar smartwatch.

**Servicio:** `SmartwatchService.java`

---

## 12. Doctors — `DoctorController.java`

### `GET /v2/api/doctors`
Lista doctores con datos profesionales.

**Response:**
```json
[
  {
    "id": 5,
    "firstName": "Carlos",
    "lastName": "López",
    "email": "carlos@clinica.es",
    "phone": "+34 600 000 000",
    "role": "Doctor",
    "licenseNumber": "282865432",
    "specialty": "Medicina Nuclear",
    "createdAt": "2024-01-15T10:30:00"
  }
]
```

### `GET /v2/api/doctors/{id}`
Perfil de doctor por ID.

### `PUT /v2/api/doctors/{id}`
Actualizar datos profesionales.

---

## 13. Health Metrics — `HealthMetricsController.java`

### `GET /v2/api/health-metrics/patient/{patientId}?days=7`
Métricas de salud del paciente: BPM, pasos, distancia, radiación.

### `GET /v2/api/health-metrics/patient/{patientId}/latest`
Última métrica registrada del paciente.

### `GET /v2/api/health-metrics/treatment/{treatmentId}`
Métricas por tratamiento.

### `POST /v2/api/health-metrics`
Ingesta batch de métricas.

**Request Body:**
```json
{
  "fkPatientId": 101,
  "fkTreatmentId": 1,
  "bpm": 72,
  "steps": 4500,
  "distance": 3.2,
  "currentRadiation": 12.5
}
```

### `GET /v2/api/health-logs/patient/{patientId}?days=30`
Logs de salud sin procesar.

### `GET /v2/api/radiation-logs/patient/{patientId}?days=7`
Historial de radiación del paciente.

### `GET /v2/api/radiation-logs/treatment/{treatmentId}`
Radiación por tratamiento.

**Servicio:** `HealthMetricsService.java`

---

## 14. Messages — `MessageController.java`

### `GET /v2/api/messages/patient/{patientId}`
Mensajes de un paciente.

### `POST /v2/api/messages`
Enviar mensaje a un paciente.

**Request Body:**
```json
{
  "fkPatientId": 101,
  "messageText": "Recuerda tu cita de control mañana a las 10:00."
}
```

### `PUT /v2/api/messages/{id}/read`
Marcar mensaje como leído.

---

## 15. Game Sessions — `GameController.java`

### `GET /v2/api/games/patient/{patientId}`
Sesiones de juego del paciente.

### `POST /v2/api/games`
Registrar sesión de juego.

---

## 16. Settings — `SettingsController.java`

### `GET /v2/api/settings/patient/{patientId}`
Preferencias del paciente.

### `PUT /v2/api/settings/patient/{patientId}`
Actualizar preferencias (unitPreference, theme, notificationsEnabled).

---

## 17. Units — `UnitController.java`

### `GET /v2/api/units`
Catálogo de unidades de medida.

### `GET /v2/api/units/{id}`
Una unidad.

---

## 18. OAuth Clients — `OAuthClientController.java`

### `GET /v2/api/oauth-clients`
Listar clientes OAuth. La sección **Configuración > Credenciales API** usa este
endpoint para mostrar los clientes existentes.

### `POST /v2/api/oauth-clients`
Crear nuevo cliente OAuth.

**Request Body:**
```json
{
  "clientId": "radix_xxxxxxxx",
  "clientSecret": "secret",
  "clientName": "Integración clínica",
  "grantType": "client_credentials",
  "scopes": "patients:read treatments:read alerts:write settings:write"
}
```

Para generar token se usa `POST /v2/api/auth/token` con las mismas
credenciales.

---

## Patients — Endpoints nuevos

### `PUT /v2/api/patients/{id}`
Actualizar datos del paciente (phone, address, familyAccessCode, isActive).

### `DELETE /v2/api/patients/{id}`
Desactivar paciente (soft delete).

**Response:** `PatientResponse` ahora incluye `phone`, `address`, `isActive`, `familyAccessCode`, `fkUserId`, `fkDoctorId`, `createdAt`.

---

## 19. Files/Upload — `FileController.java`

### `POST /v1/api/upload`
Subida de archivos (imágenes, PDFs). Acepta `multipart/form-data`.

**Request:** `multipart/form-data` con campo `file`

**Response `201`:**
```json
{
  "url": "/api/files/a1b2c3d4.jpg",
  "filename": "a1b2c3d4.jpg",
  "originalName": "radiografia.jpg",
  "size": 245760
}
```

**Límite:** 50MB por archivo. Archivos guardados en `/home/ubuntu/radix-uploads/` con UUID como nombre.

### `GET /v1/api/files/{filename}`
Sirve archivos subidos. Content-Type detectado automáticamente.

**Response `200`:** El archivo binario con headers Content-Type y Content-Disposition apropiados.

**Componente frontend:** `FileUpload.tsx` — drag & drop + click, preview de imágenes.

---

## Notas de Implementación

1. **PatientResponse ampliado:** Ahora incluye todos los campos del modelo: `phone`, `address`, `isActive`, `familyAccessCode`, `fkUserId`, `fkDoctorId`, `createdAt`.

2. **User model extendido:** Añadidos `phone`, `licenseNumber` y `specialty`.

3. **Upload de archivos:** `FileController` con volumen Docker montado en `/home/ubuntu/radix-uploads/`.

4. **35 endpoints implementados:** De los 35 endpoints faltantes, todos han sido implementados (Fases 1-5).

5. **Dominio producción:** API en `https://api.raddix.pro/v1` (context-path `/v1`). Web en `https://aiflex.dev`.

6. **Entidades con API:** Las 14 entidades JPA tienen al menos un endpoint REST.
