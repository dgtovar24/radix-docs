---
title: Inicio
description: Centro de documentación del proyecto Radix
author: Documentation Bot
date: 2026-04-28
tags:
  - index
  - overview
module: Root
status: active
---

# Radix — Documentación

Sistema de monitoreo médico para pacientes de terapia nuclear.

## Estructura del Proyecto

```
radix/
├── radix-api/       # Backend Spring Boot (Java 21, Maven)
├── radix-web/       # Frontend Astro + React (inline styles)
├── radix-ios/       # App iOS (Expo/React Native)
├── radix_app/       # App Android
├── radix_reloj/     # App smartwatch (Wear OS)
└── radix-docs/      # Documentación (Obsidian vault)
```

## Documentación por Módulo

### Backend
- [[Backend/API-Overview]] — Visión general de la API
- [[Backend/API-Authentication]] — Endpoints de autenticación
- [[Backend/API-Controllers]] — Controladores REST
- [[Backend/Database-Schema]] — Esquema de base de datos
- [[Backend/Deployment]] — Deploy con Dokploy
- [[Backend/Health]] — Health checks

### Frontend
- [[Frontend/Frontend-Overview]] — Visión general
- [[Frontend/Dashboard-Deep-Dive]] — Dashboard layout, KPIs, chat
- [[Frontend/Components]] — Catálogo de componentes React
- [[Frontend/Theme-System]] — Sistema de paletas y CSS variables
- [[Frontend/Authentication]] — Sistema de autenticación
- [[Frontend/Pages]] — Páginas Astro
- [[Frontend/Pages-Deep-Dive]] — Detalle de cada página
- [[Frontend/Tech-Stack]] — Stack tecnológico

### Arquitectura
- [[Arquitectura/Arquitectura]] — Arquitectura general del sistema

### Móvil
- [[Movil/iOS-Overview]] — App iOS
- [[Movil/Android-Overview]] — App Android
- [[Movil/AcessFamiliar]] — Acceso familiar

### Reloj
- [[Reloj/Reloj-Overview]] — App smartwatch

### Desarrollo
- [[Development-Setup]] — Setup de desarrollo
- [[Docker-Development]] — Desarrollo con Docker

## Cambios Recientes (Abril 2026)

### Frontend
- **Paletas de color funcionando**: 8 paletas, persistencia en localStorage, CSS variables aplicadas a componentes
- **ThemeProvider integrado en DashboardLayout**: soluciona el problema de Astro islands con contextos separados
- **Todos los estilos inline**: eliminado Tailwind de componentes, solo CSS variables
- **Chatbot rediseñado**: burbujas con bordes asimétricos, input pill integrado, sin send button azul
- **Dashboard refinado**: KPI layout corregido, tareas con columnas distribuidas, gráfico con área bajo la curva
- **Header simplificado**: greeting grande, sin perfil de usuario, fecha con borde sutil

### Backend
- API corriendo en `http://localhost:8080/v2`
- Endpoints activos: auth (login/register), patients, users, actuator/health
- H2 en memoria para desarrollo local

## Comandos Rápidos

```bash
# Backend
cd radix-api && ./mvnw spring-boot:run

# Frontend
cd radix-web && npm run dev

# Build
cd radix-web && npm run build
```
