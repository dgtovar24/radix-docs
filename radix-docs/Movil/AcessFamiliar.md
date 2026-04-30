---
title: AcessFamiliar
description: Pantalla de acceso familiar para familiares de pacientes
author: Documentation Bot
date: 2026-04-27
tags:
  - mobile
  - android
  - familia
  - access
module: Movil
status: active
---

# AcessFamiliar

## Descripción

Pantalla para que familiares de pacientes puedan acceder a información limitada del paciente usando un código de acceso familiar.

## Funcionalidad

Los familiares pueden ver:
- Estado del paciente
- Información general del tratamiento
- Métricas de salud (sin datos sensibles)

## Código de Acceso

Cada paciente tiene un `familyAccessCode` único generado como:

```
FAM-XXXXXXXX
```

## Flujo

1. Familiar abre la app
2. Selecciona "Acceso Familiar"
3. Ingresa el código de acceso
4. Ve información read-only del paciente

## Notas de Implementación

- No requiere login completo
- Solo acceso a información no sensible
- Para más detalles, contactar al doctor

## Ver También

- [[Movil/Android-Overview]] - App Android general
- [[Backend/Entities-Overview]] - Entidad Patient con familyAccessCode