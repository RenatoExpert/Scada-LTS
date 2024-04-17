FROM node:14.21.3-bullseye as npm_build
WORKDIR /scadalts-ui
COPY ./scadalts-ui/package.json ./scadalts-ui/node_modules /scadalts-ui
RUN --mount=type=cache,target=/src/scadalts-ui/node_modules	\
	npm install
COPY ./scadalts-ui /scadalts-ui
RUN --mount=type=cache,target=/src/scadalts-ui/node_modules	\
	npm run build

FROM debian:stable-20240408 as lib
RUN --mount=type=cache,target=/var/lib/apt	\
	apt update && apt install -y wget
WORKDIR /tmp/fetch
RUN mkdir -p /tmp/lib
COPY liblist.txt .
RUN wget -i liblist.txt -P /tmp/lib

FROM gradle:7-jdk11 as war_build
WORKDIR /src
COPY . .
COPY --from=lib /lib/* lib
COPY --from=npm_build /scadalts-ui/node_modules /tmp/node_modules
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
WORKDIR /
COPY --from=war_build /src/build/libs/Scada-LTS.war .

FROM tomcat:9.0.87-jdk11-corretto-al2 as war_deploy
WORKDIR /usr/local/tomcat/
COPY WebContent/WEB-INF/lib/mysql-connector-java-5.1.49.jar	lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar					lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar			lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar				lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar		lib/jaxb-runtime-2.4.0-b180830.0438.jar
COPY --from=war_package /Scada-LTS.war webapps/
WORKDIR webapps/Scada-LTS
RUN jar -xvf ../Scada-LTS.war && rm ../Scada-LTS.war
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
COPY --from=war_package /Scada-LTS.war .
RUN unzip Scada-LTS.war -d scadalts-standalone/usr/lib/scadalts/tomcat/webapps/Scada-LTS
RUN dpkg-deb --build scadalts-standalone

FROM debian:stable-20240408 as deb_deploy
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked		\
	apt update
COPY --from=deb_package /pack/scadalts-standalone.deb /tmp
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked		\
	apt install -y /tmp/scadalts-standalone.deb


