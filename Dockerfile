FROM gradle:7-jdk11 as war_build
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/root/.gradle	\
	gradle buildRun

FROM scratch as package
WORKDIR /
COPY --from=compilation /scadalts/target/scadalts-1.0-SNAPSHOT.war Scada-LTS.war

FROM tomcat:9.0.87-jdk8-corretto-al2 as webserver
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked		\
	--mount=target=/var/cache/apt,type=cache,sharing=locked		\
	apt update &&	\
	apt install wait-for-it
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar /usr/local/tomcat/lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar /usr/local/tomcat/lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar /usr/local/tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar /usr/local/tomcat/lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar /usr/local/tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY build/libs/Scada-LTS.war /usr/local/tomcat/webapps/
RUN cd /usr/local/tomcat/webapps/ && mkdir Scada-LTS && unzip Scada-LTS.war -d Scada-LTS
COPY docker/config/context.xml /usr/local/tomcat/webapps/Scada-LTS/META-INF/context.xml
COPY --from=package /Scada-LTS.war ./webapps

