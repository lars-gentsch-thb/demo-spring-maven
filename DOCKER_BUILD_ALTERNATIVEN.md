# Spring Boot Container Build Alternativen zu Jib

## 1. Spring Boot Buildpacks (EMPFOHLEN)

### Maven Kommandos:
```bash
# Image bauen
mvn spring-boot:build-image

# Image bauen und zu Registry pushen
mvn spring-boot:build-image -Dspring-boot.build-image.publish=true
```

### GitHub Actions Workflow:
```yaml
name: Docker Image CI with Buildpacks

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'adopt'
        cache: maven
    - name: Build and push Docker image with Buildpacks
      run: mvn spring-boot:build-image -Dspring-boot.build-image.publish=true
      env:
        DOCKER_HUB_USERNAME: ${{ secrets.DOCKER_HUB_USERNAME }}
        DOCKER_HUB_TOKEN: ${{ secrets.DOCKER_HUB_TOKEN }}
```

### Vorteile:
- ✅ Offiziell von Spring unterstützt
- ✅ Kein Dockerfile nötig
- ✅ Automatische Optimierungen
- ✅ Bereits im spring-boot-maven-plugin enthalten

---

## 2. Jib (Google) - AKTUELL IN VERWENDUNG

### Maven Kommandos:
```bash
# Image bauen und pushen
mvn compile jib:build

# Image lokal bauen (Docker Daemon)
mvn compile jib:dockerBuild
```

### GitHub Actions Workflow:
```yaml
- name: Build and push with Jib
  run: mvn -B package jib:build
  env:
    DOCKER_HUB_USERNAME: ${{ secrets.DOCKER_HUB_USERNAME }}
    DOCKER_HUB_TOKEN: ${{ secrets.DOCKER_HUB_TOKEN }}
```

### Vorteile:
- ✅ Sehr schnell durch intelligentes Layer-Caching
- ✅ Kein Docker Daemon erforderlich
- ✅ Reproduzierbare Builds

---

## 3. Spotify dockerfile-maven-plugin

### pom.xml Konfiguration:
```xml
<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>dockerfile-maven-plugin</artifactId>
    <version>1.4.13</version>
    <configuration>
        <repository>docker.io/larsgentschthb/demo-spring-maven</repository>
        <tag>${project.version}</tag>
        <useMavenSettingsForAuth>true</useMavenSettingsForAuth>
    </configuration>
    <executions>
        <execution>
            <id>default</id>
            <phase>package</phase>
            <goals>
                <goal>build</goal>
                <goal>push</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Nachteile:
- ⚠️ Projekt wird nicht mehr aktiv gewartet
- ⚠️ Benötigt Dockerfile

---

## 4. Fabric8 docker-maven-plugin

### pom.xml Konfiguration:
```xml
<plugin>
    <groupId>io.fabric8</groupId>
    <artifactId>docker-maven-plugin</artifactId>
    <version>0.44.0</version>
    <configuration>
        <images>
            <image>
                <name>docker.io/larsgentschthb/demo-spring-maven:${project.version}</name>
                <build>
                    <from>eclipse-temurin:17-jre</from>
                    <assembly>
                        <descriptorRef>artifact</descriptorRef>
                    </assembly>
                    <cmd>
                        <shell>java -jar maven/${project.build.finalName}.jar</shell>
                    </cmd>
                </build>
            </image>
        </images>
        <authConfig>
            <username>${env.DOCKER_HUB_USERNAME}</username>
            <password>${env.DOCKER_HUB_TOKEN}</password>
        </authConfig>
    </configuration>
</plugin>
```

### Maven Kommandos:
```bash
mvn docker:build docker:push
```

---

## 5. Klassisches Dockerfile + Maven

Deine aktuelle Alternative in docker.yml - nutzt separates Dockerfile.

---

## Vergleich & Empfehlung

| Plugin | Dockerfile nötig | Docker Daemon | Multi-Platform | Wartung | Empfehlung |
|--------|-----------------|---------------|----------------|---------|------------|
| **Spring Boot Buildpacks** | ❌ | ✅ | ✅ | ✅ Aktiv | ⭐⭐⭐⭐⭐ BESTE für Spring Boot |
| **Jib** | ❌ | ❌ | ✅ | ✅ Aktiv | ⭐⭐⭐⭐⭐ BESTE Performance |
| Fabric8 | ❌ | ✅ | ✅ | ✅ Aktiv | ⭐⭐⭐ |
| Spotify | ✅ | ✅ | ⚠️ | ❌ Deprecated | ⭐ |
| Klassisch | ✅ | ✅ | ✅ | Manual | ⭐⭐ |

### Meine Empfehlung:
**Für Spring Boot: Spring Boot Buildpacks**
- Native Spring Integration
- Keine zusätzliche Dependency
- Automatische Best Practices

**Für maximale Performance: Jib** (deine aktuelle Wahl)
- Schnellste Build-Zeiten
- Kein Docker Daemon nötig

