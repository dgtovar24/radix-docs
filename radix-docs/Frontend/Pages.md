---
title: Pages
description: Páginas Astro del frontend — rutas, componentes y layouts
author: Documentation Bot
date: 2026-04-28
tags:
  - frontend
  - pages
  - astro
  - routing
module: Frontend
status: active
---

# Pages

This page lists the active Astro routes in the Radix web app and explains how
the dashboard cards route users to detailed pages.

## Rutas

| Ruta | Archivo | Componentes | Auth |
|------|---------|-------------|------|
| `/login` | `login.astro` | LoginForm en AuthLayout | Público |
| `/register` | `register.astro` | RegisterForm | Público |
| `/dashboard` | `dashboard.astro` | DashboardLayout, DashboardStats | Cookie |
| `/pacientes` | `pacientes/index.astro` | PatientList | Cookie |
| `/tratamientos` | `tratamientos/index.astro` | TreatmentList | Cookie |
| `/alertas` | `alertas/index.astro` | AlertList | Cookie |
| `/usuarios` | `usuarios.astro` | UsuariosList | Cookie |
| `/mi-perfil` | `mi-perfil.astro` | DashboardLayout profile view | Cookie |
| `/rix` | `rix.astro` | DashboardLayout Rix view | Cookie |
| `/configuracion` | `configuracion.astro` | DashboardLayout (configPage) | Cookie |

> **Note:** `/facultativos` was removed because facultativos are now managed
> from `/usuarios`.

## /login

Formulario de login. Llama a `POST /v2/api/auth/login`, guarda respuesta en cookie `radix-user`.

```astro
<AuthLayout pageTitle="Iniciar Sesión">
  <LoginForm client:load />
</AuthLayout>
```

## /dashboard

Página principal. 3 islas:

```astro
<ThemeProvider client:load>
  <DashboardLayout client:load userName={userName} userRole={userRole}>
    <DashboardStats client:load />
  </DashboardLayout>
</ThemeProvider>
```

### Contenido

1. **Header**: saludo grande (28px, `fontWeight: 600`) + subtitle + fecha con borde
2. **KPI Row**: 3 indicadores que navegan a páginas de detalle:
   **Pacientes Totales** navega a `/pacientes`, **Tratamientos Activos**
   navega a `/tratamientos`, y **Alertas Pendientes** navega a `/alertas`.
3. **Charts**: los gráficos de radiación y cohorte navegan a `/pacientes`, el
   gráfico de isótopos navega a `/tratamientos`, y el gráfico de alertas navega
   a `/alertas`.

## /usuarios

`/usuarios` is now the single page for system users and facultativos. It
supports search, role filters, department filters, and mock department creation
while the backend endpoints are pending.

The page uses the following roles:

- `DESARROLLADOR`
- `ADMIN`
- `FACULTATIVO`

Admins and developers can see facultativo charts. Regular facultativos can see
the list and filters, but the doctor metrics are hidden.

## /configuracion

Selector de paletas. **1 sola isla**:

```astro
<DashboardLayout client:only="react" configPage="configuration" />
```

DashboardLayout renderiza `<ConfigurationPage />` cuando recibe `configPage="configuration"`.

### Tabs

- **TEMAS**: Grid 4×2 de paletas predefinidas
- **PERSONALIZAR**: 12 color pickers individuales
- **EXPORTAR**: JSON export/import

## Auth

Middleware (`src/middleware.ts`) protege rutas:

```typescript
const PUBLIC_ROUTES = ['/login', '/register', '/api/auth/login', '/api/auth/register', '/api/auth/callback'];

export const onRequest = defineMiddleware(async (context, next) => {
  if (PUBLIC_ROUTES.some(r => context.url.pathname.startsWith(r))) return next();
  if (!context.request.headers.get('cookie')?.includes('radix-user=')) {
    return context.redirect('/login');
  }
  return next();
});
```

## Layouts

### AuthLayout
Layout para login/register. Dos paneles: branding azul a la izquierda, formulario blanco a la derecha.

### DashboardLayout
Layout 3-columnas CSS Grid con sidebar + main + chatbot. Ver [[Frontend/Dashboard-Deep-Dive]].

## Ver También

- [[Frontend/Frontend-Overview]] — Vista general
- [[Frontend/Dashboard-Deep-Dive]] — Layout en detalle
- [[Frontend/Components]] — Componentes React
- [[Frontend/Authentication]] — Sistema de auth
