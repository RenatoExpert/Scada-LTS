mysql\bin\mysqld.exe --user=root --initialize-insecure
echo "Database generated with no password"

start /b .\mysql\bin\mysqld.exe --user=root --port=3306 --console

echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; > DEFINE_PASSWORD
echo SELECT 1; > PING_SQL
:testconn
	ping localhost > nul
	echo Loop [%%x]
	echo Trying to connect with password...
	type PING_SQL | .\mysql\bin\mysql.exe -u root --password=root
	IF %errorlevel% LSS 1 (goto:runtomcat) ELSE (echo Does not connect with password)
	echo Trying to connect without password...
	type PING_SQL | .\mysql\bin\mysql.exe -u root
	IF %errorlevel% LSS 1 (goto:changepassword) ELSE (echo Does not connect without password)
	goto:testconn

:changepassword
	echo Trying [%%x] to change root password...;
	type DEFINE_PASSWORD | .\mysql\bin\mysql.exe -u root
	IF %errorlevel% LSS 1 (echo Password changed!) ELSE (echo Password changing failed)
	goto:testconn

:runtomcat
	set ARGOS_HOME=%cd%
	set JAVA_HOME=%ARGOS_HOME%\jdk
	set CATALINA_HOME=%ARGOS_HOME%\tomcat
	call %CATALINA_HOME%\bin\catalina.bat run


