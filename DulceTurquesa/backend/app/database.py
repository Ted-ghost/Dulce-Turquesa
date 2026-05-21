from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker
from sqlalchemy.pool import StaticPool

from .config import settings


def _build_engine_options(url: str) -> dict:
    """Devuelve opciones de engine según el dialecto detectado en la URL."""
    opts: dict = {"pool_pre_ping": True}

    if url.startswith("sqlite"):
        opts["connect_args"] = {"check_same_thread": False}
        opts["poolclass"] = StaticPool

    elif "mssql" in url or "pyodbc" in url:
        # SQL Server: pool más conservador para evitar conexiones colgadas
        opts["pool_size"] = 5
        opts["max_overflow"] = 10
        opts["pool_timeout"] = 30
        opts["pool_recycle"] = 1800  # recicla conexiones cada 30 min

    return opts


engine = create_engine(settings.database_url, **_build_engine_options(settings.database_url))
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
