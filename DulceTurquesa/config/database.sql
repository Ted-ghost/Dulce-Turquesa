-- ============================================================
--  DULCE TURQUESA -- Script SQL Server completo
--  Compatible con: SQL Server 2016+ y Azure SQL
--  ORM: SQLAlchemy (las tablas las crea el ORM, pero puedes
--       usar este script para revisarlas, recrearlas o migrar)
-- ============================================================

-- ============================================================
--  1. CREAR BASE DE DATOS
-- ============================================================
IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = N'DulceTurquesa'
)
BEGIN
    CREATE DATABASE DulceTurquesa
        COLLATE Modern_Spanish_CI_AI;   -- acentos y ñ correctos
    PRINT 'Base de datos DulceTurquesa creada.';
END
GO

USE DulceTurquesa;
GO

-- ============================================================
--  2. TABLAS
--  Orden respetando dependencias (FK):
--    users -> products -> ingredients -> orders -> order_items
-- ============================================================

-- ----------------------------------------------------------
--  2.1  users
-- ----------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'users'
)
BEGIN
    CREATE TABLE users (
        id              INT             NOT NULL IDENTITY(1,1),
        name            NVARCHAR(120)   NOT NULL,
        email           NVARCHAR(180)   NOT NULL,
        hashed_password NVARCHAR(255)   NOT NULL,
        role            NVARCHAR(40)    NOT NULL CONSTRAINT df_users_role    DEFAULT 'vendedor',
        is_active       BIT             NOT NULL CONSTRAINT df_users_active  DEFAULT 1,
        created_at      DATETIME        NOT NULL CONSTRAINT df_users_created DEFAULT GETUTCDATE(),

        CONSTRAINT pk_users       PRIMARY KEY (id),
        CONSTRAINT uq_users_email UNIQUE      (email),
        CONSTRAINT ck_users_role  CHECK (role IN ('admin','encargado','vendedor','cliente'))
    );

    CREATE INDEX ix_users_email ON users (email);

    PRINT 'Tabla users creada.';
END
GO

-- ----------------------------------------------------------
--  2.2  products
-- ----------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'products'
)
BEGIN
    CREATE TABLE products (
        id          INT             NOT NULL IDENTITY(1,1),
        name        NVARCHAR(140)   NOT NULL,
        category    NVARCHAR(80)    NOT NULL,
        price       NUMERIC(10,2)   NOT NULL,
        stock       INT             NOT NULL CONSTRAINT df_products_stock    DEFAULT 0,
        description NVARCHAR(MAX)   NULL,
        is_active   BIT             NOT NULL CONSTRAINT df_products_active   DEFAULT 1,

        CONSTRAINT pk_products      PRIMARY KEY (id),
        CONSTRAINT ck_products_price CHECK (price >= 0),
        CONSTRAINT ck_products_stock CHECK (stock >= 0)
    );

    PRINT 'Tabla products creada.';
END
GO

-- ----------------------------------------------------------
--  2.3  ingredients
-- ----------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'ingredients'
)
BEGIN
    CREATE TABLE ingredients (
        id            INT           NOT NULL IDENTITY(1,1),
        name          NVARCHAR(140) NOT NULL,
        unit          NVARCHAR(30)  NOT NULL,
        minimum_stock NUMERIC(10,2) NOT NULL CONSTRAINT df_ing_min DEFAULT 0,
        current_stock NUMERIC(10,2) NOT NULL CONSTRAINT df_ing_cur DEFAULT 0,

        CONSTRAINT pk_ingredients      PRIMARY KEY (id),
        CONSTRAINT uq_ingredients_name UNIQUE      (name),
        CONSTRAINT ck_ing_min_stock    CHECK (minimum_stock >= 0),
        CONSTRAINT ck_ing_cur_stock    CHECK (current_stock >= 0)
    );

    PRINT 'Tabla ingredients creada.';
END
GO

-- ----------------------------------------------------------
--  2.4  orders
-- ----------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'orders'
)
BEGIN
    CREATE TABLE orders (
        id            INT           NOT NULL IDENTITY(1,1),
        user_id       INT           NULL,
        customer_name NVARCHAR(140) NOT NULL,
        status        NVARCHAR(40)  NOT NULL CONSTRAINT df_orders_status  DEFAULT 'pendiente',
        total         NUMERIC(10,2) NOT NULL CONSTRAINT df_orders_total   DEFAULT 0,
        created_at    DATETIME      NOT NULL CONSTRAINT df_orders_created DEFAULT GETUTCDATE(),

        CONSTRAINT pk_orders       PRIMARY KEY (id),
        CONSTRAINT fk_orders_user  FOREIGN KEY (user_id) REFERENCES users(id),
        CONSTRAINT ck_orders_status CHECK (
            status IN ('pendiente','en_proceso','listo','entregado','cancelado')
        ),
        CONSTRAINT ck_orders_total CHECK (total >= 0)
    );

    CREATE INDEX ix_orders_user_id    ON orders (user_id);
    CREATE INDEX ix_orders_created_at ON orders (created_at DESC);

    PRINT 'Tabla orders creada.';
