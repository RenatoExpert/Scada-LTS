FROM node:14.21.3-bullseye as npm_build
WORKDIR /scadalts-ui
COPY ./scadalts-ui/package.json ./scadalts-ui/node_modules /scadalts-ui
RUN --mount=type=cache,target=/src/scadalts-ui/node_modules	\
	npm install
COPY ./scadalts-ui /scadalts-ui
RUN --mount=type=cache,target=/src/scadalts-ui/node_modules	\
	npm run build

FROM alpine:20240329 as img_build
RUN apk add --update --no-cache inkscape imagemagick
WORKDIR /img
COPY art .
#RUN inkscape --export-type="ico" -w 64 -h 64 favicon.svg
#RUN inkscape --export-type="png" logo.svg
RUN mkdir -p /output
RUN cp logo.png /output
RUN convert favicon.png -define icon:auto-resize=256,64,48,32,16 /output/favicon.ico

FROM debian:stable-20240408 as lib
RUN --mount=type=cache,target=/var/lib/apt	\
	apt update && apt install -y wget
WORKDIR /tmp/fetch
RUN mkdir -p /output
COPY liblist.txt .
RUN wget -i liblist.txt -P /output

FROM gradle:7-jdk11 as war_build
COPY --from=lib /output /tmp/lib
COPY --from=npm_build /scadalts-ui/node_modules /tmp/node_modules
WORKDIR /src
COPY build.gradle .
COPY src src
COPY WebContent WebContent
COPY webapp-resources webapp-resources
COPY scadalts-ui scadalts-ui
COPY templates templates
COPY test test
COPY modbus modbus
COPY jmeter jmeter
COPY test-resources test-resources
COPY xml xml
COPY backstop backstop
COPY doc doc
RUN mv /tmp/lib/* WebContent/WEB-INF/lib/
RUN mkdir -p WebContent/resources/node_modules						&& \
	cp -r /tmp/node_modules/sockjs-client WebContent/resources/node_modules		&& \
	cp -r /tmp/node_modules/stompjs WebContent/resources/node_modules		;
COPY --from=npm_build /scadalts-ui/dist dist
RUN mkdir -p WebContent/resources/js-ui/app/									&& \
	cp -r dist/css						WebContent/resources/js-ui/app/css		&& \
	mkdir -p WebContent/resources/js-ui/app/js								&& \
	cp -r dist/js/chunk-vendors.js				WebContent/resources/js-ui/app/js		&& \
	cp -r dist/js/app.js					WebContent/resources/js-ui/app/js		&& \
	mkdir -p WebContent/resources/js-ui/modernWatchList/js							&& \
	cp -r dist/js/pdfmake.js				WebContent/resources/js-ui/modernWatchList/js	&& \
	cp -r dist/js/xlsx.js					WebContent/resources/js-ui/modernWatchList/js	&& \
	cp -r dist/js/canvg.js					WebContent/resources/js-ui/modernWatchList/js	&& \
	cp -r dist/js/example-chart-cmp.js			WebContent/resources/js-ui/modernWatchList/js	&& \
	mkdir -p WebContent/resources/js-ui/views/js								&& \
	cp -r dist/js/simple-component-svg.js			WebContent/resources/js-ui/views/js		&& \
	cp -r dist/js/live-alarms-component.js			WebContent/resources/js-ui/views/js		&& \
	cp -r dist/js/isalive-component.js			WebContent/resources/js-ui/views/js		&& \
	mkdir -p WebContent/resources/js-ui/ds/js								&& \
	cp -r dist/js/sleep-and-reactivation-ds-component.js	WebContent/resources/js-ui/ds/js		&& \
	mkdir -p WebContent/resources/js-ui/pointHierarchy/js							&& \
	cp -r dist/js/ph.js					WebContent/resources/js-ui/pointHierarchy/js	&& \
	cp -r dist/fonts					WebContent/resources/js-ui/app/fonts		&& \
	cp -r dist/img						WebContent/img					;
COPY --from=img_build /output/logo.png WebContent/assets/logo.png
COPY --from=img_build /output/favicon.ico WebContent/images/favicon.ico
RUN --mount=type=cache,target=/root/.gradle			\
	--mount=type=cache,target=/src/build/classes		\
	--mount=type=cache,target=/src/build/generated		\
	--mount=type=cache,target=/src/build/tmp		\
	gradle war --stacktrace
#RUN cp -r dist/js/test-component.js				WebContent/resources/js-ui/views/js
#RUN cp -r dist/js/cmp-component-svg.js				WebContent/resources/js-ui/views/js

FROM gradle:7-jdk11 as war_debug
WORKDIR /debug
COPY --from=war_build /src/build/libs/Scada-LTS.war /tmp
RUN unzip /tmp/Scada-LTS.war -d .

FROM scratch as war_package
WORKDIR /output
COPY --from=war_build /src/build/libs/Scada-LTS.war .

FROM tomcat:9.0.87-jdk11-corretto-al2 as war_deploy
WORKDIR /usr/local/tomcat/
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY --from=war_package /output /tmp
WORKDIR webapps/Scada-LTS
RUN jar -xvf /tmp/Scada-LTS.war && rm /tmp/Scada-LTS.war
COPY docker/config/context.xml META-INF/context.xml

FROM debian:stable-20240408 as deb_build
RUN apt update
RUN apt install -y unzip
WORKDIR /pack
COPY installers/debian scadalts-standalone
COPY installers/systemd/scadalts.service scadalts-standalone/etc/systemd/system/scadalts.service
ADD https://downloads.apache.org/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz .
RUN tar -xvf apache-tomcat-9.0.87.tar.gz
RUN mkdir -p scadalts-standalone/usr/lib/scadalts/
RUN mv apache-tomcat-9.0.87 scadalts-standalone/usr/lib/scadalts/tomcat
COPY --from=war_package /output .
RUN unzip Scada-LTS.war -d scadalts-standalone/usr/lib/scadalts/tomcat/webapps/Scada-LTS
RUN dpkg-deb --build scadalts-standalone

FROM debian:stable-20240408 as deb_deploy
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked		\
	apt update
COPY --from=deb_package /pack/scadalts-standalone.deb /tmp
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked		\
	apt install -y /tmp/scadalts-standalone.deb

FROM alpine:20240329 as standalone_build_windows
ADD https://builds.openlogic.com/downloadJDK/openlogic-openjdk/11.0.22+7/openlogic-openjdk-11.0.22+7-windows-x64.zip /tmp/jdk.zip
ADD https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.88/bin/apache-tomcat-9.0.88-windows-x64.zip /tmp/tomcat.zip
ADD https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.32-winx64.zip /tmp/mysql.zip
WORKDIR /standalone
RUN unzip /tmp/jdk.zip -d /tmp/jdk && mv /tmp/jdk/* jdk
RUN unzip /tmp/tomcat.zip -d /tmp/tomcat && mv /tmp/tomcat/* tomcat
RUN unzip /tmp/mysql.zip -d /tmp/mysql && mv /tmp/mysql/* mysql
RUN rm -rf /tmp/*
WORKDIR /standalone/tomcat
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
RUN rm -rf webapps/*
WORKDIR webapps/Scada-LTS
COPY --from=war_package /output /tmp
RUN unzip /tmp/Scada-LTS.war -d . && \
	rm /tmp/Scada-LTS.war
COPY docker/config/context.xml META-INF/context.xml
WORKDIR /standalone
COPY standalone/run.bat .

FROM scratch as standalone_package_windows
WORKDIR /output
COPY --from=standalone_build_windows /standalone .

FROM alpine:20240329 as standalone_test_windows
RUN apk add --update --no-cache wine gnutls
ENV WINEPREFIX='/root/.wine'
ENV CATALINA_HOME='C:\\argos\tomcat'
ENV JAVA_HOME='C:\\argos\jdk'
ENV WINEDEBUG=-all
WORKDIR "/root/.wine/drive_c/argos"
WORKDIR tomcat
CMD wine run.bat
#winetricks atmlib corefonts gdiplus msxml3 msxml6 vcrun2008 vcrun2010 vcrun2012 fontsmooth-rgb gecko

