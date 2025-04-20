@echo off
setlocal

:: ===== CONFIGURATION =====
set PROJECT_NAME=PMSoftware-1.0-SNAPSHOT
set TOMCAT_HOME=D:\Tomcat9\apache-tomcat-9.0.104
set WAR_SOURCE=target\%PROJECT_NAME%.war
set WAR_DEST=%TOMCAT_HOME%\webapps\%PROJECT_NAME%.war
set CATALINA_HOME=%TOMCAT_HOME%

echo 🔄 Building project with Maven...
call mvn clean package

if exist %WAR_SOURCE% (
    echo WAR built successfully!

    echo Stopping Tomcat...
    call "%TOMCAT_HOME%\bin\shutdown.bat"

    timeout /t 3 >nul

    echo Removing old deployed app...
    rmdir /s /q "%TOMCAT_HOME%\webapps\%PROJECT_NAME%"
    del /q "%TOMCAT_HOME%\webapps\%PROJECT_NAME%.war"

    echo Copying new WAR to Tomcat webapps...
    copy "%WAR_SOURCE%" "%WAR_DEST%"

    echo Starting Tomcat...
    call "%TOMCAT_HOME%\bin\startup.bat"

    echo Done! Deployed at: http://localhost:8080/%PROJECT_NAME%/
) else (
    echo ERROR: WAR file was not created. Check for Maven build errors.
)

endlocal
pause
