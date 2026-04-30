---
title: Smartwatch App Overview
description: Aplicación Wear OS para smartwatch - monitoreo de salud en tiempo real
author: Documentation Bot
date: 2026-04-27
tags:
  - mobile
  - smartwatch
  - wear-os
  - kotlin
  - compose
module: Reloj
status: active
---

# Smartwatch App Overview

## Descripción General

Aplicación Wear OS para smartwatches que monitorea constantes vitales del paciente durante el tratamiento de medicina nuclear.

## Información Base

| Propiedad | Valor |
|-----------|-------|
| **Plataforma** | Wear OS (Android) |
| **Lenguaje** | Kotlin |
| **UI** | Jetpack Compose |
| **Min SDK** | 30 (Android 11) |
| **Target SDK** | 36 |
| **Package** | `com.radioisotopos.radix` |

## Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Language | Kotlin | - |
| UI | Jetpack Compose | 1.3.0 (wear) |
| Compose Material3 | Material3 | 1.2.1 |
| Wear OS | Wear Compose | 1.3.0 |
| Navigation | Wear Navigation | 1.3.0 |
| Health | Health Services Client | 1.0.0-rc02 |
| Networking | Retrofit + Gson | 2.9.0 |
| Async | Coroutines | 1.7.3 |

## Estructura del Proyecto

```
radix_reloj/
├── build.gradle.kts              # Root build
├── settings.gradle.kts
├── gradle.properties
├── app/
│   ├── build.gradle.kts         # App build
│   └── src/main/java/com/radioisotopos/radix/presentation/
│       ├── MainActivity.kt      # Entry point + navegación
│       ├── Screen.kt            # Rutas de navegación
│       ├── SplashActivity.kt    # Splash screen
│       ├── AlertaRadiacionDialog.kt
│       ├── MainScreen.kt        # Pantalla principal
│       ├── theme/
│       │   ├── Theme.kt
│       │   └── Color.kt
│       ├── menu/
│       │   ├── MenuScreen.kt
│       │   ├── PlaceholderScreens.kt
│       │   └── HealthScreen.kt
│       └── sensors/
│           └── HealthManager.kt  # Manejo de sensores
└── gradle/
```

## Navegación

```kotlin
sealed class Screen(val route: String) {
    object Main    : Screen("main")
    object Menu    : Screen("menu")
    object Power   : Screen("power")
    object Battery : Screen("battery")
    object Health  : Screen("health")
    object Patient : Screen("patient")
    object Game    : Screen("game")
}
```

### Flujo de Navegación

```
MainScreen (swipe down) → MenuScreen
                               ├── PowerScreen
                               ├── BatteryScreen
                               ├── HealthScreen
                               ├── PatientScreen
                               ├── GameScreen
                               └── Home (back to Main)
```

## Pantallas

### MainScreen

Pantalla principal del reloj.

**Datos mostrados**:
- BPM (ritmo cardíaco) - tiempo real desde sensor
- Steps (pasos) - contador de actividad

**Interacciones**:
- Swipe down → Abre MenuScreen

### MenuScreen

Menú de navegación del reloj.

**Opciones**:
- Power → [[Reloj/PowerScreen|PowerScreen]]
- Battery → [[Reloj/BatteryScreen|BatteryScreen]]
- Health → [[Reloj/HealthScreen|HealthScreen]]
- Patient → [[Reloj/PatientScreen|PatientScreen]]
- Game → [[Reloj/GameScreen|GameScreen]]
- Home → Regresa a MainScreen

### HealthScreen

Muestra métricas de salud detalladas.

**Datos**:
- Ritmo cardíaco actual
- Historial de pasos
- Estado del sensor

### PatientScreen

Información del paciente.

**Datos**:
- Nombre del paciente
- Código de acceso familiar
- Estado del tratamiento

### GameScreen

Juego para engagement del paciente durante aislamiento.

### PowerScreen / BatteryScreen

Placeholder screens para información del dispositivo.

## Sensores (HealthManager)

```kotlin
class HealthManager(private val context: Context) {

    fun getHeartRateFlow(): Flow<Int> {
        // Recolecta datos del sensor de ritmo cardíaco
    }

    fun getStepsFlow(): Flow<Int> {
        // Recolecta datos del sensor de pasos
    }
}
```

### Permisos Requeridos

```kotlin
Manifest.permission.BODY_SENSORS         // Para heart rate
Manifest.permission.ACTIVITY_RECOGNITION // Para pasos
```

## MainActivity

```kotlin
class MainActivity : ComponentActivity() {

    private lateinit var healthManager: HealthManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        healthManager = HealthManager(this)

        setContent {
            RadixTheme {
                var bpmValue by remember { mutableStateOf("--") }
                var stepsValue by remember { mutableStateOf("--") }

                // Solicitar permisos
                // Recolectar datos de sensores
                // Navegación Compose
            }
        }
    }
}
```

### Flujo de Datos

1. Solicitar permisos (BODY_SENSORS, ACTIVITY_RECOGNITION)
2. Si concedidos, iniciar collectors de healthManager
3. BPM y Steps se actualizan en tiempo real
4. Pasar datos a MainScreen como props

## Diseño (Theme)

```kotlin
@Composable
fun RadixTheme(content: @Composable () -> Unit) {
    // Tema personalizado de la app
}
```

Colores definidos en `Color.kt`.

## Integración con Backend

```kotlin
// Dependencias de red ya incluidas
implementation("com.squareup.retrofit2:retrofit:2.9.0")
implementation("com.squareup.retrofit2:converter-gson:2.9.0")
```

> [!note]
> La integración con API está preparada pero no implementada aún.

### Datos que sincronizar

- BPM → [[Backend/Entities-Overview|HealthMetrics]]
- Steps → [[Backend/Entities-Overview|HealthLog]]
- Ubicación → [[Backend/Entities-Overview|RadiationLog]]

## Build Commands

```bash
# Debug APK
./gradlew assembleDebug

# Release APK
./gradlew assembleRelease
```

## Relación con Other Apps

Este reloj se vincula al paciente vía [[Backend/Entities-Overview|Smartwatch entity]]:
- Un paciente puede tener varios smartwatches
- El reloj registra datos que van a HealthMetrics y HealthLog
- Los datos aparecen en [[Movil/Android-Overview|Android app]] y [[Movil/iOS-Overview|iOS app]]

## Ver También

- [[Backend/Entities-Overview]] - Entidad Smartwatch
- [[Backend/Database-Schema]] - Tabla smartwatches
- [[Movil/Android-Overview]] - App Android (vinculada)
- [[Reloj/HealthManager]] - Documentación del manager de sensores