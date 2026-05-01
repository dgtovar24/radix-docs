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

## Chat interno y Rix

La columna derecha y `/rix` ya no usan conversaciones fijas. `DashboardLayout`
consume:

- `/api/internal-chat/users`
- `/api/internal-chat/conversations`
- `/api/internal-chat/conversations/{id}/messages`
- `/api/rix/conversations`
- `/api/rix/group-conversations`
- `/api/rix/doctors`
- `/api/rix/messages`

Si esos endpoints todavía no existen en backend, la interfaz muestra estados
vacíos sin inventar datos.
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

`/usuarios` is now the single page for system users and facultativos. It uses
`GET /api/users` through the frontend proxy and applies the current search in
the client until the backend ships server-side filters.

The page uses the following roles:

- `DESARROLLADOR`
- `ADMIN`
- `FACULTATIVO`

Admins and developers can see facultativo charts when the metrics endpoints are
available. Regular facultativos can see the list and filters, but the doctor
metrics are hidden.

## /mi-perfil

`/mi-perfil` loads the current user ID from the `radix-user` session cookie and
uses `GET /api/users/{id}` to hydrate the editable profile view. The page lets
users edit personal, contact, and professional fields, and reset their password
with `PUT /api/users/{id}`.

The profile page intentionally does not expose account deletion. User deletion
remains an administrative action outside the self-service profile surface.

## /configuracion

Configuration center. **1 sola isla**:

```astro
<DashboardLayout client:only="react" configPage="configuration" />
```

DashboardLayout renderiza `<ConfigurationPage />` cuando recibe `configPage="configuration"`.

### Tabs

- **Apariencia**: temas predefinidos, edición de colores, y exportación JSON.
- **SMTP**: configuración del servidor de correo saliente desde `/api/system-settings`.
- **Rix IA**: proveedor, modelo principal, modelo de respaldo, límites, y prompt desde `/api/system-settings`.
- **Seguridad**: controles operativos de sesión y auditoría.
- **Organización**: datos de clínica y formato regional.
- **Notificaciones**: reglas de avisos y resúmenes.
- **Integraciones**: API base, webhook, FHIR, y sincronización de reloj.
- **Credenciales API**: usa `GET /api/oauth-clients`,
  `POST /api/oauth-clients`, y `POST /api/auth/token` para crear client ID,
  client secret, y token.
- **Datos**: retención, backups, exportación, y anonimización.

> **Note:** La página ya llama a `GET /api/system-settings`,
> `PUT /api/system-settings`, y `POST /api/system-settings/smtp/test`. Si el
> backend todavía no expone esos endpoints, se muestra un estado de endpoint
> pendiente en vez de persistir en `localStorage`.

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
