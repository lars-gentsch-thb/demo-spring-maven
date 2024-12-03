FROM ubuntu:latest
MAINTAINER docker@thb.de

RUN apt-get update
RUN apt-get install openjdk-17-jre-headless -y

# Gradle
#ADD ./app/build/libs/your-app-1.0.jar /service.jar

# Maven
ADD ./target/demo-0.0.1-SNAPSHOT.jar /service.jar

ENTRYPOINT java -jar /service.jar
EXPOSE 8080
