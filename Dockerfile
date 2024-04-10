FROM gradle:7-jdk11 as build
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/root/.gradle			\
	--mount=type=cache,target=/src/build/classes		\
	--mount=type=cache,target=/src/build/generated		\
	--mount=type=cache,target=/src/build/tmp		\
	gradle war --stacktrace

FROM scratch as package
WORKDIR /
COPY --from=build /src/build/libs/Scada-LTS.war .

FROM tomcat:9.0.87-jdk11-corretto-al2 as webserver
WORKDIR /usr/local/tomcat/
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY --from=package /Scada-LTS.war webapps/
WORKDIR webapps/Scada-LTS
RUN jar -xvf ../Scada-LTS.war && rm ../Scada-LTS.war
COPY docker/config/context.xml META-INF/context.xml

FROM debian:stable-20240408 as debian_installer_build
WORKDIR /pack
COPY installers/debian scadalts-standalone
COPY installers/systemd/scadalts.service scadalts-standalone/etc/systemd/system/scadalts.service
ADD https://downloads.apache.org/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz .
RUN tar -xvf apache-tomcat-9.0.87.tar.gz
RUN mv apache-tomcat-9.0.87 scadalts-standalone/usr/lib/scadalts/tomcat
COPY --from=package /Scada-LTS.war .
COPY unzip Scada-LTS.war -d scadalts/usr/lib/scadalts/tomcat/webapps/Scada-LTS
RUN dpkg-deb --build scadalts-standalone

FROM debian:stable-20240408 as debian_installer_test
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked		\
	apt update
COPY --from=debian_installer_build /pack/scadalts-standalone.deb /tmp
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked		\
	apt install -y /tmp/scadalts-standalone.deb


