# ---- ETAP 1: BUDOWA ----
FROM eclipse-temurin:26-jdk AS build
WORKDIR /app

# Wrapper Mavena (mvnw sam pobiera Mavena) i kod źródłowy
COPY mvnw mvnw.cmd .mvn ./
COPY pom.xml ./
COPY src ./src

RUN chmod +x mvnw && ./mvnw -B -ntp -DskipTests package

# ---- ETAP 2: URUCHOMIENIE ----
FROM eclipse-temurin:26-jre
WORKDIR /app

# Aplikacja nie działa jako root (dobra praktyka bezpieczeństwa)
RUN groupadd -r spring && useradd -r -g spring spring

COPY --from=build /app/target/*.jar /app/helloworld.jar
RUN chown spring:spring /app/helloworld.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/helloworld.jar"]
