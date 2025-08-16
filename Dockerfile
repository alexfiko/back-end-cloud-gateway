#
# Build del proyecto (Multi-Stage)
# --------------------------------
#
# Usamos una imagen de Maven para hacer build de proyecto con Java
# Llamaremos a este sub-entorno "build"
# Copiamos todo el contenido del repositorio
# Ejecutamos el comando mvn clean package (Generara un archivo JAR para el despliegue)
FROM maven:3.9.6-eclipse-temurin-21 AS build

# ⚙️ Copiar archivos necesarios
COPY pom.xml ./
COPY mvnw ./
COPY .mvn/ .mvn/
# Dar permisos de ejecución al wrapper
RUN chmod +x mvnw

# 📦 Descargar dependencias
RUN ./mvnw dependency:go-offline -B
COPY . .
RUN ./mvnw clean package -DskipTests

# Usamos una imagen de Openjdk
# Exponemos el puerto que nuestro componente va a usar para escuchar peticiones
# Copiamos desde "build" el JAR generado (la ruta de generacion es la misma que veriamos en local) y lo movemos y renombramos en destino como 
# Marcamos el punto de arranque de la imagen con el comando "java -jar app.jar" que ejecutará nuestro componente.
FROM openjdk:21
EXPOSE 8080
COPY --from=build /target/api-gateway-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
