# Índice de Endpoints — API RADIX

> **Base URL:** `https://api.raddix.pro/v1`
> **Total:** 66 REST + 3 WebSocket
> **Controladores:** 18 archivos Java

---

## Controladores REST

| # | Controlador | Archivo | Endpoints | Descripción |
|---|-------------|---------|-----------|-------------|
| 1 | AuthController | `AuthController.java` | 4 | Login JWT, OAuth 2.0, registro de médicos y pacientes |
| 2 | PatientController | `PatientController.java` | 6 | CRUD de pacientes + búsqueda por User ID |
| 3 | UserController | `UserController.java` | 5 | CRUD de usuarios + filtro por rol |
| 4 | DoctorController | `DoctorController.java` | 3 | Perfil de facultativos con datos profesionales |
| 5 | SmartwatchController | `SmartwatchController.java` | 6 | Gestión de dispositivos wearable vinculados |
| 6 | TreatmentController | `TreatmentController.java` | 6 | Tratamientos de medicina nuclear |
| 7 | DoctorAlertController | `DoctorAlertController.java` | 4 | Alertas médicas (CRUD + resolver) |
| 8 | WatchDataController | `WatchDataController.java` | 3 | Ingesta de datos desde smartwatch |
| 9 | HealthMetricsController | `HealthMetricsController.java` | 7 | Métricas de salud, logs y radiación |
| 10 | MessageController | `MessageController.java` | 3 | Mensajería motivacional médico-paciente |
| 11 | GameController | `GameController.java` | 2 | Sesiones de juego (gamificación) |
| 12 | SettingsController | `SettingsController.java` | 2 | Preferencias del paciente |
| 13 | IsotopeController | `IsotopeController.java` | 2 | Catálogo de radioisótopos |
| 14 | UnitController | `UnitController.java` | 2 | Catálogo de unidades de medida |
| 15 | OAuthClientController | `OAuthClientController.java` | 2 | Gestión de clientes OAuth |
| 16 | DashboardController | `DashboardController.java` | 1 | Estadísticas agregadas del dashboard |
| 17 | FileController | `FileController.java` | 2 | Subida y descarga de archivos |
| 18 | WebSocketConfig | `WebSocketConfig.java` | 3 | Alertas, chat y Rix AI en tiempo real |

---

## Documentación por controlador

| Archivo | Controlador |
|---------|-------------|
| [AuthController.md](AuthController.md) | Autenticación — Login, OAuth, Registro |
| [PatientController.md](PatientController.md) | Pacientes — CRUD completo |
| [UserController.md](UserController.md) | Usuarios — CRUD completo |
| [DoctorController.md](DoctorController.md) | Facultativos — Datos profesionales |
| [SmartwatchController.md](SmartwatchController.md) | Dispositivos — Vinculación y gestión |
| [TreatmentController.md](TreatmentController.md) | Tratamientos — Medicina nuclear |
| [DoctorAlertController.md](DoctorAlertController.md) | Alertas — Monitoreo y resolución |
| [WatchDataController.md](WatchDataController.md) | Smartwatch — Ingesta de métricas |
| [HealthMetricsController.md](HealthMetricsController.md) | Salud — Métricas y radiación |
| [MessageController.md](MessageController.md) | Mensajería — Comunicación médico-paciente |
| [GameController.md](GameController.md) | Juegos — Gamificación |
| [SettingsController.md](SettingsController.md) | Configuración — Preferencias |
| [IsotopeController.md](IsotopeController.md) | Catálogo — Radioisótopos |
| [UnitController.md](UnitController.md) | Catálogo — Unidades de medida |
| [OAuthClientController.md](OAuthClientController.md) | OAuth — Clientes de acceso |
| [DashboardController.md](DashboardController.md) | Dashboard — Estadísticas |
| [FileController.md](FileController.md) | Archivos — Upload y descarga |
| [WebSocketConfig.md](WebSocketConfig.md) | Tiempo real — Alertas, Chat, Rix AI |

---

## Autenticación

| Método | Descripción |
|--------|-------------|
| JWT HS384 | 24h expiración, claims: `sub`, `role`, `firstName`, `iat`, `exp` |
| BCrypt | Passwords hasheadas con `BCryptPasswordEncoder` |
| Rate Limit | 5 intentos/minuto por email en `/api/auth/login` |
| OAuth 2.0 | Client Credentials para acceso familiar al smartwatch |

---

## Validación de DTOs

| DTO | Validaciones |
|-----|-------------|
| `RegisterRequest` | `@NotBlank` firstName, lastName, email; `@Email` email; `@Size(min=6)` password |
| `SmartwatchRequest` | `@NotNull` fkPatientId; `@NotBlank` imei |
| `MessageRequest` | `@NotNull` fkPatientId; `@NotBlank` messageText |
| `GameSessionRequest` | `@NotNull` fkPatientId, score |
| `HealthMetricsRequest` | `@NotNull` fkPatientId |
| `TreatmentCreateRequest` | `@NotNull` fkPatientId, fkRadioisotopeId, room, initialDose |

---

## Códigos de error HTTP

| Código | Significado | Ejemplo |
|--------|-------------|---------|
| 200 | OK | Operación exitosa |
| 201 | Created | Recurso creado |
| 400 | Bad Request | Campos obligatorios faltantes |
| 401 | Unauthorized | Credenciales inválidas |
| 403 | Forbidden | Rol sin permisos suficientes |
| 404 | Not Found | Recurso no existe |
| 429 | Too Many Requests | Rate limit excedido en login |
| 500 | Internal Server Error | Error del servidor |

Todos los errores usan el formato:
```json
{ "error": "Descripción del error" }
```
