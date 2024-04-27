set ARGOS_HOME=%cd%
set JAVA_HOME=%ARGOS_HOME%\jdk
set CATALINA_HOME=%ARGOS_HOME%\tomcat

./mysql/bin/mysqld.exe --user=root --initialize-insecure
echo "Database generated with no password"

start /b ./mysql/bin/mysqld.exe --user=root --port=3306 --console

echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; > DEFINE_PASSWORD
for /L %%x in (1, 1, 100) do (
	echo Trying to change root password... %%x
	./mysql/bin/mysql.exe -u root --skip-password < DEFINE_PASSWORD
	if %errorlevel% LEQ 1 %%x=100
	ping localhost > nul
)

echo SELECT 1; > PING_SQL
for /L %%x in (1, 1, 100) do (
	echo Testing Mysql DB Connection... %%x
	./mysql/bin/mysql.exe -u root --password=root < PING_SQL
	if %errorlevel% LEQ 1 %%x=100
	ping localhost > nul
)

REM call %CATALINA_HOME%\bin\catalina.bat run

