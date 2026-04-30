---
title: Tech Stack
description: Stack tecnológico completo de radix-api - Java 21, Spring Boot 3.5.9, Maven, JPA
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - tech-stack
  - java
  - spring-boot
module: Backend
status: active
---

# Tech Stack

## Visión General

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Runtime | Java | 21 |
| Framework | Spring Boot | 3.5.9 |
| Build | Maven | wrapper |
| ORM | JPA / Hibernate | - |
| Database Dev | H2 | in-memory |
| Database Prod | MySQL | 8.x |
| FHIR | HAPI FHIR | 7.4.2 |
| Lombok | Lombok | 1.18.30 |

---

## Java 21

- **LTS Release**: Java 21 es versión de soporte a largo plazo
- **Features usadas**: Pattern matching, switch expressions, records
- **JVM Target**: 21

```xml
<java.version>17</java.version>
```

> [!note]
> El pom.xml dice Java 17, pero el Dockerfile usa eclipse-temurin:21.

---

## Spring Boot 3.5.9

Framework principal del backend.

### Dependencias Incluidas

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

---

## Maven

Gestión de dependencias y build.

### Wrapper

```bash
./mvnw clean package -DskipTests
```

### Plugins

- spring-boot-maven-plugin
- maven-compiler-plugin

---

## JPA / Hibernate

ORM para acceso a base de datos.

### Configuración

```yaml
spring:
  jpa:
    database-platform: org.hibernate.dialect.MySQLDialect
    hibernate:
      ddl-auto: update
    show-sql: false
```

### Entity Mapping

- Cada clase en `com.project.radix.Model` es una entidad JPA
- Tablas se crean automáticamente desde entidades
- Relaciones via `@ManyToOne`, `@OneToMany`

---

## H2 Database (Development)

Base de datos en memoria para desarrollo local.

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:radixdb
    driver-class-name: org.h2.Driver
    username: sa
    password:
```

### Características

- No requiere instalación
- Schema se auto-crea desde entidades
- Browser console disponible en: `http://localhost:8080/h2-console`

---

## MySQL (Production)

Base de datos de producción.

```yaml
spring:
  datasource:
    url: jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: ${DB_USER}
    password: ${DB_PASSWORD}
```

### Versión Recomendada

MySQL 8.x con character set `utf8mb4`.

---

## HAPI FHIR v7.4.2

Implementación de estándares FHIR para interoperabilidad médica.

```xml
<dependency>
    <groupId>ca.uhn.hapi.fhir</groupId>
    <artifactId>hapi-fhir-base</artifactId>
    <version>7.4.2</version>
</dependency>
<dependency>
    <groupId>ca.uhn.hapi.fhir</groupId>
    <artifactId>hapi-fhir-structures-r4</artifactId>
    <version>7.4.2</version>
</dependency>
<dependency>
    <groupId>ca.uhn.hapi.fhir</groupId>
    <artifactId>hapi-fhir-server</artifactId>
    <version>7.4.2</version>
</dependency>
```

> [!tip]
> Permite integración con otros sistemas de salud que usen el estándar FHIR R4.

---

## Lombok

Biblioteca para reducción de boilerplate.

```java
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Getters y setters generados automáticamente por Lombok
}
```

### Anotaciones Usadas

- `@Data` - Getters, setters, equals, hashCode, toString
- `@RequiredArgsConstructor` - Constructor con campos final

---

## Spring Boot Actuator

Monitoreo y health checks.

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### Endpoints Expuestos

- `/actuator/health`
- `/actuator/info`
- `/actuator/metrics`

---

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────┐
│           radix-api (Spring Boot)        │
├─────────────────────────────────────────┤
│  Controllers: Auth, User, Patient, Health │
│  Services: (pendientes de implementar)   │
│  Repositories: Spring Data JPA           │
├─────────────────────────────────────────┤
│           Model (JPA Entities)           │
│  User, Patient, Treatment, Smartwatch...  │
└────────────────┬────────────────────────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
   [H2 Dev]          [MySQL Prod]
```

---

## Ver También

- [[Backend/Deployment]] - Configuración de despliegue
- [[Backend/Database-Schema]] - Modelo de datos
- [[Backend/API-Overview]] - Endpoints del API