mysql\bin\mysqld.exe --user=root --initialize-insecure
echo "Database generated with no password"

start /b .\mysql\bin\mysqld.exe --user=root --port=3306 --console

:testconn
	echo SELECT 1; > PING_SQL
	ping localhost > nul
	echo Trying to connect with database...
	type PING_SQL | .\mysql\bin\mysql.exe -u root --password=root --database=scadalts
	IF %errorlevel% LSS 1 (goto:runtomcat) ELSE (echo Does not connect with database)
	echo Trying to connect with password...
	type PING_SQL | .\mysql\bin\mysql.exe -u root --password=root
	IF %errorlevel% LSS 1 (goto:createdb) ELSE (echo Does not connect with password)
	echo Trying to connect without password...
	type PING_SQL | .\mysql\bin\mysql.exe -u root
	IF %errorlevel% LSS 1 (goto:changepassword) ELSE (echo Does not connect without password)
	goto:testconn

:changepassword
	echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; > DEFINE_PASSWORD
	echo Trying to change root password...;
	type DEFINE_PASSWORD | .\mysql\bin\mysql.exe -u root
	IF %errorlevel% LSS 1 (echo Password changed!) ELSE (echo Password changing failed)
	goto:testconn

:createdb
	echo CREATE DATABASE IF NOT EXISTS scadalts; > CREATE_DB
	type CREATE_DB | .\mysql\bin\mysql.exe -u root --password=root
	IF %errorlevel% LSS 1 (echo Database created!) ELSE (echo Database creation failed)
	echo GRANT ALL ON scadalts.* TO 'root'@'localhost'; > GRANT
	type GRANT | .\mysql\bin\mysql.exe -u root --password=root --database=scadalts
	echo FLUSH PRIVILEGES; > FLUSH
	type FLUSH | .\mysql\bin\mysql.exe -u root --password=root --database=scadalts
	goto:testconn

:runtomcat
	set ARGOS_HOME=%cd%
	set JAVA_HOME=%ARGOS_HOME%\jdk
	set CATALINA_HOME=%ARGOS_HOME%\tomcat
	call %CATALINA_HOME%\bin\catalina.bat run


