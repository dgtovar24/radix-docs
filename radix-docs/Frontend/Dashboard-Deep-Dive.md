---
title: Dashboard Deep Dive
description: Análisis detallado del layout del dashboard, sidebar, activity feed, KPIs y tareas
author: Documentation Bot
date: 2026-04-28
tags:
  - frontend
  - dashboard
  - layout
  - activity
  - kpi
module: Frontend
status: active
---

# Dashboard Deep Dive

## DashboardLayout

**Ubicación**: `src/components/DashboardLayout.tsx`  
**Líneas**: ~450

### Props

```typescript
interface DashboardLayoutProps {
  children: React.ReactNode;
  userName: string;
  userRole: string;
  configPage?: 'configuration' | 'patients' | 'treatments' | 'devices';
}
```

Cuando `configPage` está presente, DashboardLayout renderiza el componente correspondiente en lugar de `children`. Esto permite que `/configuracion` use el mismo layout sin necesidad de islas separadas.

### Estructura Visual

```
┌────────────┬───────────────────────────────┬──────────────┐
│  LEFT      │         MAIN CONTENT          │    RIGHT     │
│  SIDEBAR   │                               │   ACTIVITY   │
│  240px     │          1fr                  │    340px     │
│            │                               │              │
│  logip     │  [Header: greeting + date]    │  [Profile]   │
│  ──────    │                               │  ┌────────┐  │
│  MENU      │  [KPI Row: 3 stats]           │  │ Avatar │  │
│  Dashboard │                               │  │ Name   │  │
│  Pacientes │  [Performance Chart]          │  │ Role   │  │
│  Tratam.   │                               │  │ [FABs] │  │
│  Alertas   │  [Current Tasks]              │  └────────┘  │
│  ──────    │                               │              │
│  Upgrade   │                               │  [Activity]  │
│  Config.   │                               │  ┌────────┐  │
│  Logout    │                               │  │Timeline│  │
│            │                               │  └────────┘  │
│            │                               │  [Input]     │
└────────────┴───────────────────────────────┴──────────────┘
```

Layout usa CSS Grid con 3 columnas fijas:

```tsx
<div style={{
  display: 'grid',
  gridTemplateColumns: '240px 1fr 340px',
  minHeight: '100vh',
  background: 'var(--b, #ffffff)',
}}>
```

### Left Sidebar (240px)

- Logo "logip" (diseño de cuadrados vectoriales)
- Sección "Menú": Dashboard, Pacientes, Tratamientos, Alertas, Usuarios, Chat interno, Rix y Configuración. Usa `lucide-react`.
- Facultativos ya no existe como página separada; se administra desde Usuarios.
- "Upgrade to Pro" card con fondo dinámico claro (`var(--b)` vs `var(--sf)`).
- Botones de Configuración y Cerrar Sesión en el footer.
- Fondo: `var(--sf, #ffffff)` — cambia con la paleta.

### Main Content (1fr)

- Renderiza `children` o `configPage` condicionalmente.
- Padding: `32px 40px`, scroll vertical automático.

### Right Sidebar / Activity Feed (340px)

- **Fondo opaco** (`var(--sf)`) sobre el borde gris.
- **Profile Card**: Tarjeta flotante gris claro (`var(--b)`) con avatar centrado, nombre (Megan Norton), handle, y 3 FABs (Phone, Video, MoreVertical).
- **Activity Feed**: Timeline de eventos recientes con avatares (Pravatar).
  - Comentarios sobre proyectos con contenedores de borde redondeado.
  - Adjuntos de archivos (ej. Figma `.fig`) con peso de archivo y botón de descarga.
- **Message Input**: Input píldora en la base con botones de adjunto (Paperclip), Smile y Micrófono.

## Navegación

El sidebar usa `window.location.pathname` para detectar la ruta activa y marcarla cambiando el color del texto y la opacidad del icono:

```typescript
useEffect(() => {
  const path = window.location.pathname;
  if (path.includes('dashboard')) setActiveNav('home');
  if (path.includes('configuracion')) setActiveNav('settings');
}, []);
```

## DashboardStats

**Ubicación**: `src/components/DashboardStats.tsx`  
**Líneas**: ~260

### KPIs

3 indicadores en fila flexible **sin contenedores de tarjeta**, con divisores verticales.

| KPI | Valor | Trend |
|-----|-------|-------|
| Finished | 18 | +8 tasks |
| Tracked | 31h | -6 hours |
| Efficiency | 93% | +12% |

Cada KPI tiene:
- **Icono circular** (48px, fondo `var(--b)` con borde) a la izquierda.
- **Título** (`var(--t)`).
- **Trend** verde/rojo alineado con la métrica principal.
- **Divisor vertical** (1px × 40px, `var(--br)`) entre KPIs.

### PerformanceChart

Gráfico de línea dual con Recharts:
- **Área bajo la curva**: gradiente `var(--p)` (primario, azul).
- **Línea Superior**: `var(--p)`, 2px, con puntos (dots).
- **Línea Inferior**: `var(--s)` (secundario, naranja), 2px, sin puntos.
- **Grid**: Solo líneas verticales (`var(--br)`).
- **Tooltip**: Fondo oscuro `#0f172a`, bordes redondeados 12px, mostrando la comparativa de ambos meses.
- **Date dropdown**: pill "01-07 May ▾" en el header.

### Current Tasks

Lista de 3 tareas con:
- **Icono circular** (44px, fondo temático según estado).
- **Título** (14px, `fontWeight: 600`, `color: var(--t)`).
- **Estado** (dot de color + texto).
- **Tiempo** (icono reloj + horas).
- **Menú** (tres puntos `MoreHorizontal`, 20px).

## Integración con Astro

### dashboard.astro

```astro
<body style="background: var(--b, #ffffff);">
  <ThemeProvider client:load>
    <DashboardLayout client:load userName={userName} userRole={userRole}>
      <DashboardStats client:load />
    </DashboardLayout>
  </ThemeProvider>
</body>
```

### configuracion.astro

```astro
<body style="background: var(--b, #ffffff);">
  <DashboardLayout client:only="react" userName={userName} userRole={userRole} configPage="configuration" />
</body>
```

> [!important] Astro Islands y Contexto
> ThemeProvider y DashboardLayout NO pueden ser islas separadas porque React context no cruza entre islas. La solución: ThemeProvider se importa y renderiza **dentro** de DashboardLayout, formando una sola isla.

## Ver También

- [[Frontend/Theme-System]] — Sistema de paletas y CSS variables
- [[Frontend/Components]] — Componentes React
- [[Frontend/Pages-Deep-Dive]] — Páginas Astro
