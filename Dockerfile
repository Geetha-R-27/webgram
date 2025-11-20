# # ====== Stage 1: Build the application ======
# FROM maven:3.9.6-eclipse-temurin-17 AS build
# WORKDIR /app

# # Copy pom.xml and download dependencies (cached for faster rebuilds)
# COPY pom.xml .
# RUN mvn dependency:go-offline

# # Copy the rest of the project and build it
# COPY src ./src
# RUN mvn clean package -DskipTests

# # ====== Stage 2: Run the application ======
# FROM eclipse-temurin:17-jdk-jammy
# WORKDIR /app

# # Copy the packaged JAR file from the build stage
# COPY --from=build /app/target/*.jar app.jar

# # Expose the port your Spring Boot app runs on
# EXPOSE 8080

# # Run the app
# ENTRYPOINT ["java", "-jar", "app.jar"]


# Use Maven to build the application
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app
COPY . /app

# Build the WAR file
RUN mvn clean package -DskipTests

# ----------- Final Image -------------
FROM tomcat:9.0-jdk17

# Remove default ROOT webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file to Tomcat
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/jspgram.war

# Expose Tomcat port
EXPOSE 8080

CMD ["catalina.sh", "run"]

