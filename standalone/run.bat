set ARGOS_HOME=%cd%
set JAVA_HOME=%ARGOS_HOME%\jdk
set CATALINA_HOME=%ARGOS_HOME%\tomcat

./mysql/bin/mysqld.exe --user=root --initialize-insecure
start /b ./mysql/bin/mysqld.exe --user=root --port=3306 --console

:change_password
echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; > DEFINE_PASSWORD
for /l %%x in (1, 1, 100) do (
	echo Trying to change root password... %%x
	./mysql/bin/mysql.exe -u root --skip-password < DEFINE_PASSWORD
	if %errorlevel% eq 0 goto :test_password
	ping localhost > nul
)

:test_password
echo SELECT 1; > PING_SQL
for /l %%x in (1, 1, 100) do (
	echo Testing Mysql DB Connection... %%x
	./mysql/bin/mysql.exe -u root --password=root < PING_SQL
	if %errorlevel% eq 0 goto :start_tomcat
	ping localhost > nul
)

echo "Failed to connect to mysql server";
exit

:start_tomcat
echo "Starting Tomcat"
REM call %CATALINA_HOME%\bin\catalina.bat run

