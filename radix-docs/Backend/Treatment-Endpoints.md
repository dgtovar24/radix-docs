---
title: Treatment Endpoints
description: API para gestión de tratamientos de medicina nuclear con cálculo automático de confinamiento
author: Documentation Bot
date: 2026-04-28
tags:
  - backend
  - api
  - treatments
  - confinement
module: Backend
status: active
---

# Treatment Endpoints

## Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | `/api/treatments` | List all treatments | DOCTOR, ADMIN |
| GET | `/api/treatments/active` | List active treatments only | DOCTOR, ADMIN |
| GET | `/api/treatments/{id}` | Get treatment details | DOCTOR, ADMIN |
| GET | `/api/treatments/patient/{patientId}` | Get treatments for a patient | DOCTOR, ADMIN |
| POST | `/api/treatments` | Create treatment (auto-calculates confinement) | DOCTOR |
| POST | `/api/treatments/{id}/end` | End treatment | DOCTOR |

---

## Create Treatment (POST /api/treatments)

### Request

```json
{
  "fkPatientId": 5,
  "fkRadioisotopeId": 1,
  "fkSmartwatchId": 3,
  "room": 101,
  "initialDose": 150.5
}
```

### Confinement Calculation

When a treatment is created, the system automatically calculates:

1. **Isolation Days** = `ceil(half_life * 10)`
2. **Safety Threshold** = `initial_dose * 0.1` (10% of initial dose)

For example, if Iodine-131 has a half-life of 8 days:
- Isolation Days = `ceil(8 * 10)` = 80 days
- Safety Threshold = `150.5 * 0.1` = 15.05 mCi

### Response

```json
{
  "id": 1,
  "patientId": 5,
  "patientName": "Maria Garcia",
  "doctorId": 1,
  "doctorName": "Dr. Juan Perez",
  "isotopeId": 1,
  "isotopeName": "Iodine-131",
  "room": 101,
  "initialDose": 150.5,
  "safetyThreshold": 15.05,
  "isolationDays": 80,
  "startDate": "2026-04-28T10:00:00",
  "endDate": null,
  "isActive": true
}
```

---

## Confinement Calculation Service

```java
@Service
public class ConfinementCalculationService {

    public ConfinementResult calculate(Integer isotopeId, Double initialDose) {
        IsotopeCatalog isotope = isotopeRepository.findById(isotopeId)
            .orElseThrow(() -> new RuntimeException("Isotope not found"));

        double confinementDays = Math.ceil(isotope.getHalfLife() * 10);
        double safetyThreshold = initialDose * 0.1;

        return new ConfinementResult(
            isotope.getName(),
            isotope.getSymbol(),
            isotope.getHalfLife(),
            isotope.getHalfLifeUnit(),
            (int) confinementDays,
            safetyThreshold
        );
    }
}
```

### Formula

| Variable | Formula | Description |
|----------|---------|-------------|
| `isolationDays` | `ceil(half_life * 10)` | Safe isolation period in days |
| `safetyThreshold` | `initial_dose * 0.1` | Radiation level that triggers alert |

---

## Treatment Model

```java
@Entity
@Table(name = "treatments")
public class Treatment {
    private Integer id;
    private Integer fkPatientId;
    private Integer fkDoctorId;
    private Integer fkRadioisotopeId;
    private Integer fkSmartwatchId;
    private Integer room;
    private Double initialDose;
    private Double safetyThreshold;  // Auto-calculated
    private Integer isolationDays;   // Auto-calculated
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Boolean isActive;
}
```

---

## Example: Create Treatment with Curl

```bash
# Login first
TOKEN=$(curl -s -X POST http://localhost:8080/v2/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"Radix","password":"radixelmejor1"}' | jq -r '.token')

# Create treatment
curl -X POST http://localhost:8080/v2/api/treatments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "fkPatientId": 1,
    "fkRadioisotopeId": 1,
    "room": 101,
    "initialDose": 150.5
  }'
```

---

## Ver También

- [[Backend/Watch-Data-Ingestion]] - Smartwatch data endpoints
- [[Backend/WebSocket-Alerts]] - Real-time alert system
- [[Backend/API-Controllers]] - All controllers