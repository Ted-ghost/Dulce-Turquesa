# Estructura del proyecto - Dulce Turquesa

Proyecto para una panaderia/cafeteria con backend en FastAPI, frontend en Vue desde CDN y base de datos SQL Server. No usa package.json.

```text
DulceTurquesa/
|-- backend/
|   |-- __init__.py
|   `-- app/
|       |-- __init__.py
|       |-- main.py              # Entrada principal de FastAPI
|       |-- config.py            # Configuracion y variables de entorno
|       |-- database.py          # Conexion SQL Server / SQLAlchemy
|       |-- dependencies.py      # Dependencias de seguridad y sesion
|       |-- models.py            # Tablas ORM
|       |-- schemas.py           # Validaciones Pydantic
|       |-- security.py          # JWT y contrasenas
|       |-- seed.py              # Usuarios y datos iniciales
|       |-- controllers/
|       |   |-- auth.py          # Login
|       |   |-- users.py         # Gestion de usuarios
|       |   |-- products.py      # Productos / catalogo
|       |   |-- orders.py        # Pedidos / ventas / cliente
|       |   |-- inventory.py     # Ingredientes / inventario
|       |   `-- reports.py       # Reportes
|       |-- middleware/
|       |-- services/
|       `-- utils/
|
|-- frontend/
|   |-- index.html               # Vista principal Vue
|   |-- app.js                   # Logica de roles, carrito y API
|   |-- styles.css               # Diseno visual turquesa/pastel
|   `-- assets/
|       |-- images/
|       `-- fonts/
|
|-- config/
|   |-- .env                     # Configuracion local
|   |-- .env.example             # Plantilla de configuracion
|   `-- database.sql             # Script para crear base SQL Server
|
|-- docs/
|   |-- README.md                # Guia de uso
|   `-- STRUCTURE.md             # Este archivo
|
|-- scripts/
|   |-- run.cmd                  # Ejecutar en Windows
|   `-- run.sh                   # Ejecutar en Linux/macOS
|
|-- tests/
|   `-- smoke_test.py            # Prueba rapida de login/API
|
|-- requirements.txt             # Dependencias Python
|-- .gitignore
`-- .editorconfig
```

## Roles

```text
Admin      -> Usuarios, catalogo, ventas, inventario y reportes.
Encargado  -> Catalogo, ventas, inventario y reportes.
Vendedor   -> Ventas y consulta de productos.
Cliente    -> Catalogo, carrito y mis pedidos.
```

## Usuarios de prueba

```text
admin@dulceturquesa.com      / Admin12345
encargado@dulceturquesa.com  / Encargado123
vendedor@dulceturquesa.com   / Vendedor123
cliente@dulceturquesa.com    / Cliente123
```

## Ejecucion

```bash
pip install -r requirements.txt
uvicorn backend.app.main:app --reload
```

Despues abre:

```text
http://127.0.0.1:8000
```
