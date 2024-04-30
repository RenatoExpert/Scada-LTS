set ARGOS_HOME=%cd%

start mysql\bin\mysqld.exe --user=root		^
	--default-storage-engine=innodb		^
	--character-set-server=utf8mb3		^
	--collation-server=utf8mb3_general_ci	^
	--log-bin-trust-function-creators=1	^
	--language=english			^
	--lower_case_table_names=1		^
	--defaults-file=%ARGOS_HOME%\my.ini	^
	--init-file=%ARGOS_HOME%\scadalts.sql	^
	--initialize-insecure			^
	--port=3306				^
	--console
echo "Database initialized"

:testconn
	ping localhost > nul
	echo Trying to connect with database...
	echo SELECT 1; | .\mysql\bin\mysql.exe -u root --password=root --database=scadalts
	IF %errorlevel% LSS 1 (goto:runtomcat) ELSE (echo Does not connect with database)
	goto:testconn

:runtomcat
	set JAVA_HOME=%ARGOS_HOME%\jdk
	set CATALINA_HOME=%ARGOS_HOME%\tomcat
	call %CATALINA_HOME%\bin\catalina.bat run

