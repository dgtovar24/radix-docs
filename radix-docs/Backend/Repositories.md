---
title: Repositories
description: Repositorios JPA de Radix - interfaces Spring Data para acceso a datos
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - database
  - jpa
  - repository
module: Backend
status: active
---

# Repositories

Repositorios Spring Data JPA ubicados en `com.project.radix.Repository`. Cada entidad tiene su propio repositorio con métodos de consulta personalizados.

---

## UserRepository

```java
@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRole(String role);
}
```

### Métodos

| Método | Descripción |
|--------|-------------|
| `findByEmail(email)` | Busca usuario por email exacto |
| `existsByEmail(email)` | Verifica si existe usuario con email |
| `findByRole(role)` | Lista usuarios con rol específico |

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

### Métodos

| Método | Descripción |
|--------|-------------|
| `findByIsActiveTrue()` | Pacientes activos |
| `findByFkUserId(id)` | Paciente por ID de usuario |
| `findByFkDoctorId(id)` | Pacientes asignados a doctor |
| `findByFamilyAccessCode(code)` | Paciente por código familiar |

---

## TreatmentRepository

Ubicación: `Repository/TreatmentRepository.java`

### Métodos Disponibles

- `findAll()` - Listar todos
- `findById(id)` - Buscar por ID
- `save(treatment)` - Guardar/actualizar
- `deleteById(id)` - Eliminar

### Métodos Personalizados (ejemplos)

```java
List<Treatment> findByFkPatientId(Integer fkPatientId);
List<Treatment> findByIsActiveTrue();
Optional<Treatment> findByFkDoctorIdAndIsActiveTrue(Integer fkDoctorId);
```

---

## SmartwatchRepository

Ubicación: `Repository/SmartwatchRepository.java`

### Métodos

```java
Optional<Smartwatch> findByImei(String imei);
Optional<Smartwatch> findByMacAddress(String macAddress);
List<Smartwatch> findByFkPatientId(Integer fkPatientId);
List<Smartwatch> findByIsActiveTrue();
```

---

## HealthLogRepository

Ubicación: `Repository/HealthLogRepository.java`

### Métodos

```java
List<HealthLog> findByFkPatientIdOrderByTimestampDesc(Integer fkPatientId);
List<HealthLog> findByTimestampBetween(LocalDateTime start, LocalDateTime end);
Optional<HealthLog> findTopByFkPatientIdOrderByTimestampDesc(Integer fkPatientId);
```

---

## RadiationLogRepository

Ubicación: `Repository/RadiationLogRepository.java`

### Métodos

```java
List<RadiationLog> findByFkPatientId(Integer fkPatientId);
List<RadiationLog> findByFkTreatmentId(Integer fkTreatmentId);
List<RadiationLog> findByRadiationLevelGreaterThan(Double level);
```

---

## DoctorAlertRepository

Ubicación: `Repository/DoctorAlertRepository.java`

### Métodos

```java
List<DoctorAlert> findByIsResolvedFalse();
List<DoctorAlert> findByFkPatientIdAndIsResolvedFalse(Integer fkPatientId);
List<DoctorAlert> findByFkDoctorId(Integer fkDoctorId);
```

---

## IsotopeCatalogRepository

Ubicación: `Repository/IsotopeCatalogRepository.java`

### Métodos

```java
Optional<IsotopeCatalog> findBySymbol(String symbol);
List<IsotopeCatalog> findByType(String type);
```

---

## UnitRepository

Ubicación: `Repository/UnitRepository.java`

### Métodos

```java
Optional<Unit> findBySymbol(String symbol);
List<Unit> findAll(); // Heredado de JpaRepository
```

---

## GameSessionRepository

Ubicación: `Repository/GameSessionRepository.java`

### Métodos

```java
List<GameSession> findByFkPatientIdOrderByPlayedAtDesc(Integer fkPatientId);
Optional<GameSession> findTopByFkPatientIdOrderByScoreDesc(Integer fkPatientId);
```

---

## SettingsRepository

Ubicación: `Repository/SettingsRepository.java`

### Métodos

```java
Optional<Settings> findByFkPatientId(Integer fkPatientId);
```

---

## MotivationalMessageRepository

Ubicación: `Repository/MotivationalMessageRepository.java`

### Métodos

```java
List<MotivationalMessage> findByFkPatientIdAndIsReadFalse(Integer fkPatientId);
List<MotivationalMessage> findByFkPatientIdOrderBySentAtDesc(Integer fkPatientId);
```

---

## Uso Típico en Controladores

```java
@RestController
@RequestMapping("/api/patients")
public class PatientController {

    private final PatientRepository patientRepository;
    private final UserRepository userRepository;

    public PatientController(PatientRepository patientRepository,
                            UserRepository userRepository) {
        this.patientRepository = patientRepository;
        this.userRepository = userRepository;
    }

    @GetMapping
    public ResponseEntity<?> getAllPatients() {
        List<?> patients = patientRepository.findByIsActiveTrue().stream()
            .map(p -> Map.of("id", p.getId(), "fullName", p.getFullName()))
            .toList();
        return ResponseEntity.ok(patients);
    }
}
```

---

## Ver También

- [[Backend/Entities-Overview]] - Entidades que usan estos repositorios
- [[Backend/Database-Schema]] - Estructura de tablas en MySQL