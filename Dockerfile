FROM renatoexpert/scadalts_npm_package as npm_package
FROM renatoexpert/scadalts_npm_build as npm_build
FROM renatoexpert/scadalts_npm_src as npm_src

FROM node:22.3.0-alpine3.20 as newnpm_build
WORKDIR /package
COPY npm/hp_scada/package.json .
RUN npm install
COPY npm/hp_scada .
RUN npm run build
CMD cat dist/hp.umd.js

FROM scratch as newnpm_package
COPY --from=newnpm_build /package/dist/hp.umd.js /dist/hp.umd.js

FROM alpine:20240329 as img_build
RUN apk add --update --no-cache `#inkscape` imagemagick
WORKDIR /img
COPY art .
#RUN inkscape --export-type="ico" -w 64 -h 64 favicon.svg
#RUN inkscape --export-type="png" logo.svg
RUN mkdir -p /output
RUN cp logo.svg /output
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
COPY --from=npm_src /scadalts-ui scadalts-ui
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
COPY --from=npm_package /dist dist
COPY --from=newnpm_package /dist/hp.umd.js WebContent/assets/hp/hp.umd.js
COPY --from=newnpm_build /package/src/assets/header_L1.svg WebContent/assets/hp/header_L1.svg
COPY --from=newnpm_build /package/src/assets/views_tree.json WebContent/assets/hp/views_tree.js
COPY --from=newnpm_build /package/bg WebContent/assets/hp/bg
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
ADD https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.js WebContent/assets/hp
COPY --from=img_build /output/logo.svg WebContent/assets/logo.svg
COPY --from=img_build /output/favicon.ico WebContent/images/favicon.ico
RUN --mount=type=cache,target=/root/.gradle			\
	--mount=type=cache,target=/src/build/classes		\
	--mount=type=cache,target=/src/build/generated		\
	--mount=type=cache,target=/src/build/tmp		\
	gradle war --stacktrace
#RUN cp -r dist/js/test-component.js				WebContent/resources/js-ui/views/js
#RUN cp -r dist/js/cmp-component-svg.js				WebContent/resources/js-ui/views/js

FROM amazoncorretto:11-al2-native-jdk AS dir_build
RUN mkdir -p /output/WEB-INF/classes
WORKDIR /build
COPY src src
COPY tomcat/lib lib
COPY tomcatlib lib
COPY WebContent/WEB-INF/lib/ lib
COPY WebContent/WEB-INF/tmp-lib/ lib
COPY --from=lib /output lib
RUN find ./src -type f -name "*.java" -exec \
	javac -cp "lib/*" -d output/WEB-INF/classes -encoding "UTF-8" -source 11 -target 11 '{}' +
WORKDIR /output
COPY WebContent .
RUN mv /build/lib/* WEB-INF/lib/
COPY webapp-resources WEB-INF/classes
COPY templates templates
COPY test test
COPY modbus modbus
COPY jmeter jmeter
COPY test-resources test-resources
COPY xml xml
COPY backstop backstop
COPY --from=npm_src /scadalts-ui scadalts-ui
COPY --from=npm_build /scadalts-ui/node_modules /tmp/node_modules
COPY --from=npm_src /scadalts-ui scadalts-ui
RUN mkdir -p ./resources/node_modules						&& \
	cp -r /tmp/node_modules/sockjs-client ./resources/node_modules		&& \
	cp -r /tmp/node_modules/stompjs ./resources/node_modules		;
COPY --from=npm_package /dist dist
COPY --from=newnpm_package /dist/hp.umd.js ./assets/hp/hp.umd.js
COPY --from=newnpm_build /package/src/header_L1.svg ./assets/hp/header_L1.svg
COPY --from=newnpm_build /package/src/views_tree.json ./assets/hp/views_tree.js
COPY --from=newnpm_build /package/bg ./assets/hp/bg
RUN mkdir -p ./resources/js-ui/app/									&& \
	cp -r dist/css						./resources/js-ui/app/css		&& \
	mkdir -p ./resources/js-ui/app/js								&& \
	cp -r dist/js/chunk-vendors.js				./resources/js-ui/app/js		&& \
	cp -r dist/js/app.js					./resources/js-ui/app/js		&& \
	mkdir -p ./resources/js-ui/modernWatchList/js							&& \
	cp -r dist/js/pdfmake.js				./resources/js-ui/modernWatchList/js	&& \
	cp -r dist/js/xlsx.js					./resources/js-ui/modernWatchList/js	&& \
	cp -r dist/js/canvg.js					./resources/js-ui/modernWatchList/js	&& \
	cp -r dist/js/example-chart-cmp.js			./resources/js-ui/modernWatchList/js	&& \
	mkdir -p ./resources/js-ui/views/js								&& \
	cp -r dist/js/simple-component-svg.js			./resources/js-ui/views/js		&& \
	cp -r dist/js/live-alarms-component.js			./resources/js-ui/views/js		&& \
	cp -r dist/js/isalive-component.js			./resources/js-ui/views/js		&& \
	mkdir -p ./resources/js-ui/ds/js								&& \
	cp -r dist/js/sleep-and-reactivation-ds-component.js	./resources/js-ui/ds/js		&& \
	mkdir -p ./resources/js-ui/pointHierarchy/js							&& \
	cp -r dist/js/ph.js					./resources/js-ui/pointHierarchy/js	&& \
	cp -r dist/fonts					./resources/js-ui/app/fonts		&& \
	cp -r dist/img						./img					;
ADD https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.js ./assets/hp
COPY --from=img_build /output/logo.svg ./assets/logo.svg
COPY --from=img_build /output/favicon.ico ./images/favicon.ico

FROM scratch AS dir_package
COPY --from=dir_build /output /output

FROM tomcat:9.0.87-jdk11-corretto-al2 as dir_deploy
EXPOSE 8080
WORKDIR /usr/local/tomcat/
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY docker/config/context.xml conf/context.xml
RUN mkdir -p webapps/Scada-LTS
COPY --from=dir_package /output webapps/Scada-LTS
WORKDIR webapps/Scada-LTS

FROM gradle:7-jdk11 as war_debug
WORKDIR /debug
COPY --from=war_build /src/build/libs/Scada-LTS.war /tmp
RUN unzip /tmp/Scada-LTS.war -d .

FROM scratch as war_package
WORKDIR /output
COPY --from=war_build /src/build/libs/Scada-LTS.war .

FROM tomcat:9.0.87-jdk11-corretto-al2 as war_deploy
EXPOSE 8080
WORKDIR /usr/local/tomcat/
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY docker/config/context.xml conf/context.xml
COPY --from=war_package /output /tmp
WORKDIR webapps/Scada-LTS
RUN jar -xf /tmp/Scada-LTS.war && rm /tmp/Scada-LTS.war

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
ADD https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93-windows-x64.zip /tmp/tomcat.zip
ADD https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.36-winx64.zip /tmp/mysql.zip
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
WORKDIR /standalone
COPY standalone .

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