END
GO

-- ----------------------------------------------------------
--  2.5  order_items
-- ----------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'order_items'
)
BEGIN
    CREATE TABLE order_items (
        id         INT           NOT NULL IDENTITY(1,1),
        order_id   INT           NOT NULL,
        product_id INT           NOT NULL,
        quantity   INT           NOT NULL,
        unit_price NUMERIC(10,2) NOT NULL,
        subtotal   NUMERIC(10,2) NOT NULL,

        CONSTRAINT pk_order_items         PRIMARY KEY (id),
        CONSTRAINT fk_order_items_order   FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
        CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id),
        CONSTRAINT ck_oi_quantity         CHECK (quantity   > 0),
        CONSTRAINT ck_oi_unit_price       CHECK (unit_price >= 0),
        CONSTRAINT ck_oi_subtotal         CHECK (subtotal   >= 0)
    );

    CREATE INDEX ix_oi_order_id   ON order_items (order_id);
    CREATE INDEX ix_oi_product_id ON order_items (product_id);

    PRINT 'Tabla order_items creada.';
END
GO

-- ============================================================
--  3. DATOS INICIALES (seed)
--  Los passwords se muestran en texto plano aqui solo como
--  referencia; el hash real lo genera seed.py con bcrypt.
--  Este bloque inserta los mismos datos que seed.py para
--  entornos donde prefieras no arrancar el servidor primero.
-- ============================================================

-- 3.1  Usuarios de prueba
--  NOTA: hashed_password es un placeholder.
--        Ejecuta `uvicorn backend.app.main:app` y seed.py
--        los reemplaza con hashes bcrypt reales.
--        Si quieres usar solo SQL, genera el hash con:
--          python -c "from passlib.hash import bcrypt; print(bcrypt.hash('Admin12345'))"
--        y sustituye el valor aqui.

IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@dulceturquesa.com')
    INSERT INTO users (name, email, hashed_password, role)
    VALUES ('Administrador Dulce Turquesa', 'admin@dulceturquesa.com',
            '$HASH_ADMIN_AQUI$', 'admin');

IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'encargado@dulceturquesa.com')
    INSERT INTO users (name, email, hashed_password, role)
    VALUES ('Encargado de Panaderia', 'encargado@dulceturquesa.com',
            '$HASH_ENCARGADO_AQUI$', 'encargado');

IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'vendedor@dulceturquesa.com')
    INSERT INTO users (name, email, hashed_password, role)
    VALUES ('Vendedor de Mostrador', 'vendedor@dulceturquesa.com',
            '$HASH_VENDEDOR_AQUI$', 'vendedor');

IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'cliente@dulceturquesa.com')
    INSERT INTO users (name, email, hashed_password, role)
    VALUES ('Cliente Dulce Turquesa', 'cliente@dulceturquesa.com',
            '$HASH_CLIENTE_AQUI$', 'cliente');
GO

-- 3.2  Productos de prueba
IF NOT EXISTS (SELECT 1 FROM products)
BEGIN
    INSERT INTO products (name, category, price, stock, description) VALUES
        ('Concha turquesa',        'Pan dulce', 18.00, 40, 'Concha artesanal con cobertura de vainilla.'),
        ('Croissant de mantequilla','Hojaldre',  32.00, 24, 'Hojaldre dorado elaborado con mantequilla.'),
        ('Pastel mini de chocolate','Pasteles',  95.00, 10, 'Porcion individual con ganache suave.'),
        ('Cafe latte vainilla',    'Cafe',       48.00, 35, 'Cafe espresso con leche cremosa y vainilla.'),
        ('Tarta de frutos rojos',  'Postres',    72.00, 16, 'Base crujiente, crema suave y frutos frescos.');
    PRINT 'Productos de prueba insertados.';
END
GO

