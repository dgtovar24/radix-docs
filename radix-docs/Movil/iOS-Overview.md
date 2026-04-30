---
title: iOS App Overview
description: Aplicación iOS de Radix - Expo SDK 52, React Native, Expo Router
author: Documentation Bot
date: 2026-04-27
tags:
  - mobile
  - ios
  - expo
  - react-native
module: Movil
status: active
---

# iOS App Overview

## Descripción General

Aplicación iOS (y Android) del sistema Radix para pacientes de medicina nuclear. Usa Expo con file-based routing.

## Información Base

| Propiedad | Valor |
|-----------|-------|
| **Framework** | Expo SDK 52 |
| **UI** | React Native 0.76 |
| **Routing** | Expo Router (file-based) |
| **Lenguaje** | TypeScript strict mode |
| **Arquitectura** | New Architecture enabled |
| **API Base** | `http://localhost:8080/v2` (dev) |

## Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework | Expo | 52.0.46 |
| UI | React Native | 0.76.9 |
| Routing | Expo Router | 4.0.19 |
| Navigation | React Navigation | 7.x |
| Animations | Reanimated | 3.16.7 |
| Gestures | Gesture Handler | 2.20.2 |
| Storage | Secure Store | 14.0.1 |
| Notifications | Expo Notifications | 0.31.1 |
| Icons | react-native-svg | 15.8.0 |

## Arquitectura de Archivos

```
src/
├── app/                  # Expo Router screens (file-based routing)
│   ├── _layout.tsx      # Root layout con navegación
│   ├── index.tsx        # Redirect a login
│   ├── login.tsx        # Pantalla de login
│   ├── dashboard.tsx    # Dashboard principal
│   ├── profile.tsx       # Perfil de usuario
│   ├── settings.tsx      # Configuración
│   ├── health.tsx        # Métricas de salud
│   ├── treatment.tsx     # Info del tratamiento
│   └── alerts.tsx        # Alertas médicas
├── types/
│   └── index.ts          # TypeScript interfaces (mirrors JPA entities)
├── services/
│   └── api.ts            # Cliente API centralizado
├── hooks/
│   ├── useAuth.ts        # Hook de autenticación
│   └── useApi.ts         # Hook para llamadas API
└── utils/
    └── date.ts           # Utilidades de fecha
```

## Rutas (Expo Router)

| Ruta | Descripción |
|------|-------------|
| `/` | Redirect a `/login` |
| `/login` | Pantalla de login |
| `/dashboard` | Dashboard principal |
| `/profile` | Perfil del usuario |
| `/settings` | Configuración |
| `/health` | Métricas de salud |
| `/treatment` | Información del tratamiento |
| `/alerts` | Alertas médicas |

## Tipos TypeScript

Los tipos en `src/types/index.ts` reflejan las entidades JPA del backend:

```typescript
export interface User {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  role: 'Doctor' | 'patient' | string;
  createdAt: string;
}

export interface Patient {
  id: number;
  fullName: string;
  phone?: string;
  address?: string;
  isActive: boolean;
  familyAccessCode: string;
  fkUserId: number;
  fkDoctorId?: number;
  createdAt: string;
  user?: User;
  doctor?: User;
}

export interface HealthMetrics {
  id: number;
  fkTreatmentId: number;
  fkPatientId: number;
  bpm: number;
  steps: number;
  distance: number;
  currentRadiation: number;
  recordedAt: string;
}

export interface Treatment {
  id: number;
  fkPatientId: number;
  fkDoctorId: number;
  fkRadioisotopeId: number;
  fkSmartwatchId: number;
  fkUnitId: number;
  room: number;
  initialDose: number;
  safetyThreshold: number;
  isolationDays: number;
  startDate: string;
  endDate: string;
  isActive: boolean;
}

export interface DoctorAlert {
  id: number;
  fkPatientId: number;
  fkTreatmentId: number;
  alertType: string;
  message: string;
  isResolved: boolean;
  createdAt: string;
}
```

## API Service

```typescript
const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? 'http://localhost:8080/v2';

export const api = {
  get: <T>(endpoint: string, token?: string) =>
    request<T>(endpoint, { method: 'GET', token }),

  post: <T>(endpoint: string, body: unknown, token?: string) =>
    request<T>(endpoint, { method: 'POST', body: JSON.stringify(body), token }),
  // ...
};
```

### Servicios

```typescript
export const authService = {
  login: (email: string, password: string) =>
    api.post<{ token: string; userId: number; role: string }>('/api/auth/login', { email, password }),

  register: (data) =>
    api.post<{ message: string; userId: number }>('/api/auth/register', data),

  getProfile: (token: string) =>
    api.get<{ id: number; fullName: string }>('/api/patients/profile/:userId', token),
};

export const patientService = {
  register: (data) =>
    api.post<{ message: string; userId: number }>('/api/patients/register', data),

  getAll: (token: string) =>
    api.get<Array<{ id: number; fullName: string }>>('/api/patients', token),

  getById: (id: number, token: string) =>
    api.get<{ id: number; fullName: string }>(`/api/patients/${id}`, token),
};

export const userService = {
  getAll: (token: string) =>
    api.get<User[]>('/api/users', token),

  getByRole: (role: string, token: string) =>
    api.get<User[]>(`/api/users/role/${role}`, token),
};
```

## Hook useAuth

```typescript
export function useAuth() {
  const [state, setState] = useState<AuthState>({
    token: null,
    userId: null,
    role: null,
    loading: true,
  });

  const login = async (token: string, userId: number, role: string) => {
    await SecureStore.setItemAsync('auth_token', token);
    await SecureStore.setItemAsync('user_id', String(userId));
    await SecureStore.setItemAsync('user_role', role);
    setState({ token, userId, role, loading: false });
  };

  const logout = async () => {
    await SecureStore.deleteItemAsync('auth_token');
    await SecureStore.deleteItemAsync('user_id');
    await SecureStore.deleteItemAsync('user_role');
    router.replace('/login');
  };

  return { ...state, login, logout, isAuthenticated, reload: loadAuth };
}
```

## Permisos iOS (Info.plist)

```json
{
  "NSHealthShareUsageDescription": "Radix needs access to your health data...",
  "NSHealthUpdateUsageDescription": "Radix needs to write health data...",
  "NSLocationWhenInUseUsageDescription": "Radix uses your location...",
  "NSLocationAlwaysAndWhenInUseUsageDescription": "Radix uses your location continuously...",
  "UIBackgroundModes": ["location", "fetch", "remote-notification"]
}
```

## Commands

```bash
# Install deps
npm install

# Dev server
npx expo start

# Run on iOS
npx expo run:ios

# Run on Android
npx expo run:android

# Type check
npm run typecheck

# Lint
npm run lint
```

## Variabled de Entorno

| Variable | Default | Descripción |
|----------|---------|-------------|
| EXPO_PUBLIC_API_URL | `http://localhost:8080/v2` | URL base del API |

## Consola iOS

```
Bundle ID: com.project.radix.app
App Version: 1.0.0
Build Number: 1
Supports Tablet: true
```

## Diferencias con Android App

| Feature | iOS (Expo) | Android (Kotlin) |
|---------|------------|------------------|
| Framework | React Native | Kotlin |
| Routing | Expo Router | Activities/Fragments |
| Auth Storage | SecureStore | DataStore |
| API Version | /v2 | /v2 |
| TypeScript | Yes | No |

## Ver También

- [[Movil/Android-Overview]] - App Android
- [[Backend/API-Overview]] - API que consume
- [[Reloj/Reloj-Overview]] - App del smartwatch