from pydantic_settings import BaseSettings, SettingsConfigDict

# ──────────────────────────────────────────────────────────────
#  Ejemplos de DATABASE_URL para .env
#
#  SQL Server local - Windows Auth:
#    DATABASE_URL=mssql+pyodbc://localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes&TrustServerCertificate=yes
#
#  SQL Server local - usuario/contrasena:
#    DATABASE_URL=mssql+pyodbc://sa:TuPassword@localhost/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes
#
#  SQL Server Express (instancia nombrada):
#    DATABASE_URL=mssql+pyodbc://localhost\\SQLEXPRESS/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes
#
#  Azure SQL:
#    DATABASE_URL=mssql+pyodbc://user@server:Password@server.database.windows.net/DulceTurquesa?driver=ODBC+Driver+17+for+SQL+Server
#
#  SQLite (pruebas sin SQL Server):
#    DATABASE_URL=sqlite:///./dulce_turquesa.db
# ──────────────────────────────────────────────────────────────


class Settings(BaseSettings):
    app_name: str = "Dulce Turquesa API"
    secret_key: str = "cambia-esta-clave-en-produccion"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 480
    database_url: str = (
        "mssql+pyodbc://sa:TuPassword123@localhost/DulceTurquesa"
        "?driver=ODBC+Driver+17+for+SQL+Server&TrustServerCertificate=yes"
    )

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()
