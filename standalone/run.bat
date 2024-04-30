set ARGOS_HOME=%cd%

mysql\bin\mysqld.exe				^
	--defaults-file=%ARGOS_HOME%\my.cnf	^
	--init-file=%ARGOS_HOME%\scadalts.sql	^
	--user=root				^
	--default-storage-engine=innodb		^
	--character-set-server=utf8mb3		^
	--collation-server=utf8mb3_general_ci	^
	--log-bin-trust-function-creators=1	^
	--language=english			^
	--lower_case_table_names=1		^
	--initialize-insecure			^
	--console
echo "Database initialized"
pause

mysql\bin\mysqld.exe				^
	--defaults-file=%ARGOS_HOME%\my.cnf	^
	--port=3306				^
	--console
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
	echo root user configured

:runtomcat
	set JAVA_HOME=%ARGOS_HOME%\jdk
	set CATALINA_HOME=%ARGOS_HOME%\tomcat
	call %CATALINA_HOME%\bin\catalina.bat run

