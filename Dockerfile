# Use OpenJDK 17 JDK as the build environment
FROM eclipse-temurin:17-jdk-jammy AS build

# Set the working directory
WORKDIR /app

# Copy the Gradle wrapper files
COPY gradlew .
COPY gradle gradle

# Copy the build.gradle and settings.gradle files
COPY build.gradle settings.gradle ./

# Download dependencies
# This step will be cached if the gradle files do not change
RUN ./gradlew dependencies --no-daemon

# Copy the source code
COPY src src

# Build the application
RUN ./gradlew build --no-daemon -x test

# Create the runtime image
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose the port the app runs on
EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java", "-jar", "/app/app.jar"]