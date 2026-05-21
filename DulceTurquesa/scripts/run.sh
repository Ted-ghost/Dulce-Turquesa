#!/bin/bash
# ============================================================
#  Dulce Turquesa - Script de inicio (Linux / macOS)
# ============================================================

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "===================================="
echo " Dulce Turquesa - Backend"
echo "===================================="

# 1. Entorno virtual
if [ ! -d "venv" ]; then
    echo "[1/4] Creando entorno virtual..."
    python3 -m venv venv
fi

echo "[1/4] Activando entorno virtual..."
source venv/bin/activate

# 2. Dependencias
echo "[2/4] Instalando dependencias..."
pip install -r requirements.txt -q

# 3. Archivo .env
if [ ! -f ".env" ]; then
    echo "[3/4] Copiando .env.example -> .env"
    cp config/.env.example .env
    echo "      *** Edita .env con tu DATABASE_URL antes de continuar ***"
    echo "      Presiona ENTER para abrir .env o Ctrl+C para cancelar"
    read -r
    "${EDITOR:-nano}" .env
else
    echo "[3/4] .env encontrado, continuando..."
fi

# 4. Servidor
echo "[4/4] Iniciando servidor en http://127.0.0.1:8000"
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
