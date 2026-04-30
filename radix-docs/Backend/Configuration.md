---
title: Configuration Files
description: Archivos de configuración de radix-api - pom.xml, application.yml, Dockerfile
author: Documentation Bot
date: 2026-04-27
tags:
  - backend
  - configuration
  - docker
  - maven
module: Backend
status: active
---

# Configuration Files

## Archivos de Configuración

| Archivo | Propósito |
|---------|----------|
| `pom.xml` | Dependencias Maven y build |
| `application.yml` | Configuración local (H2) |
| `application-prod.yml` | Configuración producción (MySQL) |
| `Dockerfile` | Imagen Docker multi-stage |
| `.env.example` | Variables de entorno de ejemplo |

---

## pom.xml

Ubicación: `/radix-api/pom.xml`

### Dependencias Principales

```xml
<!-- Spring Boot Starters -->
spring-boot-starter-web
spring-boot-starter-data-jpa
spring-boot-starter-test
spring-boot-starter-actuator

<!-- Database -->
mysql-connector-j (runtime)
h2 (runtime)

<!-- FHIR -->
hapi-fhir-base
hapi-fhir-structures-r4
hapi-fhir-server

<!-- Utilities -->
lombok
spring-boot-devtools
```

### Plugins

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
</plugin>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.14.1</version>
</plugin>
```

---

## application.yml

Ubicación: `src/main/resources/application.yml`

Configuración por defecto (desarrollo).

```yaml
spring:
  application:
    name: radix

  datasource:
    url: jdbc:h2:mem:radixdb
    driver-class-name: org.h2.Driver
    username: sa
    password:

  h2:
    console:
      enabled: true

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    database-platform: org.hibernate.dialect.H2Dialect

server:
  port: 8080
  servlet:
    context-path: /v1

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
```

### Características

- H2 en memoria
- Consola H2 habilitada (`/h2-console`)
- `ddl-auto: update` - crea/actualiza tablas automáticamente
- Context path: `/v1`

---

## application-prod.yml

Ubicación: `src/main/resources/application-prod.yml`

```yaml
spring:
  datasource:
    url: jdbc:mysql://${DB_HOST:132.145.194.97}:${DB_PORT:3306}/${DB_NAME:radixDB}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: ${DB_USER:root}
    password: ${DB_PASSWORD:Diegoelmejor1.0}
  jpa:
    database-platform: org.hibernate.dialect.MySQLDialect
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQLDialect

server:
  port: ${SERVER_PORT:8080}
  servlet:
    context-path: ${CONTEXT_PATH:/v1}

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always

logging:
  level:
    com.project.radix: INFO
    org.springframework.web: WARN
```

### Variables de Entorno

| Variable | Default | Descripción |
|----------|---------|-------------|
| DB_HOST | 132.145.194.97 | Host de MySQL |
| DB_PORT | 3306 | Puerto de MySQL |
| DB_NAME | radixDB | Nombre de DB |
| DB_USER | root | Usuario de MySQL |
| DB_PASSWORD | Diegoelmejor1.0 | Contraseña de MySQL |
| SERVER_PORT | 8080 | Puerto del servidor |
| CONTEXT_PATH | /v1 | Path del contexto |

> [!warning]
> Las credenciales por defecto están en texto plano. No usar en producción.

---

## Dockerfile

Ubicación: `/radix-api/Dockerfile`

```dockerfile
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

RUN chmod +x mvnw && ./mvnw dependency:go-offline -q

COPY src src
RUN ./mvnw clean package -DskipTests -q

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
  CMD wget -qO- http://localhost:8080/v1/ || exit 1

ENTRYPOINT ["java", "-Dspring.profiles.active=prod", "-jar", "app.jar"]
```

### Explicación

1. **Build stage**: Compila el proyecto con JDK 21
2. **Runtime stage**: Ejecuta con JRE 21
3. **Health check**: Verifica endpoint `/v1/`
4. **Profile**: Activa `prod` para MySQL

---

## .env.example

```bash
SPRING_DATASOURCE_URL=jdbc:mysql://132.145.194.97:3306/radixDB
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=Diegoelmejor1.0
SPRING_JPA_HIBERNATE_DDL_AUTO=none
SPRING_JPA_SHOW_SQL=true
SERVER_PORT=8081
```

---

## docker-compose.yml

Ubicación: `/radix-api/docker-compose.yml`

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_NAME=radixDB
      - DB_USER=root
      - DB_PASSWORD=test
    depends_on:
      - mysql

  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: test
      MYSQL_DATABASE: radixDB
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

---

## Configuración de Profile

### Activación de Profiles

| Entorno | Activación |
|---------|------------|
| Local (H2) | default (sin flags) |
| Producción | `-Dspring.profiles.active=prod` |

### Ejecutar Local

```bash
./mvnw spring-boot:run
# Usa application.yml (H2)
```

### Ejecutar Producción

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=prod
# Usa application-prod.yml (MySQL)
```

---

## Ver También

- [[Backend/Deployment]] - Despliegue en Dokploy
- [[Backend/Tech-Stack]] - Tecnologías usadas
- [[Backend/Database-Schema]] - Configuración de DB