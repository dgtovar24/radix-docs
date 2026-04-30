---
title: Android App Overview
description: Aplicación Android de Radix - medicina nuclear para pacientes
author: Documentation Bot
date: 2026-04-27
tags:
  - mobile
  - android
  - kotlin
  - gradle
module: Movil
status: active
---

# Android App Overview

## Descripción General

Aplicación Android para pacientes de medicina nuclear. Permite monitoreo de aislamiento domiciliario, login de usuarios y acceso familiar.

## Información Base

| Propiedad | Valor |
|-----------|-------|
| **Lenguaje** | Kotlin |
| **Min SDK** | 24 (Android 7.0) |
| **Target SDK** | 36 |
| **Build System** | Gradle 9.3.1 con AGP 9.1.0 |
| **API Base** | `https://api.raddix.pro/v2` |

## Arquitectura

```
App Entry: LogIn → MainActivity
                    ├── Home (Fragment)
                    ├── Rellotge (Fragment)
                    └── Configuracio (Fragment)
```

### Patrón

- **Package-by-feature**: Activities, fragments y ViewModels al mismo nivel
- **No DI framework**: Sin Hilt/Koin/Dagger
- **No repository pattern**: Llamadas directas desde ViewModels

## Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Language | Kotlin | - |
| Min SDK | 24 | Android 7.0 |
| Target SDK | 36 | Android 15 |
| Build | Gradle | 9.3.1 |
| AGP | Android Gradle Plugin | 9.1.0 |
| Networking | Retrofit + OkHttp | 2.9.0 / 4.12.0 |
| JSON | Gson | - |
| Async | Coroutines | 1.8.1 |
| Lifecycle | ViewModel + LiveData | 2.8.4 |
| UI | Material Design | 1.10.0 |

## Estructura del Proyecto

```
radix_app/
├── build.gradle.kts              # Root build
├── settings.gradle.kts
├── gradle.properties
├── app/
│   ├── build.gradle.kts          # App build (dependencias)
│   └── src/
│       └── main/
│           ├── java/com/example/radix/
│           │   ├── LogIn.kt          # Pantalla login
│           │   ├── MainActivity.kt   # Contenedor con bottom nav
│           │   ├── Home.kt           # Fragment home
│           │   ├── Rellotge.kt       # Fragment reloj (smartwatch)
│           │   ├── Configuracio.kt   # Fragment config
│           │   ├── AcessFamiliar.kt  # Login familiar
│           │   ├── CambiarPin.kt     # Cambio de PIN
│           │   ├── Retrofit/
│           │   │   ├── RadixAPI.kt       # Config Retrofit
│           │   │   ├── RadixService.kt    # Interface API
│           │   │   └── Model.kt          # Data classes
│           │   └── ViewModel/
│           │       ├── LoginViewModel.kt
│           │       └── ErrorDialog.kt
│           └── res/
│               ├── layout/
│               │   ├── activity_log_in.xml
│               │   ├── activity_main.xml
│               │   ├── fragment_home.xml
│               │   ├── fragment_rellotge.xml
│               │   └── fragment_configuracio.xml
│               └── values/
└── gradle/                       # Gradle wrapper
```

## Pantallas

### LogIn

Pantalla principal de autenticación.

**Campos**:
- ID/Email (EditText)
- PIN/Contraseña (EditText)

**Botones**:
- Login (btnLogin)
- "¿Olvidaste PIN?" (tvForgot) → [[Movil/CambiarPin|CambiarPin]]
- "Acceso Familiar" (btnFamily) → [[Movil/AcessFamiliar|AcessFamiliar]]

**Flujo**:
1. Usuario ingresa credenciales
2. ViewModel llama `POST /api/auth/login`
3. Si exitoso → redirige a [[Movil/MainActivity|MainActivity]]
4. Si error → muestra [[Movil/ErrorDialog|ErrorDialog]]

### MainActivity

Contenedor con BottomNavigationView.

**Tabs**:
- Home → [[Movil/Home|Home Fragment]]
- Rellotge → [[Movil/Rellotge|Rellotge Fragment]] (conecta con smartwatch)
- Configuracio → [[Movil/Configuracio|Configuracio Fragment]]

### Home Fragment

Pantalla principal después de login. Muestra:
- Bienvenida con nombre de usuario
- Stats de aislamiento
- Info del tratamiento

### Rellotge Fragment

Fragment que conecta con el reloj smarwatch del paciente. Ver [[Reloj/Reloj-Overview]].

### Configuracio Fragment

Configuración de la app:
- Cambiar PIN
- Preferencias
- Cerrar sesión

### AcessFamiliar

Pantalla de acceso para familiares. Usa `familyAccessCode` del paciente.

### CambiarPin

Pantalla para cambiar PIN/contraseña.

## API Integration

### RadixAPI

```kotlin
class RadixAPI {
    companion object {
        @Synchronized
        fun API(): RadixService {
            return Retrofit.Builder()
                .baseUrl("https://api.raddix.pro/v2/")
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build()
                .create(RadixService::class.java)
        }
    }
}
```

### RadixService

```kotlin
interface RadixService {
    @POST("api/auth/login")
    suspend fun login(@Body request: LoginRequest): Response<LoginResponse>

    @POST("api/auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<RegisterResponse>
}
```

### Models

```kotlin
data class LoginRequest(
    val email: String,
    val password: String
)

data class LoginResponse(
    val id: Int,
    val firstName: String,
    val role: String
)

data class RegisterRequest(
    val firstName: String,
    val lastName: String,
    val email: String,
    val password: String
)
```

## ViewModels

### LoginViewModel

Maneja la lógica de autenticación.

**Estado**:
- `loginActionEvent`: LoginAction.SUCCESS o NONE
- `errorMessage`: String de error o null
- `userData`: LoginResponse con datos del usuario

**Métodos**:
- `login(email, password)`: Hace llamada al API
- `resetEvent()`: Resetea el evento de login
- `resetError()`: Resetea el mensaje de error

## Dependencias Principales

```kotlin
// Networking
implementation("com.squareup.retrofit2:retrofit:2.9.0")
implementation("com.squareup.retrofit2:converter-gson:2.9.0")
implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

// Lifecycle
implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.4")
implementation("androidx.lifecycle:lifecycle-livedata-ktx:2.8.4")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.1")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

// DataStore
implementation("androidx.datastore:datastore-preferences:1.1.1")

// UI
implementation("com.google.android.material:material:1.10.0")
```

## Build Commands

```bash
# Debug APK
./gradlew assembleDebug

# Release APK
./gradlew assembleRelease

# Dependencies tree
./gradlew dependencies
```

## Integración con Backend

El app Android consume los endpoints de [[Backend/API-Overview]]:

| Método | Path | Uso |
|--------|------|-----|
| POST | `/v2/api/auth/login` | Login de paciente |
| POST | `/v2/api/auth/register` | Registro de paciente |

> [!note] API Version
> El app usa `/v2/` mientras que [[Frontend/Frontend-Overview]] usa `/v1/`. Posible inconsistencia a normalizar.

## Ver También

- [[Movil/AcessFamiliar]] - Acceso familiar
- [[Reloj/Reloj-Overview]] - App del smartwatch
- [[Backend/API-Overview]] - API que consume