# 🏦 Payments Demo - Service Virtualization & API Testing Framework

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Components](#architecture--components)
3. [Technology Stack](#technology-stack)
4. [Setup & Installation](#setup--installation)
5. [Running the Demo](#running-the-demo)
6. [Component Details](#component-details)
7. [API Endpoints](#api-endpoints)
8. [Testing Strategy](#testing-strategy)
9. [Mock Services](#mock-services)
10. [Database & Migrations](#database--migrations)
11. [CI/CD Pipeline](#cicd-pipeline)
12. [Troubleshooting](#troubleshooting)
13. [Demo Scenarios](#demo-scenarios)

---

## 🎯 Project Overview

This is a **comprehensive payments processing demo** that showcases modern software development practices including:

- **Microservices Architecture** with Java Spring Boot
- **Service Virtualization** using WireMock and MockServer
- **Python-based Risk Assessment** with comprehensive testing
- **Event-Driven Architecture** with Kafka integration
- **Database Migrations** using Liquibase
- **CI/CD Pipeline** with GitHub Actions
- **Containerization** with Docker

The demo simulates a real-world payment processing system where external services (risk assessment, tokenization) are mocked to demonstrate service virtualization capabilities.

---

## 🏗️ Architecture & Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client App   │    │   Postman      │    │   Web Browser  │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │   Spring Boot Orchestrator │
                    │        (Port 8088)        │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
          ┌─────────▼─────────┐   │   ┌─────────▼─────────┐
          │   H2 Database     │   │   │   Kafka (Optional) │
          │   (In-Memory)     │   │   │   (Port 9092)     │
          └───────────────────┘   │   └───────────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │   External Service Calls  │
                    └─────────────┬─────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
          ┌─────────▼─────────┐   │   ┌─────────▼─────────┐
          │   WireMock        │   │   │   MockServer      │
          │   (Port 18080)    │   │   │   (Port 18081)   │
          │   Risk Service    │   │   │   Tokenization    │
          └───────────────────┘   │   └───────────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │   Python Risk Policy      │
                    │   (Local Testing)        │
                    └───────────────────────────┘
```

---

## 🛠️ Technology Stack

### **Backend Services**
- **Java 17** - Primary runtime
- **Spring Boot 3.2.6** - Main framework
- **Spring WebFlux** - Reactive web support
- **Spring Kafka** - Event streaming
- **Spring JDBC** - Database connectivity
- **Liquibase** - Database migrations

### **Mock Services**
- **WireMock 3.6.0** - API mocking & stubbing
- **MockServer 5.15.0** - HTTP mock server
- **Custom Extensions** - Risk transformation logic

### **Database & Storage**
- **H2 Database** - In-memory for local development
- **PostgreSQL 16** - Production database
- **SQLite** - Alternative local database

### **Testing & Quality**
- **Python 3.11+** - Risk policy testing
- **pytest** - Python testing framework
- **MagicMock** - Mocking library
- **JUnit 5** - Java testing
- **Testcontainers** - Integration testing

### **DevOps & Tools**
- **Gradle 8.13** - Build automation
- **Docker & Docker Compose** - Containerization
- **GitHub Actions** - CI/CD pipeline
- **Postman/OpenAPI** - API documentation

---

## 🚀 Setup & Installation

### **Prerequisites**
```bash
# Required Software
- Java 17+ (OpenJDK, Amazon Corretto, or Oracle JDK)
- Python 3.8+ (with pip)
- Docker & Docker Compose (optional)
- Git

# Verify Installation
java -version          # Should show Java 17+
python3 --version     # Should show Python 3.8+
docker --version      # Should show Docker version
```

### **Quick Setup**
```bash
# 1. Clone the repository
git clone https://github.com/KarthikTools/TestAssessment.git
cd TestAssessment

# 2. Make scripts executable
chmod +x start-local-demo.sh
chmod +x services/orchestrator-java/gradlew
chmod +x mocks/wiremock-ext/gradlew

# 3. Download required JARs (if not already present)
cd mocks/wiremock
curl -L -o wiremock-standalone-3.6.0.jar "https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.6.0/wiremock-standalone-3.6.0.jar"

cd ../mockserver
curl -L -o mockserver-netty-5.15.0-jar-with-dependencies.jar "https://repo1.maven.org/maven2/org/mock-server/mockserver-netty/5.15.0/mockserver-netty-5.15.0-jar-with-dependencies.jar"
```

---

## 🎬 Running the Demo

### **Option 1: Automated Start (Recommended)**
```bash
./start-local-demo.sh
```
This script will:
- ✅ Run Python tests
- 🚀 Start WireMock on port 18080
- 🚀 Start MockServer on port 18081
- 📝 Generate configuration files
- 📊 Show service status

### **Option 2: Manual Start**
```bash
# Terminal 1: Start Mock Services
cd mocks/wiremock
java -jar wiremock-standalone-3.6.0.jar --port 18080 &

cd ../mockserver
java -jar mockserver-netty-5.15.0-jar-with-dependencies.jar -serverPort 18081 &

# Terminal 2: Start Java Service
cd services/orchestrator-java
./gradlew bootRun
```

### **Option 3: Full Docker Setup**
```bash
cd docker
docker-compose -f docker-compose.local.yml up -d
```

---

## 🔧 Component Details

### **1. Spring Boot Orchestrator Service**

**Location**: `services/orchestrator-java/`

**Key Features**:
- **Payment Processing**: Handles payment creation, validation, and processing
- **Service Orchestration**: Coordinates calls to external risk and tokenization services
- **Event Publishing**: Publishes payment events to Kafka
- **Database Operations**: Manages payment records with Liquibase migrations

**Main Classes**:
- `OrchestratorApp.java` - Main application entry point
- `PaymentController.java` - REST API endpoints
- `PaymentService.java` - Business logic implementation
- `JdbcConfig.java` - Database configuration
- `KafkaConfig.java` - Kafka configuration

**Configuration Files**:
- `application.yml` - Default configuration
- `application-local.yml` - Local development settings
- `application-demo.yml` - Demo-specific settings

### **2. Python Risk Policy Service**

**Location**: `python/risk_policy/`

**Key Features**:
- **Risk Assessment Logic**: Implements business rules for payment approval
- **MagicMock Testing**: Comprehensive test coverage using Python's built-in mocking
- **Boundary Testing**: Tests edge cases and error conditions
- **Network Simulation**: Mocks external API calls and network failures

**Main Files**:
- `app/policy.py` - Core risk assessment logic
- `tests/test_policy.py` - Comprehensive test suite
- `requirements.txt` - Python dependencies
- `pytest.ini` - Test configuration

**Test Coverage**:
- ✅ Fast approval path (no network calls)
- ✅ Review path (moderate risk)
- ✅ Rejection path (high risk)
- ✅ Timeout handling
- ✅ Network error handling
- ✅ Boundary value testing
- ✅ Mock reset and verification

### **3. WireMock Service Virtualization**

**Location**: `mocks/wiremock/`

**Key Features**:
- **API Mocking**: Simulates external risk assessment services
- **Custom Extensions**: Risk transformation logic
- **Dynamic Responses**: Configurable response patterns
- **Request Recording**: Captures and replays API interactions

**Configuration**:
- **Port**: 18080
- **Mappings**: `mappings/risk.json`
- **Extensions**: Custom `RiskTransformer` class
- **Admin Interface**: http://localhost:18080/__admin

**Custom Extension**:
- **Class**: `com.demo.wm.RiskTransformer`
- **Purpose**: Transforms risk assessment requests/responses
- **Location**: `mocks/wiremock-ext/src/main/java/`

### **4. MockServer Service Virtualization**

**Location**: `mocks/mockserver/`

**Key Features**:
- **HTTP Mocking**: Simulates tokenization services
- **Expectation Management**: Configurable request/response patterns
- **Stateful Mocking**: Maintains state across requests
- **Performance Testing**: Simulates various response times

**Configuration**:
- **Port**: 18081
- **Expectations**: `init/expectations.json`
- **Status Endpoint**: http://localhost:18081/status

---

## 🌐 API Endpoints

### **Payment Service API** (Port 8088)

#### **Health Check**
```http
GET /payments/health
Response: {"status": "UP", "timestamp": "..."}
```

#### **Create Payment**
```http
POST /payments
Content-Type: application/json

{
  "amount": 100.00,
  "currency": "USD",
  "merchantId": "MERCH001",
  "cardNumber": "4111111111111111",
  "expiryMonth": 12,
  "expiryYear": 2025,
  "cvv": "123"
}

Response: {
  "paymentId": "PAY_12345",
  "status": "APPROVED",
  "riskScore": 25,
  "message": "Payment processed successfully"
}
```

#### **Get Payment**
```http
GET /payments/{paymentId}
Response: Payment details
```

#### **List Payments**
```http
GET /payments?page=0&size=10
Response: Paginated payment list
```

### **Mock Service Endpoints**

#### **WireMock Admin** (Port 18080)
- **Health**: `GET /__admin/health`
- **Mappings**: `GET /__admin/mappings`
- **Requests**: `GET /__admin/requests`

#### **MockServer Status** (Port 18081)
- **Status**: `GET /status`
- **Health**: `GET /health`

---

## 🧪 Testing Strategy

### **Testing Pyramid**

```
        ┌─────────────┐
        │   E2E Tests │ ← Postman Collections
        └─────────────┘
    ┌───────────────────┐
    │ Integration Tests │ ← Spring Boot Tests
    └───────────────────┘
┌─────────────────────────────┐
│      Unit Tests            │ ← Python pytest + Java JUnit
└─────────────────────────────┘
```

### **Test Types**

#### **1. Unit Tests (Python)**
```bash
cd python/risk_policy
python3 -m pytest tests/ -v --cov=app
```

**Coverage Areas**:
- ✅ Risk assessment logic
- ✅ Boundary conditions
- ✅ Error handling
- ✅ Mock interactions
- ✅ Timeout scenarios

#### **2. Integration Tests (Java)**
```bash
cd services/orchestrator-java
./gradlew test
```

**Coverage Areas**:
- ✅ API endpoints
- ✅ Database operations
- ✅ Service interactions
- ✅ Kafka messaging
- ✅ Configuration loading

#### **3. End-to-End Tests**
```bash
# Using Postman Collections
# Import: postman/openapi.yaml
# Run against running services
```

---

## 🎭 Mock Services

### **WireMock Configuration**

**File**: `mocks/wiremock/mappings/risk.json`

```json
{
  "request": {
    "method": "POST",
    "urlPath": "/risk/assess",
    "headers": {
      "Content-Type": {
        "equalTo": "application/json"
      }
    }
  },
  "response": {
    "status": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "riskScore": 25,
      "recommendation": "APPROVE",
      "factors": ["low_amount", "known_merchant"]
    }
  }
}
```

### **MockServer Configuration**

**File**: `mocks/mockserver/init/expectations.json`

```json
[
  {
    "httpRequest": {
      "method": "POST",
      "path": "/tokenize"
    },
    "httpResponse": {
      "statusCode": 200,
      "body": {
        "token": "tok_12345",
        "maskedCard": "****1111",
        "expiry": "12/25"
      }
    }
  }
]
```

### **Custom WireMock Extension**

**Purpose**: Transform risk assessment responses based on request data

**Implementation**:
```java
public class RiskTransformer implements ResponseDefinitionTransformer {
    @Override
    public ResponseDefinition transform(Request request, 
                                     ResponseDefinition responseDefinition, 
                                     FileSource files, 
                                     Parameters parameters) {
        // Custom transformation logic
        return responseDefinition;
    }
}
```

---

## 🗄️ Database & Migrations

### **Database Configuration**

#### **Local Development (H2)**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:payments;DB_CLOSE_DELAY=-1
    username: sa
    password: 
    driver-class-name: org.h2.Database
  h2:
    console:
      enabled: true
      path: /h2-console
```

#### **Production (PostgreSQL)**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/payments
    username: postgres
    password: postgres
    driver-class-name: org.postgresql.Driver
```

### **Database Migrations**

**Tool**: Liquibase

**Location**: `services/orchestrator-java/src/main/resources/db/changelog/`

**Files**:
- `db.changelog-master.xml` - Main changelog
- `changes/001-create-payments-table.xml` - Initial schema

**Migration Content**:
```xml
<changeSet id="001" author="demo">
    <createTable tableName="payments">
        <column name="id" type="VARCHAR(36)">
            <constraints primaryKey="true" nullable="false"/>
        </column>
        <column name="amount" type="DECIMAL(10,2)">
            <constraints nullable="false"/>
        </column>
        <column name="currency" type="VARCHAR(3)">
            <constraints nullable="false"/>
        </column>
        <column name="status" type="VARCHAR(20)">
            <constraints nullable="false"/>
        </column>
        <column name="created_at" type="TIMESTAMP">
            <constraints nullable="false"/>
        </column>
    </createTable>
</changeSet>
```

---

## 🔄 CI/CD Pipeline

### **GitHub Actions Workflow**

**File**: `ci/github-actions/demo-pipeline.yml`

**Triggers**:
- Push to main branch
- Pull request creation
- Manual workflow dispatch

**Stages**:
1. **Build & Test**
   - Java compilation
   - Python testing
   - Unit test execution

2. **Integration Testing**
   - Database setup
   - Service startup
   - API testing

3. **Deployment**
   - Docker image building
   - Container deployment
   - Health checks

### **Pipeline Configuration**

```yaml
name: Demo Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '17'
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Run tests
        run: |
          ./gradlew test
          python3 -m pytest python/risk_policy/tests/
```

---

## 🚨 Troubleshooting

### **Common Issues & Solutions**

#### **1. Port Conflicts**
```bash
# Check what's using the ports
lsof -i :8088  # Spring Boot
lsof -i :18080 # WireMock
lsof -i :18081 # MockServer

# Kill processes if needed
kill -9 <PID>
```

#### **2. Java Version Issues**
```bash
# Ensure Java 17 is used
java -version
export JAVA_HOME=/path/to/java17

# For Gradle
./gradlew --version
```

#### **3. Mock Service Failures**
```bash
# Check WireMock logs
cd mocks/wiremock
java -jar wiremock-standalone-3.6.0.jar --port 18080 --verbose

# Check MockServer logs
cd mocks/mockserver
java -jar mockserver-netty-5.15.0-jar-with-dependencies.jar -serverPort 18081 -logLevel INFO
```

#### **4. Database Connection Issues**
```bash
# H2 Console
http://localhost:8088/h2-console

# Connection Details
JDBC URL: jdbc:h2:mem:payments
Username: sa
Password: (leave empty)
```

### **Debug Mode**

#### **Spring Boot Debug**
```bash
cd services/orchestrator-java
./gradlew bootRun --debug
```

#### **Python Debug**
```bash
cd python/risk_policy
python3 -m pytest tests/ -v -s --pdb
```

---

## 🎭 Demo Scenarios

### **Scenario 1: Happy Path Payment**
1. **Start Services**: Run `./start-local-demo.sh`
2. **Create Payment**: POST to `/payments` with valid data
3. **Verify Flow**: Check logs for service interactions
4. **Database Check**: Verify payment record creation

### **Scenario 2: Risk Assessment Failure**
1. **Stop WireMock**: Kill WireMock process
2. **Create Payment**: POST to `/payments`
3. **Observe Fallback**: Check error handling
4. **Restart WireMock**: Verify recovery

### **Scenario 3: High-Risk Payment**
1. **Create High-Risk Payment**: Use large amount or suspicious data
2. **Check Risk Logic**: Verify risk assessment rules
3. **Review Decision**: Check approval/rejection logic

### **Scenario 4: Service Virtualization**
1. **Modify Mock Responses**: Update WireMock mappings
2. **Test Changes**: Create payments to see new behavior
3. **Reset Mocks**: Restore original behavior

### **Scenario 5: Performance Testing**
1. **Load Test**: Send multiple concurrent requests
2. **Monitor Services**: Check response times
3. **Scale Mocks**: Adjust MockServer expectations

---

## 📚 Additional Resources

### **Documentation**
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [WireMock Documentation](https://wiremock.org/docs/)
- [MockServer Documentation](https://www.mock-server.com/)
- [Liquibase Documentation](https://docs.liquibase.com/)

### **API Testing**
- [Postman Collection](postman/openapi.yaml)
- [OpenAPI Specification](postman/openapi.yaml)

### **Development Tools**
- **IDE**: VS Code, IntelliJ IDEA, Eclipse
- **API Client**: Postman, Insomnia, curl
- **Database Tools**: DBeaver, pgAdmin, H2 Console

---

## 🤝 Contributing

### **Development Workflow**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### **Code Standards**
- **Java**: Follow Spring Boot conventions
- **Python**: Follow PEP 8 guidelines
- **Testing**: Maintain >80% code coverage
- **Documentation**: Update README for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support

### **Getting Help**
- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check this README and inline code comments

### **Contact**
- **Repository**: [KarthikTools/TestAssessment](https://github.com/KarthikTools/TestAssessment)
- **Maintainer**: Karthik Tools

---

*Last Updated: August 2025*
*Version: 1.0.0*
