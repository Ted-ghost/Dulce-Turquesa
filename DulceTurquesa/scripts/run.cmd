@echo off
:: ============================================================
::  Dulce Turquesa - Script de inicio (Windows)
:: ============================================================

cd /d "%~dp0\.."
echo ====================================
echo  Dulce Turquesa - Backend
echo ====================================

:: 1. Entorno virtual
if not exist "venv" (
    echo [1/4] Creando entorno virtual...
    python -m venv venv
)
echo [1/4] Activando entorno virtual...
call venv\Scripts\activate.bat

:: 2. Dependencias
echo [2/4] Instalando dependencias...
pip install -r requirements.txt -q

:: 3. Archivo .env
if not exist ".env" (
    echo [3/4] Copiando .env.example -^> .env
    copy config\.env.example .env
    echo       *** Edita .env con tu DATABASE_URL antes de continuar ***
    notepad .env
    pause
) else (
    echo [3/4] .env encontrado, continuando...
)

:: 4. Servidor
echo [4/4] Iniciando servidor en http://127.0.0.1:8000
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
