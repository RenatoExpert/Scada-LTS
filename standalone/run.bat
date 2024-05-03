@echo off
title SCADA Argos - Standalone Version for Windows
color 10

set ARGOS_HOME=%cd%

echo "Initializing database"
mysql\bin\mysqld.exe				^
	--defaults-file="my.cnf"		^
	--user=root				^
	--init-file="%ARGOS_HOME%\scadalts.sql"	^
	--initialize-insecure			^
	--console
echo "Database initialized"

echo "Press [Enter] to start database" 
pause;
start "Database"				^
	mysql\bin\mysqld.exe			^
		--defaults-file=my.cnf		^
		--port=3306			^
		--console

echo "Press [Enter] to configure and test database" 
pause
:testconn
	ping localhost > nul
	echo Trying to connect with database...
	echo SELECT 1; | .\mysql\bin\mysql.exe -u root --password=root --database=scadalts
	IF %errorlevel% LSS 1 (goto:runtomcat) ELSE (echo Does not connect with database with password)
	echo SELECT 1; | .\mysql\bin\mysql.exe -u root
	IF %errorlevel% LSS 1 (goto:configuser) ELSE (echo Does not connect with database without password)
	goto:testconn

:configuser
	echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';	| .\mysql\bin\mysql.exe -u root
	echo GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;	| .\mysql\bin\mysql.exe -u root --password=root
	echo FLUSH PRIVILEGES;						| .\mysql\bin\mysql.exe -u root --password=root
	echo Database configured with success

:runtomcat
	set JAVA_HOME=%ARGOS_HOME%\jdk
	set CATALINA_HOME=%ARGOS_HOME%\tomcat
	echo "Press [Enter] to start webserver" 
	pause
	start "Webserver" "%CATALINA_HOME%\bin\catalina.bat" run


