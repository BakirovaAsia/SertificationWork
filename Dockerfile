FROM ubuntu:latest as builder

RUN apt-get update \
    && apt-get install maven -y \
    && apt-get install git -y

WORKDIR /usr/local/
RUN git clone https://github.com/BakirovaAsia/CaucusCalculator.git
WORKDIR /usr/local/CaucusCalculator/
RUN  mvn package

WORKDIR /usr/local/war

RUN cp -r /usr/local/CaucusCalculator/target/*.war /usr/local/war/CaucusCalc.war

FROM openjdk:8-jre-alpine as deployer
RUN apk add --no-cache wget

WORKDIR /usr/local/tomcat

RUN wget https://mirrors.nav.ro/apache/tomcat/tomcat-8/v8.5.66/bin/apache-tomcat-8.5.66.tar.gz   -O /tmp/tomcat.tar.gz \
    && cd /tmp && tar xvfz /tmp/tomcat.tar.gz \
    && cp -Rv /tmp/apache-tomcat-8.5.66/* /usr/local/tomcat/ \
    && rm -rf /tmp/* \
            /usr/local/tomcat/webapps/docs/* \
            /usr/local/tomcat/webapps/examples/*

WORKDIR /usr/local/tomcat/webapps/
COPY --from=builder /usr/local/war/ .

EXPOSE 8080
CMD  /usr/local/tomcat/bin/catalina.sh run