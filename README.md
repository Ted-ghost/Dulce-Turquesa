# Dulce Turquesa

Sistema de gestión para panadería artesanal construido con **FastAPI**, **Vue 3** y **SQL Server 2022**.

---

## Tecnología

| Capa | Tecnología |
|---|---|
| Backend | FastAPI 0.115 + Uvicorn |
| Frontend | Vue 3 desde CDN (sin build) |
| Base de datos | SQL Server 2022 Express |
| ORM | SQLAlchemy 2.0 |
| Autenticación | JWT (python-jose + bcrypt) |
| Validaciones | Pydantic v2 |
| Conector DB | pyodbc + ODBC Driver 17 |

---

## Módulos

- **Login** — Autenticación JWT con expiración configurable
- **Usuarios** — CRUD completo con roles y validaciones estrictas
- **Productos / Catálogo** — Gestión de productos con stock y categorías
- **Pedidos / Ventas** — Registro de ventas multi-ítem con cálculo de totales
- **Inventario** — Control de ingredientes con alertas de stock mínimo
- **Reportes** — Resumen general de ventas, usuarios y alertas
- **Catálogo cliente** — Vista pública de productos disponibles
- **Carrito** — Carrito persistente por usuario con validación de stock
- **Mis pedidos** — Historial de pedidos del cliente autenticado

---

## Roles y permisos

| Rol | Permisos |
|---|---|
| **Admin** | Usuarios · Catálogo · Ventas · Inventario · Reportes |
| **Encargado** | Catálogo · Ventas · Inventario · Reportes |
| **Vendedor** | Consulta de productos · Registro de ventas |
| **Cliente** | Catálogo · Carrito · Mis pedidos |

---

## Instalación

### Requisitos previos

- Python 3.12
- SQL Server 2022 Express
- ODBC Driver 17 for SQL Server
- Visual Studio Code (recomendado)

### Paso 1 — Crear la base de datos

Abrir `config/database.sql` en SSMS y presionar **F5**.

El script crea:
- Base de datos `DulceTurquesa`
- Tablas: `users`, `products`, `ingredients`, `orders`, `order_items`
- Índices y restricciones
- Vistas: `vw_orders_detail`, `vw_low_stock_ingredients`, `vw_report_summary`
- Procedimientos: `sp_cancel_order`, `sp_sales_by_category`
- Datos de prueba: 5 productos, 10 ingredientes

### Paso 2 — Configurar el entorno

Copiar `.env.example` a `.env` en la raíz del proyecto y ajustar `DATABASE_URL`:

```env
# SQL Server Express con Windows Auth (sin contraseña):
DATABASE_URL=mssql+pyodbc://localhost\SQLEXPRESS/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes&TrustServerCertificate=yes

# SQL Server local con usuario y contraseña:
DATABASE_URL=mssql+pyodbc://sa:TuPassword@localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes

# SQLite (solo para pruebas sin SQL Server):
DATABASE_URL=sqlite:///./dulce_turquesa.db
```

### Paso 3 — Instalar dependencias

```bash
py -3.12 -m venv venv
venv\Scripts\pip install -r requirements.txt
```

### Paso 4 — Crear usuarios iniciales

```bash
venv\Scripts\python -c "from backend.app.database import SessionLocal; from backend.app.seed import seed_database; db = SessionLocal(); seed_database(db); db.close(); print('Seed OK')"
```

### Paso 5 — Iniciar el servidor

```bash
venv\Scripts\uvicorn backend.app.main:app --reload
```

Abrir en el navegador:

```
http://127.0.0.1:8000        # Aplicación
http://127.0.0.1:8000/docs   # Swagger UI
```

---

## Usuarios de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Admin | admin@dulceturquesa.com | Admin12345 |
| Encargado | encargado@dulceturquesa.com | Encargado123 |
| Vendedor | vendedor@dulceturquesa.com | Vendedor123 |
| Cliente | cliente@dulceturquesa.com | Cliente123 |

---

## Validaciones de negocio

