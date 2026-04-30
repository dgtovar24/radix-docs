---
title: Tech Stack Frontend
description: Stack tecnológico completo de radix-web - Astro 5, React 19, Tailwind CSS
author: Documentation Bot
date: 2026-04-27
tags:
  - frontend
  - tech-stack
  - astro
  - react
  - tailwind
module: Frontend
status: active
---

# Tech Stack Frontend

## Visión General

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework | Astro | 5.18.1 |
| UI Library | React | 19.2.4 |
| Styling | Tailwind CSS | 3.4.19 |
| Server | Node.js adapter | standalone |
| Charts | Recharts | 3.8.0 |
| Icons | Lucide React | 0.577.0 |
| Auth | Supabase SSR | 0.9.0 |
| Validation | Zod | 4.3.6 |
| Runtime | Node.js | 22 (production) |

---

## Astro 5.18.1

Framework web híbrido que permite SSR y generación estática.

### Configuración

```javascript
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import node from '@astrojs/node';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  output: 'server',
  adapter: node({
    mode: 'standalone',
  }),
  integrations: [react(), tailwind()],
  security: {
    checkOrigin: false,
  },
});
```

### Modo SSR

El sitio corre en modo **Server-side Rendering**:
- Cada request se rendered en el servidor
- Formularios y datos dinámicas funcionan sin JS del cliente
- Ideal para apps con autenticación

### Render Mode

| Modo | Uso |
|------|-----|
| `output: 'static'` | Generación estática (SSG) |
| `output: 'server'` | Server-side rendering (SSR) |
| `output: 'hybrid'` | Mixto (default es estático, rutas específicas son SSR) |

---

## React 19.2.4

Biblioteca UI para componentes interactivos.

### Uso en Astro

Los componentes se hidratan con directivas:
- `client:load` - Hydrate immediately
- `client:idle` - Hydrate when browser idle
- `client:visible` - Hydrate when visible
- `client:media` - Hydrate on media query

### Ejemplo

```astro
<LoginForm client:load />
```

### Componentes Principales

- LoginForm - Formulario de auth
- RegisterForm - Formulario de registro
- DashboardLayout - Layout principal
- ThemeProvider - Gestión de temas

---

## Tailwind CSS 3.4.19

Framework de utilidades para estilos.

### Configuración

```javascript
// tailwind.config.mjs
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      fontFamily: {
        'display': ['Outfit', 'sans-serif'],
        'sans': ['DM Sans', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
```

### CSS Variables en Tailwind

El theme usa CSS custom properties que Tailwind puede acceder:

```css
/* En componentes */
className="text-[var(--t)] bg-[var(--sf)]"
```

### Fuentes

| Familia | Uso | Google Fonts |
|---------|-----|--------------|
| Outfit | Headings, display | Yes |
| DM Sans | Body text | Yes |

---

## Node Adapter

Permite desplegar Astro como servidor Node.js.

### Build Output

```
dist/
└── server/
    └── entry.mjs    # Entry point para Node
```

### Ejecutar en Producción

```bash
node ./dist/server/entry.mjs
```

### Variables de Entorno

| Variable | Descripción |
|----------|-------------|
| HOST | Host del servidor (default: 0.0.0.0) |
| PORT | Puerto (default: 4321) |

---

## Recharts 3.8.0

Biblioteca de gráficos para React.

### Uso

```typescript
import { BarChart, Bar, XAxis, YAxis, Tooltip } from 'recharts';

// En componente
<BarChart data={data}>
  <Bar dataKey="value" fill="#6b32e8" />
  <XAxis dataKey="name" />
  <YAxis />
  <Tooltip />
</BarChart>
```

### Gráficos Disponibles

- BarChart
- LineChart
- PieChart
- AreaChart
- ComposedChart

---

## Lucide React 0.577.0

Biblioteca de iconos.

### Uso

```typescript
import { Heart, Users, Settings } from 'lucide-react';

// En JSX
<Heart className="w-5 h-5 text-red-500" />
<Users className="w-5 h-5" />
<Settings className="w-5 h-5" />
```

### Iconos Populares en el Proyecto

- Home, Settings, Users, Plus, Logout
- SVG components optimizados

---

## Supabase SSR 0.9.0

Autenticación y gestión de sesiones server-side.

### Uso (futuro)

```typescript
import { createServerClient } from '@supabase/ssr';

const supabase = createServerClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  cookies
);
```

### Estado Actual

El auth actual usa cookies propias + API de [[Backend/Auth]]. Supabase podría integrarse para:
- Auth más robusto
- Realtime subscriptions
- Storage

---

## Zod 4.3.6

Validación de esquemas.

### Uso

```typescript
import { z } from 'zod';

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

// En form
const result = LoginSchema.safeParse(formData);
if (!result.success) {
  // Manejar error
}
```

---

## Dependencias de Desarrollo

### @astrojs/tailwind 6.0.2

Integración de Tailwind en Astro.

### @types/react 19.2.14

Tipos TypeScript para React.

### @types/react-dom 19.2.3

Tipos para React DOM.

### @types/use-sync-external-store 1.5.0

Tipos para useSyncExternalStore.

### @types/ws 8.18.1

Tipos para WebSockets.

### pg 8.20.0

Cliente PostgreSQL (para будущее Supabase integration).

### typescript 5.9.3

Lenguaje TypeScript.

---

## Arquitectura de Rendering

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Browser   │────▶│  Node.js    │────▶│  MySQL DB   │
│   (React)   │◀────│  (Astro)    │◀────│  (radix-api)│
└─────────────┘     └─────────────┘     └─────────────┘
     Client           Server              External API
```

1. Browser hace request
2. Astro (Node) recibe en el server
3. Ejecuta lógica de page (fetch data si needed)
4. Renderiza HTML + hidrata React components
5. Cliente recibe página completa e interactiva

---

## Dockerfile

```dockerfile
# Builder stage
FROM oven/bun:1 AS builder
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --production
COPY . .
RUN bun run build

# Runner stage
FROM node:22-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 4321
CMD ["node", "dist/server/entry.mjs"]
```

---

## Ver También

- [[Frontend/Frontend-Overview]] - Vista general
- [[Frontend/Pages]] - Páginas y rutas
- [[Frontend/Components]] - Componentes React
- [[Backend/API-Overview]] - API que consume