# AuthController

> **Package:** `com.project.radix.Controller.AuthController`
> **Ruta base:** `/api/auth`
> **Endpoints:** 4

---

## Descripción general

Gestiona la autenticación del sistema mediante JWT (HS384, 24h de expiración) y OAuth 2.0 para clientes externos (smartwatch, app familiar). Las contraseñas se almacenan con BCrypt (`PasswordEncoder`). Incluye rate limiting por email en el endpoint de login. Los registros de doctores y pacientes requieren autorización basada en roles.

---

## Endpoints

### `POST /api/auth/login`

Autentica a un usuario con email y contraseña. Devuelve un token JWT con los claims `sub` (userId), `role`, `firstName`, `iat` y `exp`. Está protegido por rate limiting: máximo 5 intentos fallidos en 1 minuto por email.

**Cuerpo de la petición:**
```json
{
  "email": "elena.ruiz@radix.pro",
  "password": "password123"
}
```

**Validaciones:**
| Campo | Regla |
|-------|-------|
| `email` | Obligatorio |
| `password` | Obligatorio |

**Respuesta `200`:**
```json
{
  "token": "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiIyIiwicm9sZSI6IkRvY3RvciIsI…",
  "id": 2,
  "firstName": "Elena",
  "role": "Doctor"
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `Email and password are required` |
| 401 | `Invalid credentials` |
| 429 | `Too many login attempts. Try again in X seconds.` |

---

### `POST /api/auth/token`

Flujo OAuth 2.0 `client_credentials` para autenticación de dispositivos externos (smartwatch, app familiar). Genera un `accessToken` UUID con 24h de validez y devuelve la información del paciente vinculado al cliente OAuth.

**Cuerpo de la petición:**
```json
{
  "grantType": "client_credentials",
  "clientId": "smartwatch-radix-001",
  "clientSecret": "s3cr3t-watch-key",
  "scope": "watch:ingest patient:read"
}
```

**Validaciones:**
| Campo | Regla |
|-------|-------|
| `grantType` | Obligatorio — debe ser `client_credentials` |
| `clientId` | Obligatorio — debe coincidir con un `OAuthClient` activo |
| `clientSecret` | Obligatorio — debe coincidir con el secreto del cliente |

**Respuesta `200`:**
```json
{
  "accessToken": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "tokenType": "Bearer",
  "expiresIn": 86400,
  "scope": "watch:ingest patient:read",
  "patientId": 5,
  "patientName": "Ana García",
  "familyAccessCode": "FAM-A1B2C3D4"
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `Unsupported grant type` |
| 400 | `client_id and client_secret are required` |
| 401 | `Invalid client credentials` |

---

### `POST /api/auth/register/doctor`

Registra un nuevo usuario con rol `Doctor`. Solo accesible para administradores (rol `ADMIN`). Permite incluir datos profesionales: número de colegiado, especialidad y teléfono.

**Headers:**
```
Authorization: Bearer <JWT_ADMIN>
```

**Cuerpo de la petición:**
```json
{
  "firstName": "Elena",
  "lastName": "Ruiz",
  "email": "elena.ruiz@radix.pro",
  "password": "segura123",
  "licenseNumber": "282864321",
  "specialty": "Medicina Nuclear",
  "phone": "600111001"
}
```

**Validaciones:**
| Campo | Regla |
|-------|-------|
| `firstName` | `@NotBlank` — Obligatorio |
| `lastName` | `@NotBlank` — Obligatorio |
| `email` | `@NotBlank`, `@Email` — Obligatorio, formato email válido |
| `password` | `@NotBlank`, `@Size(min=6)` — Mínimo 6 caracteres |
| `licenseNumber` | Opcional |
| `specialty` | Opcional |
| `phone` | Opcional |

**Respuesta `200`:**
```json
{
  "message": "Doctor registered successfully",
  "id": 8
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `firstName, lastName, email, and password are required` |
| 400 | `Email already exists` |
| 403 | `Only Admin can create Doctors` |

---

### `POST /api/auth/register/patient`

Registra un nuevo paciente creando tanto el `User` (rol `patient`) como el registro `Patient` vinculado. Solo accesible para doctores. Genera automáticamente un `familyAccessCode` único (formato `FAM-XXXXXXXX`). Asigna automáticamente al doctor que realiza el registro.

**Headers:**
```
Authorization: Bearer <JWT_DOCTOR>
```

**Cuerpo de la petición:**
```json
{
  "firstName": "Ana",
  "lastName": "García",
  "email": "ana.garcia@example.com",
  "password": "paciente123",
  "phone": "600222002",
  "address": "Calle Mayor 12, Madrid"
}
```

**Validaciones:**
| Campo | Regla |
|-------|-------|
| `firstName` | `@NotBlank` — Obligatorio |
| `lastName` | `@NotBlank` — Obligatorio |
| `email` | `@NotBlank`, `@Email` — Obligatorio, formato email válido |
| `password` | `@NotBlank`, `@Size(min=6)` — Mínimo 6 caracteres |
| `phone` | Opcional |
| `address` | Opcional |

**Respuesta `200`:**
```json
{
  "message": "Patient registered successfully",
  "id": 12
}
```

**Errores:**
| Código | Mensaje |
|--------|---------|
| 400 | `firstName, lastName, email, and password are required` |
| 400 | `Email already exists` |
| 403 | `Only a Doctor can register Patients` |

---

## Notas de implementación

- **JWT:** Generado con `JwtUtil` usando HS384. Claims: `sub` (userId), `role`, `firstName`, `iat`, `exp`. Expiración: 24 horas.
- **BCrypt:** `PasswordEncoder` en `SecurityConfig.java` para hash de contraseñas.
- **Rate Limiting:** `RateLimiter` con límite de 5 intentos por minuto por email en `/login`.
- **Resolución de token:** `resolveTokenUser()` extrae el JWT del header `Authorization: Bearer <token>`, valida con `jwtUtil.getUserId(token)` y busca el usuario en `UserRepository`.
- **OAuth /token:** Los clientes se gestionan en la tabla `oauth_clients` a través de `OAuthClientRepository`. El `accessToken` es un UUID aleatorio, no un JWT.
- `Patient.fkDoctorId` se asigna automáticamente al ID del doctor autenticado en `/register/patient`.
- `Patient.familyAccessCode` se genera con `FAM-` + 8 caracteres hexadecimales aleatorios.