-- 3.3  Ingredientes de prueba
IF NOT EXISTS (SELECT 1 FROM ingredients)
BEGIN
    INSERT INTO ingredients (name, unit, minimum_stock, current_stock) VALUES
        ('Harina',      'kg', 8.00,  30.00),
        ('Mantequilla', 'kg', 5.00,   4.50),   -- por debajo del minimo (alerta)
        ('Azucar',      'kg', 6.00,  18.00),
        ('Huevos',      'pz', 24.00, 60.00),
        ('Leche',       'l',  4.00,  12.00),
        ('Sal',         'kg', 1.00,   3.00),
        ('Levadura',    'kg', 0.50,   1.20),
        ('Chocolate',   'kg', 2.00,   5.00),
        ('Vainilla',    'l',  0.20,   0.50),
        ('Frutos rojos','kg', 1.00,   2.50);
    PRINT 'Ingredientes de prueba insertados.';
END
GO

-- ============================================================
--  4. VISTAS UTILES
-- ============================================================

-- 4.1  Pedidos con detalle de items
CREATE OR ALTER VIEW vw_orders_detail AS
SELECT
    o.id            AS order_id,
    o.customer_name,
    o.status,
    o.total         AS order_total,
    o.created_at,
    u.name          AS user_name,
    u.role          AS user_role,
    oi.id           AS item_id,
    p.name          AS product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.subtotal
FROM orders      o
LEFT JOIN users       u  ON u.id  = o.user_id
JOIN      order_items oi ON oi.order_id   = o.id
JOIN      products    p  ON p.id  = oi.product_id;
GO

-- 4.2  Ingredientes en alerta de stock
CREATE OR ALTER VIEW vw_low_stock_ingredients AS
SELECT
    id,
    name,
    unit,
    minimum_stock,
    current_stock,
    minimum_stock - current_stock AS deficit
FROM ingredients
WHERE current_stock <= minimum_stock;
GO

-- 4.3  Resumen ejecutivo (equivalente a /api/reports/summary)
CREATE OR ALTER VIEW vw_report_summary AS
SELECT
    (SELECT COUNT(*)                        FROM products    WHERE is_active = 1)   AS products,
    (SELECT COUNT(*)                        FROM users       WHERE is_active = 1)   AS active_users,
    (SELECT COUNT(*)                        FROM orders)                            AS orders,
    (SELECT ISNULL(SUM(total), 0)           FROM orders)                            AS sales_total,
    (SELECT COUNT(*)                        FROM vw_low_stock_ingredients)          AS low_stock_ingredients;
GO

-- ============================================================
--  5. CADENA DE CONEXION (referencia para .env)
-- ============================================================
--
--  SQL Server local con autenticacion de Windows:
--    DATABASE_URL=mssql+pyodbc://localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes
--
--  SQL Server local con usuario y contrasena:
--    DATABASE_URL=mssql+pyodbc://sa:TuPassword@localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server
--
--  Azure SQL:
--    DATABASE_URL=mssql+pyodbc://usuario@servidor:password@servidor.database.windows.net/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server
--
--  Nota: reemplaza los espacios del driver con %20 si usas URL directa:
--    driver=ODBC+Driver+17+for+SQL+Server  ->  ya usa + como separador, no hace falta %20

-- ============================================================
--  6. PROCEDIMIENTOS ALMACENADOS (opcionales)
-- ============================================================

-- 6.1  Cancelar un pedido y devolver stock
CREATE OR ALTER PROCEDURE sp_cancel_order
    @order_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM orders WHERE id = @order_id AND status NOT IN ('cancelado','entregado'))
    BEGIN
        RAISERROR('El pedido no existe o no se puede cancelar.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Devolver stock a cada producto
        UPDATE p
        SET    p.stock = p.stock + oi.quantity
        FROM   products p
        JOIN   order_items oi ON oi.product_id = p.id
        WHERE  oi.order_id = @order_id;

        -- Marcar como cancelado
        UPDATE orders SET status = 'cancelado' WHERE id = @order_id;

        COMMIT;
        PRINT 'Pedido cancelado y stock restaurado.';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- 6.2  Resumen de ventas por categoria
CREATE OR ALTER PROCEDURE sp_sales_by_category
    @desde DATETIME = NULL,
    @hasta DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @desde = ISNULL(@desde, '2000-01-01');
    SET @hasta = ISNULL(@hasta, GETUTCDATE());

    SELECT
        p.category,
        SUM(oi.quantity)  AS units_sold,
        SUM(oi.subtotal)  AS revenue
    FROM   order_items oi
    JOIN   products    p  ON p.id = oi.product_id
    JOIN   orders      o  ON o.id = oi.order_id
    WHERE  o.created_at BETWEEN @desde AND @hasta
      AND  o.status NOT IN ('cancelado')
    GROUP BY p.category
    ORDER BY revenue DESC;
END
GO

PRINT '==================================';
PRINT 'Script Dulce Turquesa completado.';
PRINT '==================================';
