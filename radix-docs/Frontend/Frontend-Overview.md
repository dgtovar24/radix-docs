---
title: Frontend Overview
description: Dashboard web de Radix — Astro + React con estilos inline puros
author: Documentation Bot
date: 2026-04-28
tags:
  - frontend
  - astro
  - react
  - dashboard
module: Frontend
status: active
---

# Frontend Overview

## Stack

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework | Astro (SSR mode) | 5.18 |
| UI | React | 19 |
| CSS approach | Pure inline styles | — |
| Charts | Recharts | 3.x |
| Icons | Lucide React | 0.x |
| Server | Node.js adapter | standalone |

> [!note] Sin Tailwind en componentes
> Todos los componentes usan **inline styles** puros con CSS variables (`var(--sf)`, `var(--t)`, etc.). Tailwind solo se usa como base CSS reset (`global.css`).

## Arquitectura de Páginas

```
src/pages/
├── login.astro         → LoginForm en AuthLayout
├── register.astro      → RegisterForm
├── dashboard.astro     → Dashboard principal
├── pacientes/          → Listado, alta, y detalle de pacientes
├── tratamientos/       → Listado y alta de tratamientos
├── alertas/            → Alertas clínicas
├── usuarios.astro      → Usuarios y facultativos
├── mi-perfil.astro     → Perfil editable del usuario conectado
├── rix.astro           → Vista expandida de Rix
└── configuracion.astro → Centro de configuración
```

## API Context Path

`server.servlet.context-path=/v2` — frontend llama a
`http://localhost:8080/v2` (dev) o `https://api.raddix.pro/v2`
(producción).

El cliente React consume `/api/*`. Astro sirve un proxy general en
`src/pages/api/[...path].ts` que reenvía esas llamadas a
`${PUBLIC_API_URL}/api/*` y adjunta el token de la cookie `radix-user` cuando
existe. Las rutas de autenticación mantienen handlers dedicados para crear y
borrar la cookie de sesión.

## CSS Variables

El sistema de temas usa CSS custom properties aplicadas al `:root` para personalización dinámica en tiempo real:

```css
--p      /* primary */
--p-l    /* primary light */
--s      /* secondary */
--b      /* background (página principal) */
--sf     /* surface (cards, sidebars) */
--t      /* text principal */
--t-s    /* text secondary */
--br     /* border */
```

### Consumo en inline styles

```tsx
// Fondo de card — responde a cambios de paleta inmediatamente
<div style={{ background: 'var(--sf, #ffffff)' }}>

// Texto principal — responde a cambios de paleta
<span style={{ color: 'var(--t, #111827)' }}>
```

## Componentes

| Componente | Archivo | Descripción |
|------------|---------|-------------|
| DashboardLayout | `DashboardLayout.tsx` | Layout 3-columnas; chat interno y Rix consumen API y muestran estados vacíos si faltan endpoints |
| DashboardStats | `DashboardStats.tsx` | KPIs y gráficos con datos de API |
| ThemeProvider | `ThemeProvider.tsx` | Contexto de paleta, CSS variables, localStorage |
| ConfigurationPage | `ConfigurationPage.tsx` | Configuración API-first: `/api/system-settings`, SMTP test, Rix IA, credenciales API |
| ProfilePage | `DashboardLayout.tsx` | Perfil editable y reset de contraseña |
| LoginForm | `LoginForm.tsx` | Formulario de login |

## Astro Islands

Cada componente hidratado con `client:load` o `client:only` es una **isla independiente** con su propio React root. El contexto de React no cruza entre islas.

**Regla**: ThemeProvider se incrusta dentro de DashboardLayout (misma isla) para que el contexto fluya a todos los hijos.

```astro
<!-- dashboard.astro — 3 islas -->
<ThemeProvider client:load>
  <DashboardLayout client:load userName={userName} userRole={userRole}>
    <DashboardStats client:load />
  </DashboardLayout>
</ThemeProvider>

<!-- configuracion.astro — 1 isla -->
<DashboardLayout client:only="react" configPage="configuration" />
```

## Autenticación

Cookie `radix-user` con JSON encodeado:

```json
{
  "firstName": "Doctor",
  "role": "Doctor",
  "email": "radix@example.com"
}
```

- Middleware redirige a `/login` si no hay cookie
- Rutas públicas: `/login`, `/register`, `/api/auth/*`
- El proxy `/api/*` usa `token` o `id` de la cookie como bearer-like token.
- El login del frontend ya no crea usuarios hardcoded; siempre consulta la API.
- Chat interno y Rix ya no contienen conversaciones fijas; consultan
  `/api/internal-chat/*` y `/api/rix/*`.

## Paletas

8 paletas predefinidas en `src/data/palettes.ts`. Ver [[Frontend/Theme-System]] para detalles.

## Deployment

- **Dev**: `npm run dev` → http://localhost:4321
- **Build**: `npm run build` → output en `dist/`
- **Docker**: Bun builder + Node 22 runner, `radix-web/Dockerfile`

## Ver También

- [[Frontend/Dashboard-Deep-Dive]] — Layout y Activity Feed
- [[Frontend/Components]] — Componentes React
- [[Frontend/Theme-System]] — Sistema de paletas
- [[Frontend/Authentication]] — Sistema de auth
- [[Backend/API-Overview]] — API que consume el frontend
