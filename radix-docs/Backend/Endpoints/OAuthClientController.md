# OAuthClientController

> **Package:** `com.project.radix.Controller.OAuthClientController`
> **Ruta base:** `/api/oauth-clients`
> **Endpoints:** 2

---

## Descripción general

Gestiona los clientes OAuth 2.0 que permiten el acceso de familiares al smartwatch del paciente. Cada paciente tiene un cliente OAuth generado automáticamente con su `familyAccessCode` como `clientId`.

---

## Endpoints

### `GET /api/oauth-clients`

Lista todos los clientes OAuth registrados.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "clientId": "FAM-0001",
    "clientSecret": "secret_1",
    "clientName": "Smartwatch-Ana García",
    "grantType": "client_credentials",
    "scopes": "read write",
    "isActive": true,
    "fkUserId": 8,
    "createdAt": "2026-05-01T10:00:00",
    "expiresAt": null
  }
]
```

---

### `POST /api/oauth-clients`

Crea un nuevo cliente OAuth manualmente.

**Cuerpo de la petición:**
```json
{
  "clientId": "FAM-CUSTOM",
  "clientSecret": "my-custom-secret",
  "clientName": "Custom Family Client",
  "grantType": "client_credentials",
  "scopes": "read"
}
```

**Respuesta `201`:** Objeto `OAuthClient` creado.

---

## Notas de implementación

- Los clientes OAuth se crean automáticamente en `DataLoader.java` para cada paciente existente usando su `familyAccessCode` como `clientId`.
- El endpoint `POST /api/auth/token` valida las credenciales OAuth contra esta tabla.
- La entidad `OAuthClient` está en la tabla `oauth_clients`.
- El repositorio tiene consultas: `findByClientId`, `findByClientIdAndIsActiveTrue`, `existsByClientId`.
