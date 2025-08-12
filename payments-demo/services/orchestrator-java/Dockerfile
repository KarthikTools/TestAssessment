FROM amazoncorretto:17-alpine as build

WORKDIR /workspace/app

# Copy gradle files
COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./
COPY gradle.properties ./

# Download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source code
COPY src src

# Build the application
RUN ./gradlew build -x test --no-daemon

# Runtime stage
FROM amazoncorretto:17-alpine

VOLUME /tmp

# Install curl for health checks
RUN apk add --no-cache curl

# Copy the built artifact
COPY --from=build /workspace/app/build/libs/*.jar app.jar

# Expose port
EXPOSE 8088

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8088/payments/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "/app.jar"]
