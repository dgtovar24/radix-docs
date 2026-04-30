---
title: API Deep Dive - Controllers
description: Análisis detallado de todos los controllers del API de Radix
author: Documentation Bot
date: 2026-04-28
tags:
  - backend
  - api
  - controllers
  - endpoints
  - deep-dive
module: Backend
status: active
---

# API Deep Dive - Controllers

## Overview de Controllers

| Controller | Path Base | Métodos |
|------------|-----------|---------|
| AuthController | `/api/auth` | login, register/doctor, register/patient |
| UserController | `/api/users` | getAllUsers, getUsersByRole |
| PatientController | `/api/patients` | getAllPatients, getPatient, getProfileByUser, registerPatient |
| HealthController | `/` | root (API info) |
| DocsController | `/docs` | getApiDocs |

---

## AuthController

**Ubicación**: `Controller/AuthController.java`

### Annotations

```java
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController { ... }
```

- `@RestController`: Combina `@Controller` y `@ResponseBody`
- `@RequestMapping("/api/auth")`: Todos los endpoints empiezan con `/api/auth`
- `@CrossOrigin(origins = "*")`: Permite CORS de cualquier origen

### Endpoints

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/login` | Login de usuario | No |
| POST | `/register/doctor` | Registrar doctor | ADMIN |
| POST | `/register/patient` | Registrar paciente | DOCTOR |

### Dependencias

```java
private final UserRepository userRepository;
private final PatientRepository patientRepository;

public AuthController(UserRepository userRepository, PatientRepository patientRepository) {
    this.userRepository = userRepository;
    this.patientRepository = patientRepository;
}
```

---

## UserController

**Ubicación**: `Controller/UserController.java`

### Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/users` | Lista todos los usuarios |
| GET | `/api/users/role/{role}` | Lista usuarios por rol |

### Implementación

```java
@GetMapping
public ResponseEntity<List<User>> getAllUsers() {
    return ResponseEntity.ok(userRepository.findAll());
}

@GetMapping("/role/{role}")
public ResponseEntity<List<User>> getUsersByRole(@PathVariable String role) {
    return ResponseEntity.ok(userRepository.findByRole(role));
}
```

---

## PatientController

**Ubicación**: `Controller/PatientController.java`

### Annotations

```java
@RestController
@RequestMapping("/api/patients")
@RequiredArgsConstructor  // Lombok - genera constructor con campos final
@CrossOrigin(origins = "*")
public class PatientController { ... }
```

