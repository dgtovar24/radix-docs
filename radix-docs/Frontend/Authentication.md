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
2. `LoginForm` llama `POST /v2/api/auth/login`
3. Respuesta se guarda como cookie con `path=/; max-age=28800`
4. Redirección a `/dashboard`

```typescript
// LoginForm.tsx
if (res.ok) {
  const data = await res.json();
  document.cookie = `radix-user=${encodeURIComponent(JSON.stringify(data))}; path=/; max-age=28800`;
  window.location.href = '/dashboard';
}
```

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

Las páginas leen la cookie para extraer nombre y rol:

```astro
---
const userCookie = Astro.cookies.get('radix-user')?.value;
let userName = 'Doctor';
let userRole = 'Doctor';

if (userCookie) {
  const user = JSON.parse(decodeURIComponent(userCookie));
  userName = user.firstName || user.email || 'Doctor';
  userRole = user.role || 'Doctor';
}
---
```

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
