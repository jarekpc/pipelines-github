# ---- ETAP 1: BUDOWA ----
FROM eclipse-temurin:26-jdk AS build
WORKDIR /app

# Narzedzia wymagane przez wrapper Mavena (pobieranie + rozpakowanie)
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip && rm -rf /var/lib/apt/lists/*

# Wrapper Mavena (mvnw sam pobiera Mavena) i kod zrodlowy
COPY mvnw mvnw.cmd ./
COPY .mvn ./.mvn
COPY pom.xml ./
COPY src ./src

RUN chmod +x mvnw && ./mvnw -B -ntp -DskipTests package

# ---- ETAP 2: URUCHOMIENIE ----
FROM eclipse-temurin:26-jre
WORKDIR /app

# Aplikacja nie dziala jako root (dobra praktyka bezpieczenstwa)
RUN groupadd -r spring && useradd -r -g spring spring

COPY --from=build /app/target/*.jar /app/helloworld.jar
RUN chown spring:spring /app/helloworld.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/helloworld.jar"]
