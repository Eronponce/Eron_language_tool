@echo off
setlocal EnableDelayedExpansion

set "BASE_DIR=%~dp0LanguageToolServer"
cd /d "%BASE_DIR%"

set "LT_FOLDER="
for /d %%i in (LanguageTool-*) do (
    set "LT_FOLDER=%%i"
)

if not defined LT_FOLDER exit /b 1

cd /d "%BASE_DIR%\!LT_FOLDER!"

start "" javaw -Xms256m -Xmx512m -XX:+UseG1GC -cp languagetool-server.jar org.languagetool.server.HTTPServer --port 8081 --allow-origin "*"

exit
