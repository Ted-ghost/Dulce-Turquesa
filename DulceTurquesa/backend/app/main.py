from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import inspect, text

from .controllers import auth, inventory, orders, products, reports, users
from .database import Base, SessionLocal, engine
from .seed import seed_database


ROOT_DIR = Path(__file__).resolve().parents[2]
FRONTEND_DIR = ROOT_DIR / "frontend"

app = FastAPI(title="Dulce Turquesa API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)
    ensure_order_user_column()
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()


def ensure_order_user_column() -> None:
    inspector = inspect(engine)
    if "orders" not in inspector.get_table_names():
        return
    columns = {column["name"] for column in inspector.get_columns("orders")}
    if "user_id" in columns:
        return

    column_type = "INTEGER" if engine.dialect.name == "sqlite" else "INT"
    with engine.begin() as connection:
        connection.execute(text(f"ALTER TABLE orders ADD user_id {column_type} NULL"))


app.include_router(auth.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(products.router, prefix="/api")
app.include_router(inventory.router, prefix="/api")
app.include_router(orders.router, prefix="/api")
app.include_router(reports.router, prefix="/api")

app.mount("/", StaticFiles(directory=FRONTEND_DIR, html=True), name="frontend")
