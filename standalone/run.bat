set ARGOS_HOME=%cd%
set JAVA_HOME=%ARGOS_HOME%\jdk
set CATALINA_HOME=%ARGOS_HOME%\tomcat

start /b ./mysql/bin/mysqld.exe --user=root --port=3306 --initialize-insecure

set DEFINE_PASSWORD="ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"
set PING_SQL="SELECT 1;"
for /l %%x in (1, 1, 100) do (
	echo Testing Mysql DB Connection... %%x
	./mysql/bin/mysql.exe -u root --password=root < %PING_SQL%		&& goto :start_tomcat
	./mysql/bin/mysql.exe -u root --skip-password < %DEFINE_PASSWORD%	&& echo "Password set to 'root'"
	timeout 5;
)

echo "Failed to connect to mysql server";
exit

:start_tomcat
echo "Starting Tomcat"
call %CATALINA_HOME%\bin\catalina.bat run

