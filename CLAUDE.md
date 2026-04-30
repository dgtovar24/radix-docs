# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a multi-service medical dashboard system (RADIX).

- **`radix-api/`**: Spring Boot backend API (Java 21, Maven).
- **`radix-web/`**: Astro frontend dashboard (React 19, Tailwind, Supabase SSR).

## Development Commands

### Backend (radix-api)
```bash
cd radix-api
./mvnw spring-boot:run              # Local dev (H2 in-memory)
./mvnw test                         # Run tests
./mvnw test -Dtest=ClassName        # Run specific test
./mvnw clean package -DskipTests    # Build JAR
```

### Frontend (radix-web)
```bash
cd radix-web
npm install                         # Install dependencies
npm run dev                         # Start dev server (http://localhost:4321)
npm run build                       # Production build
npm run preview                     # Preview production build
```

## Architecture

### Backend (radix-api)
- **Framework**: Spring Boot 3.5.9, Java 21, Maven.
- **Database**: H2 in-memory for local dev; MySQL for production (`-Dspring.profiles.active=prod`).
- **API Version**: Currently v2 (context path `/v2`).
- **Core Entities**: `Usuario` (users), `Pacientes` (patients), `Tratamiento` (treatments), `MetricasSalud` (health metrics).
- **Authentication**: Email/password based. See `radix-api/AGENTS.md` for endpoint list.
- **Schema Management**: JPA/Hibernate with `ddl-auto: update` — entities in `Model/` are the schema source of truth.

### Frontend (radix-web)
- **Framework**: Astro 5.18 (SSR mode).
- **UI**: React 19 components with Tailwind CSS.
- **Backend Integration**: Calls `https://api.raddix.pro/v2` (or local `http://localhost:8080/v2` for dev).
- **Auth**: Supabase SSR for session management (see `middleware.ts`).

## Deployment

- **API**: Deployed via Dokploy using `radix-api/Dockerfile`. Environment variables `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` are required.
- **Web**: Built as a Docker image or static files (check `radix-web/Dockerfile`).

## Database Details
- **Schema**: Defined in `radix-api/DATABASE.md`. Contains 13 tables: `users`, `patients`, `smartwatches`, `treatments`, `health_logs`, `radiation_logs`, `doctor_alerts`, `game_sessions`, `settings`, etc.
- **Sample Data**: Pre-loaded via `Config/DataLoader.java` (8 patients, doctors, active treatments).

## Additional Resources
- `radix-api/DEPLOY.md`: Detailed deployment instructions for the API.
- `radix-api/docs/01-overview.md`: Spanish API documentation and conventions.