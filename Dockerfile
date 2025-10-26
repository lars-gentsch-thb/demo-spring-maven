# Dockerfile for Spring Boot Application
# Requires pre-built JAR file
# Build first: mvn clean package

FROM eclipse-temurin:17-jre

LABEL maintainer="docker@thb.de"
LABEL description="Spring Boot Demo Application"

# Set working directory - all subsequent commands run from here
WORKDIR /app

# Copy the pre-built JAR file
COPY target/demo-0.0.1-SNAPSHOT.jar /app/service.jar

# Create non-root user for security
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# Expose port
EXPOSE 8080

# Health check - verifies the application is responding
# Note: Standard Debian-based image has curl pre-installed
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "/app/service.jar"]