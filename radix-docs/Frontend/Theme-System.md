---
title: Theme System
description: Sistema de paletas de color con CSS variables, React context y persistencia en localStorage
author: Documentation Bot
date: 2026-04-28
tags:
  - frontend
  - theme
  - css
  - colors
  - inline-styles
module: Frontend
status: active
---

# Theme System

## Arquitectura

El sistema usa **React Context** + **CSS Custom Properties** + **localStorage** para persistencia. No usa Tailwind — todos los estilos son inline.

```
┌─────────────────────────────────────────────────────────┐
│                  ThemeProvider.tsx                       │
│  ┌─────────────────────────────────────────────────┐    │
│  │  useState<ColorPalette>(loadSavedPalette())       │    │
│  │  useEffect → set CSS vars on :root                │    │
│  │  useEffect → savePalette() to localStorage        │    │
│  └─────────────────────────────────────────────────┘    │
│                    │                                    │
│         ThemeContext.Provider (value={...})              │
│                    │                                    │
│     ┌──────────────┼──────────────┐                     │
│     ▼              ▼              ▼                     │
│  DashboardLayout  DashboardStats  ConfigurationPage     │
│  (useTheme())     (no usa)       (useTheme())           │
└─────────────────────────────────────────────────────────┘
```

## CSS Variables

El `useEffect` del ThemeProvider aplica estas variables al `:root`:

| Variable | Propósito | Fallback |
|----------|-----------|----------|
| `--p` | Color primario | `#3b82f6` |
| `--p-l` | Primario claro | `#60a5fa` |
| `--s` | Secundario | `#1e40af` |
| `--b` | Fondo de página | `#f7f8fa` |
| `--sf` | Superficie (cards, sidebar) | `#ffffff` |
| `--t` | Texto principal | `#111827` |
| `--t-s` | Texto secundario | `#6b7280` |
| `--br` | Bordes | `#e5e7eb` |

### Consumo en componentes

```tsx
// Antes (hardcoded):
<div style={{ background: '#ffffff' }}>Card</div>

// Ahora (con CSS variable):
<div style={{ background: 'var(--sf, #ffffff)' }}>Card</div>
```

## Paletas

**Ubicación**: `src/data/palettes.ts`

8 paletas con 12 colores cada una:

| ID | Nombre | Primario |
|----|--------|----------|
| `hospital-purple` | Hospital Purple | `#6b32e8` |
| `ocean-depths` | Ocean Depths | `#0369a1` |
| `forest-sanctuary` | Forest Sanctuary | `#15803d` |
| `sunset-glow` | Sunset Glow | `#c2410c` |
| `midnight-command` | Midnight Command | `#818cf8` |
| `slate-elegance` | Slate Elegance | `#475569` |
| `rose-diagnostic` | Rose Diagnostic | `#be185d` |
| `teal-vital` | Teal Vital | `#0d9488` |

### Estructura de ColorPalette

```typescript
interface ColorPalette {
  id: string;
  name: string;
  description: string;
  isCustom?: boolean;
  colors: {
    primary: string;
    primaryLight: string;
    secondary: string;
    background: string;
    surface: string;
    text: string;
    textSecondary: string;
    accent: string;
    success: string;
    warning: string;
    error: string;
    border: string;
  };
}
```

## ThemeProvider

**Ubicación**: `src/components/ThemeProvider.tsx`

### API del Contexto

```typescript
interface ThemeContextType {
  palette: ColorPalette;
  setPalette: (palette: ColorPalette) => void;
  updateColor: (key: keyof ColorPalette['colors'], value: string) => void;
  resetPalette: () => void;
  presets: ColorPalette[];
  isCustom: boolean;
}
```

### Hook useTheme()

```typescript
export function useTheme(): ThemeContextType {
  const context = useContext(ThemeContext);
  if (!context) {
    // Fallback seguro — retorna no-ops
    return {
      palette: DEFAULT_PALETTE,
      setPalette: () => {},
      updateColor: () => {},
      resetPalette: () => {},
      presets: PRESET_PALETTES,
      isCustom: false,
    };
  }
  return context;
}
```

> [!warning] Contexto en Astro Islands
> Cada `client:load` / `client:only` en Astro crea su **propio React root**. El contexto de React no cruza entre islas. Por eso ThemeProvider se incrusta **dentro** de DashboardLayout (no como isla separada).

### Inicialización

ThemeProvider usa el initializer de `useState` para cargar la paleta guardada:

```typescript
const [palette, setPaletteState] = useState<ColorPalette>(() => {
  if (typeof window !== 'undefined') {
    return loadSavedPalette(); // Lee de localStorage
  }
  return DEFAULT_PALETTE;
});
```

### Efecto al cambiar paleta

```typescript
useEffect(() => {
  if (typeof document === 'undefined') return;
  const c = palette.colors;
  const root = document.documentElement;
  root.style.setProperty('--p', c.primary);
  root.style.setProperty('--p-l', c.primaryLight);
  root.style.setProperty('--s', c.secondary);
  root.style.setProperty('--b', c.background);
  root.style.setProperty('--sf', c.surface);
  root.style.setProperty('--t', c.text);
  root.style.setProperty('--t-s', c.textSecondary);
  root.style.setProperty('--br', c.border);
  
  // Dark mode toggle
  const isDark = c.background === '#0f172a' || c.background === '#000000';
  document.documentElement.className = isDark ? 'dark' : 'light';
  
  savePalette(palette);
}, [palette]);
```

## Persistencia

### localStorage

| Key | Tipo | Ejemplo |
|-----|------|---------|
| `radix-palette` | JSON string | `{"id":"teal-vital","name":"Teal Vital","colors":{...}}` |

### Funciones

```typescript
// Carga con validación
export function loadSavedPalette(): ColorPalette {
  const saved = localStorage.getItem('radix-palette');
  if (saved) {
    const parsed = JSON.parse(saved);
    if (parsed?.colors && parsed?.id) return parsed;
  }
  return DEFAULT_PALETTE;
}

// Guardado con try/catch
export function savePalette(palette: ColorPalette): void {
  localStorage.setItem('radix-palette', JSON.stringify(palette));
}
```

## Inline Script en .astro

Cada página tiene un `<script is:inline>` que aplica la paleta **antes** de que React hidrate, evitando flash de colores incorrectos:

```html
<script is:inline>
  (function() {
    var saved = localStorage.getItem('radix-palette');
    if (saved) {
      var p = JSON.parse(saved);
      var c = p.colors;
      var root = document.documentElement;
      root.style.setProperty('--p', c.primary);
      root.style.setProperty('--b', c.background);
      // ... todas las variables
    }
  })();
</script>
```

## Dark Mode

Se activa automáticamente cuando el fondo de la paleta es oscuro (`#0f172a` o `#000000`). El `<html>` recibe la clase `dark` o `light`.

## Ver También

- [[Frontend/Dashboard-Deep-Dive]] — Layout con CSS variables
- [[Frontend/Components]] — Componentes que usan el tema
- [[Frontend/Frontend-Overview]] — Visión general del frontend
