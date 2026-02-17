# ── Stage 1: Build WAR with Maven ────────────────────────
FROM maven:3.9-eclipse-temurin-11 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
COPY WebContent ./WebContent
RUN mvn clean package -q

# ── Stage 2: Run on Tomcat ────────────────────────────────
FROM tomcat:9.0-jdk11-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/smart-inventory-pro-1.0.war \
     /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]