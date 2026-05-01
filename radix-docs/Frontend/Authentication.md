---
title: Authentication
description: Sistema de autenticación del frontend con cookies
author: Documentation Bot
date: 2026-04-28
tags:
  - frontend
  - auth
  - login
  - middleware
module: Frontend
status: active
---

# Authentication

This page explains the frontend session flow, the Astro API proxy, and how
authenticated pages read the current user.

## Cookie-Based Auth

El frontend usa una cookie `radix-user` en lugar de JWT tradicional:

```json
{
  "firstName": "Doctor",
  "role": "Doctor",
  "email": "radix@example.com"
}
```

### Login Flow

1. Usuario ingresa email/password en `LoginForm`
2. `LoginForm` llama `POST /api/auth/login`
3. El handler Astro llama `POST ${PUBLIC_API_URL}/api/auth/login`
4. Respuesta se guarda como cookie HTTP-only con `path=/; max-age=28800`
5. Redirección a `/dashboard`

```typescript
// pages/api/auth/login.ts
cookies.set('radix-user', encodeURIComponent(JSON.stringify({ email, ...data, role })), {
  path: '/',
  httpOnly: true,
  sameSite: 'lax',
  maxAge: 60 * 60 * 8,
});
```

The frontend login handler does not create a hardcoded admin session. All login
attempts go through the backend API.

## API proxy

Authenticated React components call `src/services/api.ts`, which targets
`/api/*`. Astro handles those requests with `src/pages/api/[...path].ts` and
forwards them to the configured backend base URL.

The proxy forwards:

- Request method and query string.
- JSON or form body.
- `Authorization: Bearer <token>` when the `radix-user` cookie contains a
  `token` or `id`.

Dedicated auth handlers still exist for login, register, and logout because
they manage the browser session cookie.

### Middleware Protection

```typescript
// src/middleware.ts
const PUBLIC_ROUTES = ['/login', '/register', '/api/auth/login', '/api/auth/register', '/api/auth/callback'];

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url;
  if (PUBLIC_ROUTES.some(r => pathname.startsWith(r))) return next();
  if (pathname.startsWith('/_astro') || pathname.startsWith('/favicon')) return next();

  const cookie = context.request.headers.get('cookie') ?? '';
  if (!cookie.includes('radix-user=')) {
    return context.redirect('/login');
  }
  return next();
});
```

### Page-Level User Data

Las páginas leen la cookie para extraer nombre, rol, email, and user ID:

```astro
---
const userCookie = Astro.cookies.get('radix-user')?.value;
let userName = 'Doctor';
let userRole = 'Doctor';
let userId = 0;

if (userCookie) {
  const user = JSON.parse(decodeURIComponent(userCookie));
  userName = user.firstName || user.email || 'Doctor';
  userRole = user.role || 'Doctor';
  userId = Number(user.id || 0);
}
---
```

`/mi-perfil` passes `userId` to `DashboardLayout`. The profile view then loads
the full editable profile with `GET /api/users/{id}` and saves changes with
`PUT /api/users/{id}`.

## Logout

No hay endpoint de logout. Se elimina la cookie del lado del cliente:

```typescript
document.cookie = 'radix-user=; path=/; max-age=0';
window.location.href = '/login';
```

## Ver También

- [[Frontend/Frontend-Overview]] — Vista general
- [[Frontend/Pages]] — Páginas y rutas
- [[Backend/API-Authentication]] — Endpoints de auth del backend
