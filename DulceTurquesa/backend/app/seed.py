from decimal import Decimal

from sqlalchemy.orm import Session

from . import models
from .security import hash_password


def seed_database(db: Session) -> None:
    starter_users = [
        {
            "name": "Administrador Dulce Turquesa",
            "email": "admin@dulceturquesa.com",
            "role": "admin",
            "password": "Admin12345",
        },
        {
            "name": "Encargado de Panaderia",
            "email": "encargado@dulceturquesa.com",
            "role": "encargado",
            "password": "Encargado123",
        },
        {
            "name": "Vendedor de Mostrador",
            "email": "vendedor@dulceturquesa.com",
            "role": "vendedor",
            "password": "Vendedor123",
        },
        {
            "name": "Cliente Dulce Turquesa",
            "email": "cliente@dulceturquesa.com",
            "role": "cliente",
            "password": "Cliente123",
        },
    ]

    for user_data in starter_users:
        exists = db.query(models.User).filter(models.User.email == user_data["email"]).first()
        if not exists:
            db.add(
                models.User(
                    name=user_data["name"],
                    email=user_data["email"],
                    role=user_data["role"],
                    hashed_password=hash_password(user_data["password"]),
                )
            )

    if db.query(models.Product).count() == 0:
        db.add_all(
            [
                models.Product(
                    name="Concha turquesa",
                    category="Pan dulce",
                    price=Decimal("18.00"),
                    stock=40,
                    description="Concha artesanal con cobertura de vainilla.",
                ),
                models.Product(
                    name="Croissant de mantequilla",
                    category="Hojaldre",
                    price=Decimal("32.00"),
                    stock=24,
                    description="Hojaldre dorado elaborado con mantequilla.",
                ),
                models.Product(
                    name="Pastel mini de chocolate",
                    category="Pasteles",
                    price=Decimal("95.00"),
                    stock=10,
                    description="Porcion individual con ganache suave.",
                ),
                models.Product(
                    name="Cafe latte vainilla",
                    category="Cafe",
                    price=Decimal("48.00"),
                    stock=35,
                    description="Cafe espresso con leche cremosa y vainilla.",
                ),
                models.Product(
                    name="Tarta de frutos rojos",
                    category="Postres",
                    price=Decimal("72.00"),
                    stock=16,
                    description="Base crujiente, crema suave y frutos frescos.",
                ),
            ]
        )

    if db.query(models.Ingredient).count() == 0:
        db.add_all(
            [
                models.Ingredient(
                    name="Harina",
                    unit="kg",
                    minimum_stock=Decimal("8.00"),
                    current_stock=Decimal("30.00"),
                ),
                models.Ingredient(
                    name="Mantequilla",
                    unit="kg",
                    minimum_stock=Decimal("5.00"),
                    current_stock=Decimal("4.50"),
                ),
                models.Ingredient(
                    name="Azucar",
                    unit="kg",
                    minimum_stock=Decimal("6.00"),
                    current_stock=Decimal("18.00"),
                ),
            ]
        )

    db.commit()
