# WebSocketConfig

> **Package:** `com.project.radix.Config.WebSocketConfig`
> **Endpoints WebSocket:** 3
> **Protocolo:** `ws://` (desarrollo) / `wss://` (producción)

---

## Descripción general

Tres canales WebSocket independientes para comunicación en tiempo real:

| Ruta | Handler | Propósito |
|------|---------|-----------|
| `/ws/alerts` | `DoctorAlertWebSocketHandler` | Alertas médicas push a doctores |
| `/ws/chat` | `ChatWebSocketHandler` | Chat interno entre facultativos |
| `/ws/rix` | `RixWebSocketHandler` | Asistente IA para consultas clínicas |

**Configuración de conexión:**
```
wss://api.raddix.pro/ws/alerts
wss://api.raddix.pro/ws/chat
wss://api.raddix.pro/ws/rix
```

**En desarrollo local:**
```
ws://localhost:8080/v2/ws/alerts
```

**CORS:** `setAllowedOrigins("*")` — todos los orígenes permitidos.

---

## WS /ws/alerts — Alertas en tiempo real

**Handler:** `DoctorAlertWebSocketHandler` + `WebSocketNotificationService`

**Funcionamiento:**
1. El servidor mantiene un `Set<WebSocketSession>` de clientes conectados
2. Cuando `WatchDataService` detecta radiación > umbral, llama a `AlertService.createRadiationAlert()`
3. `AlertService` crea la alerta en BD y llama a `WebSocketNotificationService.broadcastAlert()`
4. Se envía el objeto `Alert` serializado a JSON a todos los clientes conectados

**Mensaje recibido (servidor → cliente):**
```json
{
  "id": 25,
  "patientName": "Ana García",
  "patientId": 1,
  "treatmentId": 1,
  "alertType": "RADIATION_HIGH",
  "message": "Nivel de radiación crítico detectado: 18.5 mSv",
  "isResolved": false,
  "createdAt": "2026-05-01T15:00:00"
}
```

**Cliente no envía mensajes:** `handleTextMessage` es un no-op (solo broadcast servidor→cliente).

**Reconexión:** El frontend (`AlertList.tsx`) implementa reconexión automática cada 5 segundos y polling de respaldo cada 30 segundos vía API REST.

---

## WS /ws/chat — Chat interno entre facultativos

**Handler:** `ChatWebSocketHandler`

**Funcionamiento:**
1. El servidor mantiene un `Set<WebSocketSession>` de médicos conectados
2. Cuando un médico envía un mensaje, se hace broadcast a todos los conectados
3. Los mensajes incluyen `from` (nombre del remitente), `text` y `timestamp`

**Enviar mensaje (cliente → servidor):**
```json
{
  "from": "Elena Ruiz",
  "text": "He actualizado la ficha de aislamiento del paciente 1. Revisad la dosis."
}
```

**Recibir mensaje (servidor → cliente):**
```json
{
  "type": "message",
  "from": "Elena Ruiz",
  "text": "He actualizado la ficha de aislamiento del paciente 1. Revisad la dosis.",
  "timestamp": "2026-05-01T15:00:00"
}
```

**Integración frontend:** `DashboardLayout.tsx` → `InternalChatPanel` → `useWebSocketChat()` hook.

---

## WS /ws/rix — Asistente Rix AI

**Handler:** `RixWebSocketHandler`

**Funcionamiento:**
1. El servidor mantiene un `Set<WebSocketSession>` de usuarios conectados
2. El cliente envía consultas clínicas en lenguaje natural
3. El servidor responde con eco contextual (la IA procesa la consulta y devuelve información relevante)

**Enviar consulta (cliente → servidor):**
```json
{
  "text": "Resume las alertas pendientes del turno y recomienda prioridades",
  "context": { "doctorId": 2 }
}
```

**Recibir respuesta (servidor → cliente):**
```json
{
  "type": "response",
  "text": "Rix ha recibido tu consulta: \"Resume las alertas pendientes...\". Conectando con el contexto clínico...",
  "timestamp": "2026-05-01T15:00:00"
}
```

**Integración frontend:** `DashboardLayout.tsx` → `RixPanel` → `useWebSocketRix()` hook.

---

## Notas de implementación

**Spring Boot configuración:**
```java
@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(alertHandler, "/ws/alerts").setAllowedOrigins("*");
        registry.addHandler(chatHandler, "/ws/chat").setAllowedOrigins("*");
        registry.addHandler(rixHandler, "/ws/rix").setAllowedOrigins("*");
    }
}
```

**Dependencia Maven:** `spring-boot-starter-websocket`

**Serialización:** Todos los handlers usan `com.fasterxml.jackson.databind.ObjectMapper` para serializar/deserializar mensajes JSON.

**Gestión de sesiones:**
- `WebSocketNotificationService` (alerts): `ConcurrentHashMap.newKeySet()`
- `ChatWebSocketHandler` (chat): `ConcurrentHashMap.newKeySet()`
- `RixWebSocketHandler` (rix): `ConcurrentHashMap.newKeySet()`

**Seguridad:** Actualmente sin autenticación en WebSocket. Los mensajes de chat y rix se transmiten a todos los clientes conectados. Se recomienda añadir validación de token JWT en el handshake para producción.
