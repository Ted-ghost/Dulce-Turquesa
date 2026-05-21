# Conectar Dulce Turquesa a SQL Server

## Requisitos previos

| Requisito | Verificar con |
|---|---|
| SQL Server 2016+ o SQL Server Express | SSMS o `sqlcmd -S localhost -Q "SELECT @@VERSION"` |
| ODBC Driver 17 for SQL Server | `odbcinst -q -d` (Linux) / Panel de control ODBC (Windows) |
| Python 3.11+ | `python --version` |
| pip | `pip --version` |

### Instalar ODBC Driver 17

**Windows** — descarga desde:
https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

**Ubuntu/Debian:**
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17
```

---

## Paso 1 — Crear la base de datos

Abre **SQL Server Management Studio (SSMS)** o **Azure Data Studio**, conectate a tu instancia y ejecuta:

```
config/database.sql
```

Ese script crea la BD `DulceTurquesa`, las 5 tablas, índices, restricciones, vistas y datos de prueba.

---

## Paso 2 — Configurar .env

Copia el archivo de ejemplo y edítalo:

```bash
cp config/.env.example .env
```

Elige la línea `DATABASE_URL` que corresponda a tu entorno y descomenta solo esa:

| Escenario | URL |
|---|---|
| Windows Auth (sin contraseña) | `mssql+pyodbc://localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes&TrustServerCertificate=yes` |
| Usuario + contraseña | `mssql+pyodbc://sa:TuPassword@localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes` |
| SQL Server Express | `mssql+pyodbc://localhost\SQLEXPRESS/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes` |
| Azure SQL | `mssql+pyodbc://user@srv:Pass@srv.database.windows.net/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server` |
| SQLite (sin SQL Server) | `sqlite:///./dulce_turquesa.db` |

---

## Paso 3 — Instalar dependencias y arrancar

**Linux / macOS:**
```bash
chmod +x scripts/run.sh
./scripts/run.sh
```

**Windows:**
```bat
scripts\run.cmd
```

O manualmente:
```bash
pip install -r requirements.txt
uvicorn backend.app.main:app --reload
```

Al arrancar, FastAPI:
1. Crea las tablas si no existen (SQLAlchemy `create_all`)
2. Inserta los 4 usuarios, 5 productos y 10 ingredientes de prueba (`seed.py`)

---

## Paso 4 — Verificar

Abre en el navegador:
- App: http://127.0.0.1:8000
- Swagger: http://127.0.0.1:8000/docs

Usuarios de prueba:

| Rol | Email | Contraseña |
|---|---|---|
| Admin | admin@dulceturquesa.com | Admin12345 |
| Encargado | encargado@dulceturquesa.com | Encargado123 |
| Vendedor | vendedor@dulceturquesa.com | Vendedor123 |
| Cliente | cliente@dulceturquesa.com | Cliente123 |

---

## Errores frecuentes

**`[08001] Data source name not found`**
→ El ODBC Driver 17 no está instalado o el nombre del driver en la URL no coincide.
Verifica con `odbcinst -q -d` (Linux) o el Administrador ODBC (Windows).

**`Login failed for user 'sa'`**
→ El usuario `sa` está deshabilitado o la contraseña es incorrecta.
En SSMS: clic derecho en el servidor → Propiedades → Seguridad → habilita autenticación SQL Server.

**`Cannot open database "DulceTurquesa"`**
→ Ejecuta primero `config/database.sql` en SSMS.

**`SSL Provider: [error:...] certificate verify failed`**
→ Agrega `&TrustServerCertificate=yes` al final de tu DATABASE_URL.
