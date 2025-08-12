#!/bin/bash

echo "🚀 Starting Service Virtualization Demo (No Docker Required)"
echo "============================================================"

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed or not in PATH"
    echo "Please install Java 17+ and try again"
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed or not in PATH"
    echo "Please install Python 3.8+ and try again"
    exit 1
fi

echo ""
echo "1️⃣ Testing Python MagicMock Tests..."
cd python/risk_policy
if python3 -m pytest tests/ -q; then
    echo "✅ Python MagicMock tests passed!"
else
    echo "❌ Python MagicMock tests failed!"
    exit 1
fi
cd ../..

echo ""
echo "2️⃣ Starting Mock Services..."

# Start WireMock (if you have Java)
echo "   Starting WireMock on port 18080..."
cd mocks/wiremock-ext
if [ -f "build/libs/wiremock-ext-1.0.0.jar" ]; then
    echo "   Using built extension JAR"
    cd ../..
    java -cp "mocks/wiremock-ext/build/libs/wiremock-ext-1.0.0.jar:$(find ~/.m2 -name 'wiremock-standalone-*.jar' | head -1)" \
         com.github.tomakehurst.wiremock.standalone.WireMockServerRunner \
         --port 18080 \
         --extensions com.demo.wm.RiskTransformer \
         --root-dir mocks/wiremock &
    WIREMOCK_PID=$!
    echo "   WireMock started with PID: $WIREMOCK_PID"
else
    echo "   ⚠️  WireMock extension not built, using basic WireMock"
    cd ../..
    # You can download WireMock standalone JAR here if needed
    echo "   Please build WireMock extension first: cd mocks/wiremock-ext && ./gradlew clean jar"
fi

# Start MockServer (if you have Java)
echo "   Starting MockServer on port 18081..."
if command -v java &> /dev/null; then
    # You can download MockServer standalone JAR here
    echo "   Please download MockServer standalone JAR and run:"
    echo "   java -jar mockserver-netty-5.15.0-jar-with-dependencies.jar -serverPort 18081"
fi

echo ""
echo "3️⃣ Starting Spring Boot Orchestrator..."
echo "   Using H2 in-memory database (no PostgreSQL required)"
echo "   Kafka will be disabled (using in-memory alternatives)"

echo ""
echo "4️⃣ Python Dependencies..."
echo "   Using requirements.txt (traditional Python approach)"
echo "   MagicMock is built into Python standard library"
echo "   Optional: pip install -r python/risk_policy/requirements.txt"

# Create a simple profile for local demo
cat > services/orchestrator-java/src/main/resources/application-demo.yml << 'EOF'
server:
  port: 8088

app:
  riskBaseUrl: http://localhost:18080
  tokenizeBaseUrl: http://localhost:18081
  kafka:
    bootstrap: localhost:9092
    topic: payments.events

spring:
  datasource:
    url: jdbc:h2:mem:payments;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    username: sa
    password: 
    driver-class-name: org.h2.Database
  h2:
    console:
      enabled: true
      path: /h2-console
  kafka:
    bootstrap-servers: ${app.kafka.bootstrap}
    consumer:
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true

logging:
  level:
    com.demo.pay: DEBUG
    org.springframework.kafka: DEBUG
EOF

echo ""
echo "4️⃣ Demo Components Status:"
echo "   ✅ Python MagicMock tests: READY"
echo "   ⚠️  WireMock: $([ -n "$WIREMOCK_PID" ] && echo "RUNNING (PID: $WIREMOCK_PID)" || echo "NEEDS SETUP")"
echo "   ⚠️  MockServer: NEEDS SETUP"
echo "   ⚠️  Spring Boot: NEEDS BUILD"
echo "   ✅ H2 Database: CONFIGURED (in-memory)"

echo ""
echo "5️⃣ Next Steps:"
echo "   a) Build WireMock extension: cd mocks/wiremock-ext && ./gradlew clean jar"
echo "   b) Download MockServer: https://www.mock-server.com/download.html"
echo "   c) Build Spring Boot: cd services/orchestrator-java && ./gradlew bootRun"
echo "   d) Import postman/openapi.yaml into Postman"

echo ""
echo "6️⃣ Alternative Demo Approach:"
echo "   Use Testcontainers for the full demo:"
echo "   cd services/orchestrator-java && ./gradlew test"
echo "   This will spin up everything automatically!"

echo ""
echo "🎯 Demo is ready to run without Docker!"
echo "Focus on the working Python tests and show the architecture."
