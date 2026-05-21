# Dulce Turquesa

App para panaderia creada con **FastAPI**, **Vue** y **SQL Server**.

## Modulos incluidos

- Login con JWT
- Gestion de usuarios
- Productos / Catalogo
- Pedidos / Ventas
- Inventario / Ingredientes
- Reportes
- Validaciones en backend y frontend
- Estructura tipo controlador en FastAPI

## Ejecutar

1. Crea una base de datos en SQL Server llamada `DulceTurquesa`.
2. Copia `.env.example` a `.env` y ajusta `DATABASE_URL`.
3. Instala dependencias:

```bash
pip install -r requirements.txt
```

4. Inicia la API:

```bash
uvicorn backend.app.main:app --reload
```

5. Abre:

```text
http://127.0.0.1:8000
```

## Usuarios iniciales

Al iniciar, se crean estos usuarios si no existen:

- Admin: `admin@dulceturquesa.com` / `Admin12345`
- Encargado: `encargado@dulceturquesa.com` / `Encargado123`
- Vendedor: `vendedor@dulceturquesa.com` / `Vendedor123`
- Cliente: `cliente@dulceturquesa.com` / `Cliente123`
