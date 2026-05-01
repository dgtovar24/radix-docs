# RADIX — Next Steps (P1 y P2)

> **Fecha:** Mayo 2026
> **P0 completado:** BCrypt + JWT + eliminación de admin hardcodeado + limpieza de credenciales

---

## P1 — Funcionalidad (Alta Prioridad)

### P1-1: iOS — Sincronizar HealthKit con el backend
**Archivos:** `radix-ios/src/hooks/useHealthKit.ts`, `radix-ios/src/services/healthKit.ts`
**Problema:** HealthKit lee datos de Apple Health localmente pero nunca los envía al backend.
**Solución:** Añadir un `setInterval` cada 5 minutos que haga `POST /api/watch/ingest` con `bpm`, `steps`, `distance` y el IMEI del smartwatch registrado del paciente.
**Impacto:** App iOS deja de usar datos solo locales y alimenta la BD de producción.

### P1-2: iOS — Notificaciones Push
**Archivos:** `radix-ios/src/app/_layout.tsx`, nuevo `radix-ios/src/hooks/useNotifications.ts`
**Problema:** `app.json` tiene permisos de notificaciones pero no hay código que las implemente.
**Solución:** 
1. Registrar listener `Notifications.addNotificationReceivedListener()` en `_layout.tsx`
2. Obtener push token con `Notifications.getExpoPushTokenAsync()` y guardarlo en SecureStore
3. Navegar a la pantalla de alertas al recibir una notificación

### P1-3: iOS — Consolidar pantallas duplicadas
**Archivos:** `radix-ios/src/app/dashboard.tsx`, `radix-ios/src/app/alerts.tsx`
**Problema:** Existen dos dashboards (`dashboard.tsx` viejo con mock data y `(tabs)/index.tsx` nuevo con API) y dos pantallas de alertas (misma situación).
**Solución:** Eliminar `dashboard.tsx`, `alerts.tsx`, `health.tsx`, `treatment.tsx`, `settings.tsx`, `profile.tsx` (las viejas en `src/app/` raíz sin tabs). Mantener solo `(tabs)/`.

### P1-4: Web — Migrar dominio a raddix.pro
**Archivos:** `radix-web/.github/workflows/deploy.yml`, Traefik config dinámica
**Problema:** El frontend se sirve en `aiflex.dev` pero debe estar en `raddix.pro`.
**Solución:**
1. Actualizar labels Traefik en `deploy.yml`: `Host(raddix.pro) || Host(www.raddix.pro)`
2. Configurar DNS en dondominio: A record `@` → `132.145.194.97`, CNAME `www` → `raddix.pro`
3. Actualizar Traefik dynamic config en el servidor

### P1-5: Web — Conectar Chat y Rix a WebSocket real
**Archivos:** `DashboardLayout.tsx`, `InternalChatPanel`, `RixPanel`
**Problema:** Los mensajes del chat interno y Rix AI están hardcodeados.
**Solución:**
1. `InternalChatPanel` → conectar a `WS /ws/chat` (ya implementado en backend)
2. `RixPanel` → conectar a `WS /ws/rix` (ya implementado como eco simple)

### P1-6: Web — Limpiar API client de endpoints fantasma
**Archivos:** `radix-web/src/services/api.ts`
**Problema:** El cliente tiene funciones para `internalChat`, `rix`, `systemSettings` que no existen en el backend.
**Solución:** Eliminar esos stubs o marcarlos como `// TODO: implementar backend`.

---

## P2 — Calidad (Media Prioridad)

### P2-1: Tests de integración para cada controller
**Estado:** 11 tests para 66 endpoints.
**Plan:** Crear 1 test por controller (mínimo) usando `@WebMvcTest` + `MockMvc`. Prioridad: AuthController, PatientController, TreatmentController, AlertController.

### P2-2: Validación de DTOs con `@Valid`
**Archivos:** Todos los DTOs y controllers
**Problema:** Solo `TreatmentCreateRequest` usa `@Valid`. Registro de usuarios acepta campos vacíos sin error.
**Solución:** Añadir `@NotBlank`/`@Email`/`@NotNull` a `RegisterRequest`, `LoginRequest`, `SmartwatchRequest`, `MessageRequest`, etc. Usar `@Valid @RequestBody` en todos los controllers.

### P2-3: Rate limiting en login
**Problema:** Sin protección anti brute-force.
**Solución:** Añadir rate limiter con `Bucket4j` o un contador simple en memoria: 5 intentos/minuto por IP.

### P2-4: Actualizar AGENTS.md interno de radix-api
**Archivo:** `radix-api/AGENTS.md`
**Problema:** Dice que solo existen 3 endpoints. La realidad son 66+.
**Solución:** Actualizar con la tabla completa de endpoints y comandos actualizados.

### P2-5: iOS — Background sync de HealthKit
**Archivos:** Nuevo `radix-ios/src/tasks/backgroundFetch.ts`
**Problema:** `app.json` tiene `UIBackgroundModes: ["fetch"]` pero sin implementación.
**Solución:** Usar `expo-task-manager` + `expo-background-fetch` para sincronizar HealthKit periódicamente en background.

### P2-6: Audit log de logins fallidos
**Archivo:** `AuthController.java`
**Problema:** Sin registro de intentos de login fallidos.
**Solución:** Añadir `log.warn("Failed login attempt for email: {}", email)` en el catch de autenticación.

### P2-7: Eliminar `schema.sql` obsoleto
**Archivo:** `radix-api/src/main/resources/schema.sql`
**Problema:** Spring Boot intenta ejecutarlo al arrancar y falla (ya se desactivó con `spring.sql.init.mode=never`). Mejor eliminarlo o renombrarlo a `schema.sql.bak`.
