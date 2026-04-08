@echo off
setlocal enabledelayedexpansion
title Servidor LanguageTool Local (ALTA PERFORMANCE)

:: Pega o caminho da pasta onde o script rodou
set BASE_DIR=%~dp0LanguageToolServer
cd /d "%BASE_DIR%"

:: Procura pela pasta da versao atual do LanguageTool
for /d %%i in (LanguageTool-*) do (
    set LT_FOLDER=%%i
)

if "!LT_FOLDER!"=="" (
    echo [ERRO] Pasta do LanguageTool nao encontrada! 
    pause
    exit /b
)

echo ========================================================
echo   INICIANDO SERVIDOR COM ALTA PERFORMANCE
echo   MEMORIA RESERVADA: 2GB
echo ========================================================
echo.

cd "!LT_FOLDER!"

:: EXPLICAÇÃO DOS PARÂMETROS:
:: -Xms512m : Memória inicial (512MB)
:: -Xmx2g   : Memória máxima (2GB) - Aumente se seu PC tiver muita RAM
:: -XX:+UseG1GC : Gerenciamento de memória de baixa latência
:: --warmup : Carrega as regras na inicialização para ser mais rápido depois

java -Xms512m -Xmx2g -XX:+UseG1GC -cp languagetool-server.jar org.languagetool.server.HTTPServer --port 8081 --allow-origin "*"

pause
