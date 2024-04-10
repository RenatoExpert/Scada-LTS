FROM gradle:7-jdk11 as build
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/root/.gradle		\
	--mount=type=cache,target=/src/build/classes	\
	--mount=type=cache,target=/src/build/generated	\
	--mount=type=cache,target=/src/build/tmp	\
	gradle war

FROM scratch as package
WORKDIR /
COPY --from=build /src/build/libs/Scada-LTS.war .

FROM tomcat:9.0.87-jdk8-corretto-al2 as webserver
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked		\
	--mount=target=/var/cache/apt,type=cache,sharing=locked		\
	apt update &&	\
	apt install wait-for-it
WORKDIR /usr/local/tomcat/
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY --from=package /Scada-LTS.war webapps/
RUN cd webapps && mkdir Scada-LTS && unzip Scada-LTS.war -d Scada-LTS
COPY docker/config/context.xml webapps/Scada-LTS/META-INF/context.xml