- **Nombre de usuario** — Solo letras, sin números ni caracteres especiales
- **Correo** — Debe pertenecer a Gmail, Hotmail, Outlook, Yahoo, iCloud o Live
- **Contraseña** — Mínimo 8 caracteres, una mayúscula y un número
- **Precio** — Debe ser mayor a cero
- **Stock** — No puede ser negativo
- **Carrito** — Respeta el stock disponible por producto
- **Inventario** — Alerta visual cuando stock actual ≤ stock mínimo

---

## Estructura del proyecto

```
DulceTurquesa/
├── backend/
│   └── app/
│       ├── controllers/
│       │   ├── auth.py          # Login y token JWT
│       │   ├── users.py         # Gestión de usuarios
│       │   ├── products.py      # Catálogo de productos
│       │   ├── orders.py        # Pedidos y ventas
│       │   ├── inventory.py     # Ingredientes e inventario
│       │   └── reports.py       # Reportes y resúmenes
│       ├── models.py            # ORM: User, Product, Ingredient, Order, OrderItem
│       ├── schemas.py           # Validaciones Pydantic
│       ├── security.py          # JWT y hashing bcrypt
│       ├── database.py          # Conexión SQLAlchemy
│       ├── dependencies.py      # Inyección de dependencias
│       ├── seed.py              # Datos iniciales
│       ├── config.py            # Variables de entorno
│       └── main.py              # Entrada de FastAPI
├── frontend/
│   ├── index.html               # Vista principal Vue
│   ├── app.js                   # Lógica de roles, carrito y API
│   └── styles.css               # Diseño turquesa/pastel
├── config/
│   ├── database.sql             # Script completo SQL Server
│   ├── .env                     # Configuración local
│   └── .env.example             # Plantilla de configuración
├── docs/
│   ├── README.md                # Este archivo
│   ├── STRUCTURE.md             # Estructura detallada
│   └── CONEXION_SQLSERVER.md    # Guía de conexión y errores frecuentes
├── scripts/
│   ├── run.cmd                  # Inicio en Windows
│   └── run.sh                   # Inicio en Linux/macOS
├── tests/
│   └── smoke_test.py            # Prueba rápida de login y API
├── .vscode/
│   ├── tasks.json               # Tareas de build y servidor
│   ├── launch.json              # Configuración de depuración
│   ├── settings.json            # Configuración del editor
│   └── extensions.json          # Extensiones recomendadas
└── requirements.txt             # Dependencias Python
```

---

## Endpoints principales

| Método | Ruta | Rol mínimo | Descripción |
|---|---|---|---|
| POST | `/api/auth/login` | Público | Autenticación y token JWT |
| GET | `/api/users` | Admin | Listar usuarios |
| POST | `/api/users` | Admin | Crear usuario |
| GET | `/api/products` | Todos | Listar productos |
| POST | `/api/products` | Admin/Encargado | Crear producto |
| GET | `/api/orders` | Todos | Listar pedidos propios |
| POST | `/api/orders` | Todos | Crear pedido |
| GET | `/api/inventory` | Admin/Encargado | Listar ingredientes |
| POST | `/api/inventory` | Admin/Encargado | Crear ingrediente |
| GET | `/api/reports/summary` | Admin/Encargado | Resumen general |

Documentación interactiva completa disponible en `/docs`.

---

## Errores frecuentes

**`Login failed for user 'sa'`**
El usuario `sa` está desactivado. Usar Windows Auth o habilitarlo en SSMS → Propiedades del servidor → Seguridad.

**`[08001] Named Pipes Provider`**
La instancia de SQL Server no es `localhost`. Cambiar a `localhost\SQLEXPRESS` en el `.env`.

**`SSL certificate verify failed`**
Agregar `&TrustServerCertificate=yes` al final de `DATABASE_URL`.

**`ODBC Driver not found`**
Instalar ODBC Driver 17 desde: https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server

**`TypeError: typing.Union`**
Python 3.14 no es compatible. Usar Python 3.12: `py -3.12 -m venv venv`
