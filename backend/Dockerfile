# Build context is the repository root: the scenarios in /content are part of the jar.
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /src
COPY content ./content
COPY backend/pom.xml ./backend/pom.xml
RUN mvn -q -f backend/pom.xml dependency:go-offline -DskipTests || true
COPY backend/src ./backend/src
RUN mvn -q -f backend/pom.xml -DskipTests package

FROM eclipse-temurin:25-jre-alpine
RUN addgroup -S koeder && adduser -S koeder -G koeder
USER koeder
COPY --from=build /src/backend/target/koeder.jar /app/koeder.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "/app/koeder.jar"]
