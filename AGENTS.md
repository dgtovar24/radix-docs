# AGENTS.md

## Repository Layout

- `radix-api/` — Spring Boot backend (Java 21, Maven)
- `radix-web/` — Astro frontend (React 19, pure inline styles, SSR mode)

## Backend Commands

```bash
cd radix-api
./mvnw spring-boot:run              # local dev (H2 in-memory, no setup)
./mvnw test                         # all tests
./mvnw test -Dtest=ClassName        # single test class
./mvnw clean package -DskipTests    # JAR build (radix-api/Dockerfile shows multi-stage)
```

## Frontend Commands

```bash
cd radix-web
npm install                         # install deps
npm run dev                         # dev server at http://localhost:4321
npm run build                       # production build
npm run preview                     # preview production build
```

## API Context Path

`server.servlet.context-path=/v2` — all backend endpoints are under `/v2`.
Frontend calls `https://api.raddix.pro/v2` (dev: `http://localhost:8080/v2`).

## Complete Endpoint Inventory (29 REST + 1 WebSocket)

### Auth — `AuthController.java`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/v2/api/auth/login` | Login with email/password |
| POST | `/v2/api/auth/token` | OAuth 2.0 token (family/smartwatch access) |
| POST | `/v2/api/auth/register/doctor` | Admin-only: register new doctor |
| POST | `/v2/api/auth/register/patient` | Doctor-only: register new patient |

### Patients — `PatientController.java`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/api/patients` | List all active patients |
| GET | `/v2/api/patients/{id}` | Get patient by ID |
| GET | `/v2/api/patients/profile/{userId}` | Get patient by User ID |
| POST | `/v2/api/patients/register` | Register patient + create user |

> ⚠️ **Limitation:** Patient endpoints only return `{id, fullName}`. Frontend expects `phone`, `address`, `isActive`, `familyAccessCode`, `createdAt`.

### Users — `UserController.java`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/api/users` | List all users |
| GET | `/v2/api/users/role/{role}` | List users by role |

> ⚠️ **Missing:** No GET/PUT/DELETE for individual users. No `phone`, `licenseNumber`, `specialty` fields on User model.

### Treatments — `TreatmentController.java`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/api/treatments` | List all treatments |
| GET | `/v2/api/treatments/active` | List active treatments |
| GET | `/v2/api/treatments/{id}` | Get treatment by ID |
| GET | `/v2/api/treatments/patient/{patientId}` | Treatments by patient |
| POST | `/v2/api/treatments` | Create treatment (auth required) |
| POST | `/v2/api/treatments/{id}/end` | End/close treatment |

### Alerts — `DoctorAlertController.java`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/api/alerts` | List all alerts |
| GET | `/v2/api/alerts/pending` | List unresolved alerts |
| GET | `/v2/api/alerts/patient/{patientId}` | Alerts by patient |
| PUT | `/v2/api/alerts/{id}/resolve` | Mark alert as resolved |

### Watch/Smartwatch — `WatchDataController.java`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/v2/api/watch/ingest` | Ingest metrics from smartwatch |
| GET | `/v2/api/watch/{imei}/metrics` | Metrics by device IMEI |
| GET | `/v2/api/watch/patient/{patientId}/latest` | Latest metrics for patient |

### Isotopes — `IsotopeController.java`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/api/isotopes` | List all isotopes |
| GET | `/v2/api/isotopes/{id}` | Get isotope by ID |

### Dashboard — `DashboardController.java`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/api/dashboard/stats` | Aggregated dashboard statistics |

### System
| Method | Path | Description |
|--------|------|-------------|
| GET | `/v2/` | Health check + API metadata |
| GET | `/v2/docs` | Self-documenting API schema |
| WS | `/ws/alerts` | Real-time alert push via WebSocket |

## Missing Endpoints

35 endpoints identified across 7 categories. See `MISSING_ENDPOINTS.md` for full gap analysis with dependency diagram.

**Entities without any controller:** `Smartwatch`, `HealthLog`, `RadiationLog`, `GameSession`, `MotivationalMessage`, `Settings`, `Unit`, `OAuthClient`.

## Database

- **Local**: H2 in-memory (`jdbc:h2:mem:radixdb`), schema auto-created via `ddl-auto: update`
- **Production**: MySQL via env vars `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`; activated by `-Dspring.profiles.active=prod` (set in Dockerfile)
- **Credentials in `application-prod.yml` are real and must not be committed**

## Deployment

- **API**: Dokploy with `radix-api/Dockerfile` (multi-stage `eclipse-temurin:21`). Env vars: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `SERVER_PORT`
- **Web**: `radix-web/Dockerfile` (Bun builder + Node 22 runner)
- See `radix-api/DEPLOY.md` for full env var table

## Schema Source of Truth

JPA entities in `radix-api/src/main/java/com/project/radix/Model/` — schema auto-generated via `ddl-auto: update`. See `radix-api/DATABASE.md` for full table list (13 tables).

## Sample Data

Pre-loaded at startup via `radix-api/src/main/java/com/project/radix/Config/DataLoader.java` (1 admin user, 11 isotope catalog entries, auto-creates OAuth clients).

## Documentation Files

| File | Content |
|------|---------|
| `ENDPOINTS.md` | Complete catalog of all 29 existing API endpoints |
| `MISSING_ENDPOINTS.md` | Gap analysis: 35 missing endpoints with Mermaid diagram |
| `radix-api/DATABASE.md` | Full database schema with ERD and table definitions |
| `radix-api/DEPLOY.md` | Deployment guide with env vars |
| `radix-web/apiScheme.json` | Client-side API schema reference |
| `diagrams.md` | Navigation and use case diagrams |

## Frontend Architecture Notes

### Style System
- **Pure inline styles** in all React components — no Tailwind classes used
- **CSS Variables** (`--p`, `--b`, `--sf`, `--t`, `--t-s`, `--br`) set on `:root` by ThemeProvider
- Components reference CSS vars with fallbacks: `var(--sf, #ffffff)`

### Astro Islands
- Each `client:load` / `client:only` creates a **separate React root**
- React context does NOT cross island boundaries
- **ThemeProvider is embedded inside DashboardLayout** so context flows to all children

### Palette System
- 8 preset palettes in `radix-web/src/data/palettes.ts`
- Persisted in `localStorage` as `radix-palette` (JSON string)
- Page-level inline `<script is:inline>` applies palettes before React hydrates
- Switching works on `/configuracion` — visual colors update on dashboard via CSS variables

### Page Structure
- `/dashboard` — 3 islands: ThemeProvider, DashboardLayout, DashboardStats
- `/configuracion` — 1 island: DashboardLayout with `configPage="configuration"`
- Auth via `radix-user` cookie (JSON encoded), checked by middleware

### Mock Data
- Dashboard widgets (`DashboardWidgets.tsx`) use `MOCK_STATS`, `MOCK_RADIATION_LOGS`, `MOCK_ISOTOPE_DISTRIBUTION`, `MOCK_ALERTS_DATA`, `MOCK_RADAR_DATA`, `MOCK_PATIENTS_LIST` from `mockDashboardData.ts`
- Patient details use `setInterval` simulated heart rate and `useMemo` generated historical data
- Chat panel uses hardcoded messages (Floyd Miles, Guy Hawkins, Kristin Watson)
- Rix panel uses hardcoded chat history and doctor list
- All mock data should be replaced with real API calls once missing endpoints are implemented
