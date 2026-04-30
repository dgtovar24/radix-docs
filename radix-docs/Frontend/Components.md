---
title: Components
description: Catálogo de componentes React del frontend — arquitectura real
author: Documentation Bot
date: 2026-04-28
tags:
  - frontend
  - react
  - components
module: Frontend
status: active
---

# Components

## Estructura Real

```
radix-web/src/components/
├── DashboardLayout.tsx     # Layout principal (grid 3-columnas)
├── DashboardStats.tsx      # KPIs, gráfico, tareas
├── ThemeProvider.tsx       # Contexto de paleta + CSS variables
├── ConfigurationPage.tsx   # Selector de paletas y colores
├── LoginForm.tsx           # Formulario de login
```

Los componentes viven directamente en `src/components/` — no hay subcarpetas `auth/`, `layout/`, `users/`, `ui/`.

## DashboardLayout

**Archivo**: `DashboardLayout.tsx` (~450 líneas)

### Estructura

```tsx
// Wrapper exterior — provee ThemeProvider
export default function DashboardLayout(props: DashboardLayoutProps) {
  return (
    <ThemeProvider>
      <DashboardLayoutInner {...props} />
    </ThemeProvider>
  );
}

// Componente interno con toda la lógica y UI
function DashboardLayoutInner({ children, userName, userRole, configPage }) {
  // estado: activeNav
  // render: grid 3-columnas con sidebar (nav), main (children), sidebar derecha (activity feed)
}
```

### Por qué el wrapper

ThemeProvider se incrusta dentro de DashboardLayout para que **compartan el mismo React root**. En Astro, cada `client:load` es una isla independiente con su propio árbol de React. Si ThemeProvider fuera una isla separada, su contexto no sería visible para los componentes hijos.

### CSS Variables usadas para personalización en tiempo real

- `var(--b, #ffffff)` → fondo principal del grid
- `var(--sf, #ffffff)` → contenedor de sidebars (superficies elevadas)
- `var(--t, #111827)` → texto principal
- `var(--t-s, #6b7280)` → texto secundario
- `var(--br, #f3f4f6)` → bordes y divisores
- `var(--p, #60a5fa)` → acentos, botones primarios (Upgrade)
- `var(--s, #ef4444)` → estado de alertas, iconos secundarios

### Interfaz del Dashboard (Diseño Logip)

- **Left Sidebar**: Logo (`logip`), navegación médica principal (Pacientes, Tratamientos, etc.) con iconos lucide-react y banner de "Upgrade to Pro".
- **Right Sidebar**: Tarjeta de perfil detallada (Megan Norton con avatar) y un "Activity Feed" vertical con eventos de línea de tiempo y un input estilo píldora.

## DashboardStats

**Archivo**: `DashboardStats.tsx` (~260 líneas)

### Secciones

1. **KPI Row** — 3 indicadores (Finished, Tracked, Efficiency) integrados directamente en el fondo sin tarjetas, separados por divisores verticales.
2. **PerformanceChart** — Gráfico Recharts de doble línea (naranja y azul) con un área bajo la curva azul. Soporta un tooltip oscuro personalizado.
3. **Current Tasks** — Lista detallada de tareas ("Product Review", "UX Research") mostrando estados, iconos, responsables y duración.

### Variables de Color Dinámico

Todos los textos y formas geométricas del DashboardStats están mapeados a las variables `var(--...)` expuestas por el `ThemeProvider`, garantizando que cualquier cambio en la configuración se aplique instantáneamente sin recarga de página.

## ThemeProvider

**Archivo**: `ThemeProvider.tsx` (~130 líneas)

Ver [[Frontend/Theme-System]] para documentación completa.

### API

```typescript
const { palette, setPalette, updateColor, resetPalette, presets, isCustom } = useTheme();
```

## ConfigurationPage

**Archivo**: `ConfigurationPage.tsx` (~409 líneas)

### Tabs

- **TEMAS**: Grid de 8 paletas predefinidas (4 columnas)
- **PERSONALIZAR**: Selectores HTML (`<input type="color">`) que invocan directamente a `updateColor` para aplicar el tema instantáneamente a nivel de `:root`.
- **EXPORTAR**: Exportar/importar JSON de configuración.

## LoginForm

**Archivo**: `LoginForm.tsx`

### Funcionamiento

- Usa `fetch` para llamar al endpoint `/v2/api/auth/login`
- Guarda el usuario en cookie `radix-user` (JSON encodeado)
- Redirige a `/dashboard` tras login exitoso

## Ver También

- [[Frontend/Dashboard-Deep-Dive]] — Layout de 3 columnas
- [[Frontend/Theme-System]] — Sistema de paletas
- [[Frontend/Authentication]] — Sistema de autenticación