### Endpoints

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/register` | Registrar paciente | No |
| GET | `/` | Lista pacientes activos | No |
| GET | `/{id}` | Ver paciente por ID | No |
| GET | `/profile/{userId}` | Perfil por userId | No |

### Registro de Paciente (POST /register)

```java
@PostMapping("/register")
public ResponseEntity<?> registerPatient(@RequestBody Map<String, String> body) {
    // 1. Check email uniqueness
    if (userRepository.existsByEmail(body.get("email"))) {
        return ResponseEntity.status(400)
            .body(Map.of("error", "Email already exists"));
    }

    // 2. Create User
    User u = new User();
    u.setFirstName(body.get("firstName"));
    u.setLastName(body.get("lastName"));
    u.setEmail(body.get("email"));
    u.setPassword(body.get("password"));
    u.setRole("patient");
    u = userRepository.save(u);

    // 3. Create Patient
    Patient p = new Patient();
    p.setFullName(body.get("firstName") + " " + body.get("lastName"));
    p.setFkUserId(u.getId());
    p.setIsActive(true);
    p.setFamilyAccessCode("FAM-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());

    if (body.containsKey("doctorId")) {
        p.setFkDoctorId(Integer.parseInt(body.get("doctorId")));
    }

    patientRepository.save(p);

    return ResponseEntity.ok(Map.of(
        "message", "Patient created successfully",
        "userId", u.getId()
    ));
}
```

### Listar Pacientes (GET /)

```java
@GetMapping
public ResponseEntity<?> getAllPatients() {
    List<?> patients = patientRepository.findByIsActiveTrue().stream()
        .map(p -> Map.of(
            "id", p.getId(),
            "fullName", p.getFullName()
        ))
        .toList();
    return ResponseEntity.ok(patients);
}
```

> [!note] Respuesta Minimalista
> `getAllPatients()` solo retorna `id` y `fullName`. La información completa está en la entidad Patient.

### Ver Paciente por ID (GET /{id})

```java
@GetMapping("/{id}")
public ResponseEntity<?> getPatient(@PathVariable Integer id) {
    return patientRepository.findById(id)
        .filter(Patient::getIsActive)
        .map(p -> ResponseEntity.ok(Map.of(
            "id", p.getId(),
            "fullName", p.getFullName()
        )))
        .orElse(ResponseEntity.status(404)
            .body(Map.of("error", "Not found")));
}
```

### Perfil por User ID (GET /profile/{userId})

```java
@GetMapping("/profile/{userId}")
public ResponseEntity<?> getProfileByUser(@PathVariable Integer userId) {
    return patientRepository.findByFkUserId(userId)
        .map(p -> ResponseEntity.ok(Map.of(
            "id", p.getId(),
            "fullName", p.getFullName()
        )))
        .orElse(ResponseEntity.status(404)
            .body(Map.of("error", "Patient not found")));
}
```

---

## HealthController

**Ubicación**: `Controller/HealthController.java`

### Endpoint Raíz

```java
@Get({"", "/"})
public ResponseEntity<?> root() {
    return ResponseEntity.ok(Map.of(
        "name", "Radix API",
        "version", "v1",
        "description", "REST API for Radix medical management system",
        "status", "operational",
        "timestamp", Instant.now().toString(),
        "docs", "https://api.aiflex.dev/v1/actuator",
        "endpoints", List.of(
            Map.of("method", "GET",  "path", "/v1/", "description", "API info & status"),
            Map.of("method", "POST", "path", "/v1/api/auth/login", "description", "User authentication"),
            // ... más endpoints
        )
    ));
}
```

---

## DocsController

**Ubicación**: `Controller/DocsController.java`

### Documentación Auto-generada

```java
@Get
public ResponseEntity<?> getApiDocs() {
    return ResponseEntity.ok(Map.of(
        "api", "Radix API v1",
        "description", "Complete API Schema...",
        "endpoints", List.of(
            Map.of(
                "path", "/api/auth/login",
                "method", "POST",
                "description", "Login user to get session ID/Token",
                "request_body", Map.of(
                    "email", "string (required)",
                    "password", "string (required)"
                ),
                "response", Map.of(
                    "token", "integer (ID as token)",
                    "id", "integer",
                    "firstName", "string",
                    "role", "string"
                )
            ),
            // ... más endpoints
        )
    ));
}
```

---

## Patient Entity (Modelo)

**Ubicación**: `Model/Patient.java`

```java
@Entity
@Table(name = "patients")
public class Patient {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "phone")
    private String phone;

    @Column(name = "address")
    private String address;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "family_access_code", unique = true)
    private String familyAccessCode;

    @Column(name = "fk_user_id")
    private Integer fkUserId;

    @Column(name = "fk_doctor_id")
    private Integer fkDoctorId;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fk_user_id", insertable = false, updatable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fk_doctor_id", insertable = false, updatable = false)
    private User doctor;
}
```

### Relaciones

| Relación | Tipo | Descripción |
|----------|------|-------------|
| user | ManyToOne | Usuario asociado (cuenta de acceso) |
| doctor | ManyToOne | Doctor que atiende al paciente |

---

## PatientRepository

```java
@Repository
public interface PatientRepository extends JpaRepository<Patient, Integer> {
    List<Patient> findByIsActiveTrue();
    Optional<Patient> findByFkUserId(Integer fkUserId);
    Optional<Patient> findByFkDoctorId(Integer fkDoctorId);
    Optional<Patient> findByFamilyAccessCode(String familyAccessCode);
}
```

### Métodos Derivados de Spring Data

| Método | SQL Generado |
|--------|--------------|
| `findByIsActiveTrue()` | `SELECT * FROM patients WHERE is_active = true` |
| `findByFkUserId(id)` | `SELECT * FROM patients WHERE fk_user_id = id` |
| `findByFkDoctorId(id)` | `SELECT * FROM patients WHERE fk_doctor_id = id` |
| `findByFamilyAccessCode(code)` | `SELECT * FROM patients WHERE family_access_code = code` |

---

## Códigos de Estado HTTP

| Código | Significado | Uso |
|--------|--------------|-----|
| 200 | OK | Respuesta exitosa |
| 400 | Bad Request | Datos inválidos o faltantes |
| 401 | Unauthorized | Credenciales inválidas |
| 403 | Forbidden | Permisos insuficientes |
| 404 | Not Found | Recurso no encontrado |
| 500 | Internal Server Error | Error del servidor |

---

## Anotaciones de Spring Boot

### @RestController

Combina `@Controller` y `@ResponseBody`. Indica que la clase maneja requests HTTP y los datos de retorno se serializan a JSON/XML.

### @RequestMapping

```java
@RequestMapping("/api/patients")
// Todos los métodos usan este prefijo de ruta
```

### @GetMapping, @PostMapping, @PutMapping, @DeleteMapping

Shortcuts para `@RequestMapping` con método específico.

```java
@GetMapping("/{id}")
// Equivale a:
// @RequestMapping(value = "/{id}", method = RequestMethod.GET)
```

### @PathVariable

Extrae variables de la URL:

```java
@GetMapping("/{id}")
public ResponseEntity<?> getPatient(@PathVariable Integer id) { ... }
// GET /api/patients/5 → id = 5
```

### @RequestBody

Deserializa el body de la petición a un objeto:

```java
@PostMapping("/register")
public ResponseEntity<?> registerPatient(@RequestBody Map<String, String> body) {
    String email = body.get("email"); // Auto-convertido desde JSON
}
```

### @RequestHeader

Extrae headers de la petición:

```java
@PostMapping("/register/doctor")
public ResponseEntity<?> registerDoctor(
    @RequestHeader("Authorization") String creatorAuth) {
    // Authorization header value
}
```

### @CrossOrigin

Permite requests desde otros dominios (CORS):

```java
@CrossOrigin(origins = "*")
// * = cualquier origen
//También: origins = {"http://localhost:3000", "https://example.com"}
```

---

## ResponseEntity

Wrapper para respuestas HTTP con control total del status code:

```java
// Éxito
return ResponseEntity.ok(user);

// Con cuerpo y status específico
return ResponseEntity.status(403).body(Map.of("error", "..."));

// Not Found
return ResponseEntity.notFound().build();

// Con headers
return ResponseEntity.ok()
    .header("X-Custom", "value")
    .body(data);
```

---

## Ver También

- [[Backend/API-Authentication]] - Flujo de auth detallado
- [[Backend/Auth]] - Endpoints de autenticación
- [[Backend/Entities-Overview]] - Todas las entidades