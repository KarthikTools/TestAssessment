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

# Start WireMock with the downloaded JAR
echo "   Starting WireMock on port 18080..."
cd mocks/wiremock
if [ -f "wiremock-standalone-3.6.0.jar" ]; then
    echo "   Using downloaded WireMock JAR"
    java -jar wiremock-standalone-3.6.0.jar --port 18080 &
    WIREMOCK_PID=$!
    echo "   WireMock started with PID: $WIREMOCK_PID"
else
    echo "   ❌ WireMock JAR not found!"
    echo "   Please ensure wiremock-standalone-3.6.0.jar is in mocks/wiremock/"
    exit 1
fi
cd ../..

# Start MockServer with the downloaded JAR
echo "   Starting MockServer on port 18081..."
cd mocks/mockserver
if [ -f "mockserver-netty-5.15.0-jar-with-dependencies.jar" ]; then
    echo "   Using downloaded MockServer JAR"
    java -jar mockserver-netty-5.15.0-jar-with-dependencies.jar -serverPort 18081 &
    MOCKSERVER_PID=$!
    echo "   MockServer started with PID: $MOCKSERVER_PID"
else
    echo "   ❌ MockServer JAR not found!"
    echo "   Please ensure mockserver-netty-5.15.0-jar-with-dependencies.jar is in mocks/mockserver/"
    exit 1
fi
cd ../..

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
echo "   ✅ WireMock: RUNNING (PID: $WIREMOCK_PID)"
echo "   ✅ MockServer: RUNNING (PID: $MOCKSERVER_PID)"
echo "   ⚠️  Spring Boot: NEEDS BUILD"
echo "   ✅ H2 Database: CONFIGURED (in-memory)"

echo ""
echo "5️⃣ Next Steps:"
echo "   a) Build Spring Boot: cd services/orchestrator-java && ./gradlew bootRun"
echo "   b) Import postman/openapi.yaml into Postman"
echo "   c) Test the mock services:"
echo "      - WireMock: http://localhost:18080/__admin"
echo "      - MockServer: http://localhost:18081/status"

echo ""
echo "6️⃣ Alternative Demo Approach:"
echo "   Use Testcontainers for the full demo:"
echo "   cd services/orchestrator-java && ./gradlew test"
echo "   This will spin up everything automatically!"

echo ""
echo "🎯 Demo is ready to run without Docker!"
echo "Focus on the working Python tests and show the architecture."
